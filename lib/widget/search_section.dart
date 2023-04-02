import 'package:dabel_adl/controller/AnimationController.dart';
import 'package:dabel_adl/controller/BookController.dart';
import 'package:dabel_adl/controller/ContractController.dart';
import 'package:dabel_adl/controller/DocumentController.dart';
import 'package:dabel_adl/controller/FinderController.dart';
import 'package:dabel_adl/controller/LawyerController.dart';
import 'package:dabel_adl/controller/LegalController.dart';
import 'package:dabel_adl/controller/LinkController.dart';
import 'package:dabel_adl/controller/LocationController.dart';
import 'package:dabel_adl/helper/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/ContentController.dart';

class SearchSection extends StatelessWidget {
  TextEditingController textController = TextEditingController();
  dynamic controller;

  MyAnimationController animationController = Get.find<MyAnimationController>();
  Style styleController = Get.find<Style>();

  Widget filterSection;
  String hintText;

  SearchSection({
    Key? key,
    required this.filterSection,
    required this.controller,
    required this.hintText,
  }) {
    controller.filterController.filters['search'] = '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Padding(
            padding: EdgeInsets.all(styleController.cardMargin / 2)
                .copyWith(bottom: 0),
            child: Column(
              children: [
                Stack(
                  children: [
                    //filters section
                    Card(
                      margin: EdgeInsets.only(
                        top: styleController.cardMargin * 2,
                        left: styleController.cardMargin / 2,
                        right: styleController.cardMargin / 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            styleController.cardBorderRadius),
                      ),
                      color: Colors.white.withOpacity(.95),
                      child: SizeTransition(
                        sizeFactor: animationController.animation_height_filter,
                        child: Container(
                          padding:
                              EdgeInsets.only(top: styleController.tabHeight),
                          child: filterSection,
                        ),
                      ),
                    ),
                    //main section
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            styleController.cardBorderRadius),
                      ),
                      child: ListTile(
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextButton.icon(
                                  style: ButtonStyle(
                                      overlayColor:
                                          MaterialStateProperty.resolveWith(
                                        (states) {
                                          return states.contains(
                                                  MaterialState.pressed)
                                              ? styleController.secondaryColor
                                              : null;
                                        },
                                      ),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              styleController.primaryColor),
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                        borderRadius: BorderRadius.horizontal(
                                            right: Radius.circular(
                                                styleController
                                                    .cardBorderRadius)),
                                      ))),
                                  onPressed: () {
                                    animationController.toggleFilterSearch();
                                  },
                                  icon: Icon(Icons.filter_alt,
                                      color: Colors.white),
                                  label: Text(
                                    'filter'.tr,
                                    style: styleController.textMediumLightStyle,
                                  )),
                              VerticalDivider(
                                indent: styleController.cardMargin / 2,
                                endIndent: styleController.cardMargin / 2,
                              ),
                              IconButton(
                                  onPressed: () => controller
                                      .getData(param: {'page': 'clear'}),
                                  icon: Icon(Icons.search)),
                            ],
                          ),
                          title: TextField(
                            controller: textController,
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                                hintText: hintText, border: InputBorder.none),
                            onSubmitted: (str) {
                              controller.getData(param: {'page': 'clear'});
                            },
                            // onEditingComplete: () {
                            //   controller.getData(param: {'page': 'clear'});
                            // },
                            onChanged: (str) {
                              controller.filterController.filters['search'] =
                                  str;
                              controller.filterController.filters['page'] = '1';
                              animationController
                                  .toggleCloseSearchIcon(str.length);
                            },
                          ),
                          trailing: FadeTransition(
                            opacity: animationController.fadeShowController,
                            child: IconButton(
                              splashColor: styleController.secondaryColor,
                              icon: Icon(Icons.close),
                              onPressed: () {
                                textController.clear();
                                controller.filterController.filters['search'] =
                                    '';
                                animationController.toggleCloseSearchIcon(0);

                                controller.getData(param: {'page': 'clear'});
                                // animationController
                                //     .toggleCloseSearchIcon(0);
                                // controller.getData(params: {'page': '1'});
                                // onSearchTextChanged('');
                              },
                            ),
                          )),
                    ),
                  ],
                ),
                SelectedFiltersSection(
                    controller: controller,
                    animationController: animationController,
                    styleController: styleController),
              ],
            )));
  }
}

class SelectedFiltersSection extends StatelessWidget {
  final controller;

  late dynamic filters;
  Style styleController;
  MyAnimationController animationController;

  SelectedFiltersSection(
      {required this.controller,
      required this.styleController,
      required this.animationController}) {
    animationController.toggleFilterSearch(open: false);
  }

  @override
  Widget build(BuildContext context) {
    if (controller is LinkController)
      return Get.find<LinkController>().filterController.obx((data) {
        filters = controller.filterController.filters;
        filters = controller.filterController.filters.keys
            .where((type) =>
                type != 'page' &&
                type != 'search' &&
                type != 'panel' &&
                filters[type] != '' &&
                filters[type] != null)
            .toList().reversed;
        return Container(
          height: filters.length > 0 ? 48 : 0,
          margin: EdgeInsets.only(top: styleController.cardMargin / 2),
          child: ListView(
            shrinkWrap: false,
            scrollDirection: Axis.horizontal,
            children: filters.map<Widget>((key) => makeWidget(key)).toList(),
          ),
        );
      });

    if (controller is ContentController)
      return Get.find<ContentController>().filterController.obx((data) {
        filters = controller.filterController.filters;
        filters = controller.filterController.filters.keys
            .where((type) =>
                type != 'page' &&
                type != 'search' &&
                type != 'type' &&
                type != 'panel' &&
                filters[type] != '' &&
                filters[type] != null)
            .toList().reversed;

        return Container(
          height: filters.length > 0 ? 48 : 0,
          margin: EdgeInsets.only(top: styleController.cardMargin / 2),
          child: ListView(
            shrinkWrap: false,
            scrollDirection: Axis.horizontal,
            children: filters.map<Widget>((key) => makeWidget(key)).toList(),
          ),
        );
      });

    if (controller is LawyerController)
      return Get.find<LawyerController>().filterController.obx((data) {
        filters = controller.filterController.filters;
        filters = controller.filterController.filters.keys
            .where((type) =>
                type != 'page' &&
                type != 'search' &&
                type != 'target' &&
                type != 'city_id' &&
                type != 'province_id' &&
                type != 'panel' &&
                filters[type] != '' &&
                filters[type] != null)
            .toList().reversed;

        return Container(
          height: filters.length > 0 ? 48 : 0,
          margin: EdgeInsets.only(top: styleController.cardMargin / 2),
          child: ListView(
            shrinkWrap: false,
            scrollDirection: Axis.horizontal,
            children: filters.map<Widget>((key) => makeWidget(key)).toList(),
          ),
        );
      });
    if (controller is LocationController)
      return Get.find<LocationController>().filterController.obx((data) {
        filters = controller.filterController.filters;
        filters = controller.filterController.filters.keys
            .where((type) =>
                type != 'page' &&
                type != 'search' &&
                type != 'target' &&
                type != 'panel' &&
                filters[type] != '' &&
                filters[type] != null)
            .toList().reversed;

        return Container(
          height: filters.length > 0 ? 48 : 0,
          margin: EdgeInsets.only(top: styleController.cardMargin / 2),
          child: ListView(
            shrinkWrap: false,
            scrollDirection: Axis.horizontal,
            children: filters.map<Widget>((key) => makeWidget(key)).toList(),
          ),
        );
      });
    if (controller is DocumentController)
      return Get.find<DocumentController>().filterController.obx((data) {
        filters = controller.filterController.filters;
        filters = controller.filterController.filters.keys
            .where((type) =>
                type != 'page' &&
                type != 'search' &&
                type != 'target' &&
                type != 'city_id' &&
                type != 'province_id' &&
                type != 'document_type' &&
                type != 'panel' &&
                filters[type] != '' &&
                filters[type] != null)
            .toList().reversed;

        return Container(
          height: filters.length > 0 ? 48 : 0,
          margin: EdgeInsets.only(top: styleController.cardMargin / 2),
          child: ListView(
            shrinkWrap: false,
            scrollDirection: Axis.horizontal,
            children: filters.map<Widget>((key) => makeWidget(key)).toList(),
          ),
        );
      });
    if (controller is FinderController)
      return Get.find<FinderController>().filterController.obx((data) {
        filters = controller.filterController.filters;
        filters = controller.filterController.filters.keys
            .where((type) =>
                type != 'page' &&
                type != 'search' &&
                type != 'target' &&
                type != 'paginate' &&
                type != 'finder' &&
                type != 'document_type' &&
                filters[type] != '' &&
                filters[type] != null)
            .toList().reversed;

        return Container(
          height: filters.length > 0 ? 48 : 0,
          margin: EdgeInsets.only(top: styleController.cardMargin / 2),
          child: ListView(
            shrinkWrap: false,
            scrollDirection: Axis.horizontal,
            children: filters.map<Widget>((key) => makeWidget(key)).toList(),
          ),
        );
      });
    if (controller is LegalController)
      return Get.find<LegalController>().filterController.obx((data) {
        filters = controller.filterController.filters;
        filters = controller.filterController.filters.keys
            .where((type) =>
                type != 'page' &&
                type != 'search' &&
                type != 'target' &&
                type != 'paginate' &&
                type != 'finder' &&
                filters[type] != '' &&
                filters[type] != null)
            .toList().reversed;

        return Container(
          height: filters.length > 0 ? 48 : 0,
          margin: EdgeInsets.only(top: styleController.cardMargin / 2),
          child: ListView(
            shrinkWrap: false,
            scrollDirection: Axis.horizontal,
            children: filters.map<Widget>((key) => makeWidget(key)).toList(),
          ),
        );
      });

    if (controller is ContractController)
      return Get.find<ContractController>().filterController.obx((data) {
        filters = controller.filterController.filters;
        filters = controller.filterController.filters.keys
            .where((type) =>
                type != 'page' &&
                type != 'search' &&
                type != 'target' &&
                type != 'paginate' &&
                type != 'finder' &&
                filters[type] != '' &&
                filters[type] != null)
            .toList().reversed;

        return Container(
          height: filters.length > 0 ? 48 : 0,
          margin: EdgeInsets.only(top: styleController.cardMargin / 2),
          child: ListView(
            shrinkWrap: false,
            scrollDirection: Axis.horizontal,
            children: filters.map<Widget>((key) => makeWidget(key)).toList(),
          ),
        );
      });

    if (controller is BookController)
      return Get.find<BookController>().filterController.obx((data) {
        filters = controller.filterController.filters;
        filters = controller.filterController.filters.keys
            .where((type) =>
                type != 'page' &&
                type != 'search' &&
                type != 'target' &&
                type != 'paginate' &&
                type != 'finder' &&
                filters[type] != '' &&
                filters[type] != null)
            .toList().reversed;

        return Container(
          height: filters.length > 0 ? 48 : 0,
          margin: EdgeInsets.only(top: styleController.cardMargin / 2),
          child: ListView(
            shrinkWrap: false,
            scrollDirection: Axis.horizontal,
            children: filters.map<Widget>((key) => makeWidget(key)).toList(),
          ),
        );
      });

    return Center();
  }

  Widget makeWidget(String type) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: styleController.cardMargin / 4,
          vertical: styleController.cardMargin / 4),
      padding: EdgeInsets.symmetric(horizontal: styleController.cardMargin / 2),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(.95),
          borderRadius: BorderRadius.all(
              Radius.circular(styleController.cardBorderRadius / 4))),
      child: Row(
        children: [
          Text(
            type.tr + ' | ' + controller.filterController.getFilterName(type),
            style: styleController.textSmallStyle.copyWith(
                color: styleController.primaryColor,
                fontWeight: FontWeight.bold,
                fontFamily: 'Shabnam'),
          ),
          Material(
            color: Colors.transparent,
            child: IconButton(
                onPressed: () {
                  controller.filterController.toggleFilter(type);
                },
                icon: Icon(
                  Icons.clear_rounded,
                  color: styleController.primaryColor,
                )),
          )
        ],
      ),
    );
  }
}
