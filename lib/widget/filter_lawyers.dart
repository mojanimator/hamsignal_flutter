import 'package:dabel_adl/controller/AnimationController.dart';
import 'package:dabel_adl/controller/SettingController.dart';
import 'package:dabel_adl/helper/styles.dart';
import 'package:dabel_adl/widget/filter_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/LawyerController.dart';

class LawyerFilterSection extends StatelessWidget {
  final LawyerController controller;
  late MyTabController tabController;

  final MyAnimationController animationController =
      Get.find<MyAnimationController>();
  final Style styleController = Get.find<Style>();
  final SettingController settingController = Get.find<SettingController>();

  LawyerFilterSection({required this.controller}) {
    tabController = MyTabController(length: 3);
  }

  @override
  Widget build(BuildContext context) {
    return controller.filterController.obx(
      (data) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: Get.height * 2 / 3),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                SizedBox(
                  height: styleController.cardMargin * 2,
                ),
                Center(
                  child: MyToggleButtons(
                    type: 'target',
                    controller: controller.filterController,
                    styleController: styleController,
                    children: [

                      Container(
                          padding: EdgeInsets.all(styleController.cardMargin),
                          child: Text('lawyer'.tr)),
                      Container(
                          padding: EdgeInsets.all(styleController.cardMargin),
                          child: Text('expert'.tr))
                    ],
                  ),
                ),
                Center(
                  child: MyDropdownButton(
                      styleController: styleController,
                      controller: controller.filterController,
                      type: 'category_id',
                      children: controller.categories
                          .where((e) =>
                              controller.filterController.filters['target'] ==
                                  null ||
                              e['type'] ==
                                  controller.filterController.filters['target'])
                          .toList(),
                      margin: EdgeInsets.symmetric(
                          horizontal: styleController.cardMargin,
                          vertical: styleController.cardMargin / 4)),
                ),
                Center(
                  child: Row(
                    children: [
                      Expanded(
                        child: MyDropdownButton(
                          styleController: styleController,
                          controller: controller.filterController,
                          type: 'province',
                          children: settingController.provinces,
                          margin: EdgeInsets.only(
                              left: styleController.cardMargin / 4,
                              right: styleController.cardMargin,
                              bottom: styleController.cardMargin / 4,
                              top: styleController.cardMargin / 4),
                        ),
                      ),
                      Expanded(
                        child: MyDropdownButton(
                          styleController: styleController,
                          controller: controller.filterController,
                          type: 'county',
                          children: settingController.counties
                              .where((e) =>
                                  e['province_id'] ==
                                  controller
                                      .filterController.filters['province_id'])
                              .toList(),
                          margin: EdgeInsets.only(
                              left: styleController.cardMargin,
                              right: styleController.cardMargin / 4,
                              bottom: styleController.cardMargin / 4,
                              top: styleController.cardMargin / 4),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(styleController.cardMargin),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextButton.icon(
                            style: ButtonStyle(
                                padding: MaterialStateProperty.all(
                                    EdgeInsets.symmetric(
                                        vertical: styleController.cardMargin)),
                                elevation: MaterialStateProperty.all(10),
                                overlayColor: MaterialStateProperty.resolveWith(
                                  (states) {
                                    return states
                                            .contains(MaterialState.pressed)
                                        ? styleController.secondaryColor
                                        : null;
                                  },
                                ),
                                backgroundColor: MaterialStateProperty.all(
                                    styleController.primaryColor),
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.horizontal(
                                      right: Radius.circular(
                                          styleController.cardBorderRadius *
                                              2)),
                                ))),
                            onPressed: () {
                              controller.getData(param: {'page': 'clear'});
                            },
                            icon: Icon(Icons.search, color: Colors.white),
                            label: Text(
                              'search'.tr,
                              style: styleController.textMediumLightStyle,
                            )),
                      ),
                      Expanded(
                        flex: 1,
                        child: TextButton.icon(
                            style: ButtonStyle(
                                padding: MaterialStateProperty.all(
                                    EdgeInsets.symmetric(
                                        vertical: styleController.cardMargin)),
                                elevation: MaterialStateProperty.all(10),
                                overlayColor: MaterialStateProperty.resolveWith(
                                  (states) {
                                    return states
                                            .contains(MaterialState.pressed)
                                        ? styleController.secondaryColor
                                        : null;
                                  },
                                ),
                                backgroundColor: MaterialStateProperty.all(
                                    styleController.primaryColor),
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.horizontal(
                                      left: Radius.circular(
                                          styleController.cardBorderRadius *
                                              2)),
                                ))),
                            onPressed: () {
                              animationController.toggleFilterSearch();
                            },
                            icon: Icon(Icons.arrow_upward, color: Colors.white),
                            label: Text('')),
                      ),
                    ],
                  ),
                ),
                // TabBar(
                //     indicatorWeight: 2,
                //     unselectedLabelColor: styleController.primaryColor,
                //     overlayColor:
                //         MaterialStateProperty.all(styleController.primaryColor),
                //     unselectedLabelStyle: styleController.textMediumStyle
                //         .copyWith(fontFamily: 'Shabnam'),
                //     labelColor: Colors.white,
                //     indicator: BoxDecoration(color: styleController.primaryColor),
                //     controller: tabController.controller,
                //     tabs: [
                //       Tab(
                //         child: Text('sex'.tr),
                //       ),
                //       Tab(
                //         child: Text('man'.tr),
                //       ),
                //       Tab(
                //         child: Text('woman'.tr),
                //       ),
                //     ])
              ],
            ),
          ),
        );
      },
      onLoading: Center(),
    );
  }
}