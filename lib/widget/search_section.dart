import 'package:dabel_sport/controller/AnimationController.dart';
import 'package:dabel_sport/controller/BlogController.dart';
import 'package:dabel_sport/controller/ClubController.dart';
import 'package:dabel_sport/controller/CoachController.dart';
import 'package:dabel_sport/controller/PlayerController.dart';
import 'package:dabel_sport/controller/ProductController.dart';
import 'package:dabel_sport/controller/ShopController.dart';
import 'package:dabel_sport/controller/TournamentController.dart';
import 'package:dabel_sport/helper/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    controller.filterController.filters['name'] = '';
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
                          padding: EdgeInsets.only(
                              top: styleController.cardMargin * 2),
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
                              controller.filterController.filters['name'] = str;
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
                                controller.filterController.filters['name'] =
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
    if (controller is PlayerController)
      return Get.find<PlayerController>().filterController.obx((data) {
        filters = controller.filterController.filters;
        filters = controller.filterController.filters.keys
            .where((type) =>
                type != 'page' &&
                type != 'name' &&
                type != 'panel' &&
                filters[type] != '' &&
                filters[type] != null)
            .toList();
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
    if (controller is CoachController)
      return Get.find<CoachController>().filterController.obx((data) {
        filters = controller.filterController.filters;
        filters = controller.filterController.filters.keys
            .where((type) =>
                type != 'page' &&
                type != 'name' &&
                type != 'panel' &&
                filters[type] != '' &&
                filters[type] != null)
            .toList();
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
    if (controller is ClubController)
      return Get.find<ClubController>().filterController.obx((data) {
        filters = controller.filterController.filters;
        filters = controller.filterController.filters.keys
            .where((type) =>
                type != 'page' &&
                type != 'name' &&
                type != 'panel' &&
                filters[type] != '' &&
                filters[type] != null)
            .toList();
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
    if (controller is ShopController)
      return Get.find<ShopController>().filterController.obx((data) {
        filters = controller.filterController.filters;
        filters = controller.filterController.filters.keys
            .where((type) =>
                type != 'page' &&
                type != 'name' &&
                type != 'panel' &&
                filters[type] != '' &&
                filters[type] != null)
            .toList();
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
    if (controller is ProductController)
      return Get.find<ProductController>().filterController.obx((data) {
        filters = controller.filterController.filters;
        filters = controller.filterController.filters.keys
            .where((type) =>
                type != 'page' &&
                type != 'name' &&
                type != 'panel' &&
                filters[type] != '' &&
                filters[type] != null)
            .toList();
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
    if (controller is BlogController)
      return Get.find<BlogController>().filterController.obx((data) {
        filters = controller.filterController.filters;
        filters = controller.filterController.filters.keys
            .where((type) =>
                type != 'page' &&
                type != 'name' &&
                type != 'panel' &&
                filters[type] != '' &&
                filters[type] != null)
            .toList();
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
    if (controller is TournamentController)
      return Get.find<TournamentController>().filterController.obx((data) {
        filters = controller.filterController.filters;
        filters = controller.filterController.filters.keys
            .where((type) =>
                type != 'page' &&
                type != 'name' &&
                type != 'panel' &&
                filters[type] != '' &&
                filters[type] != null)
            .toList();
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
