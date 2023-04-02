import 'package:dabel_adl/controller/AnimationController.dart';
import 'package:dabel_adl/controller/ContentController.dart';
import 'package:dabel_adl/controller/SettingController.dart';
import 'package:dabel_adl/helper/styles.dart';
import 'package:dabel_adl/widget/filter_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BlogFilterSection extends StatelessWidget {
  final ContentController controller;
  late final MyTabController tabController;

  final MyAnimationController animationController =
      Get.find<MyAnimationController>();
  final Style styleController = Get.find<Style>();
  final SettingController settingController = Get.find<SettingController>();

  BlogFilterSection({required this.controller}) {
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
                  child: MyDropdownButton(
                      styleController: styleController,
                      controller: controller.filterController,
                      type: 'category',
                      children: settingController.categories,
                      margin: EdgeInsets.symmetric(
                          horizontal: styleController.cardMargin,
                          vertical: styleController.cardMargin / 4)),
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
