import 'package:hamsignal/controller/AnimationController.dart';
import 'package:hamsignal/controller/SettingController.dart';
import 'package:hamsignal/helper/styles.dart';
import 'package:hamsignal/widget/filter_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/TransactionController.dart';

class TransactionFilterSection extends StatelessWidget {
  final TransactionController controller;
  late MyTabController tabController;

  final MyAnimationController animationController =
      Get.find<MyAnimationController>();
  final Style style = Get.find<Style>();
  final SettingController settingController = Get.find<SettingController>();

  TransactionFilterSection({required this.controller}) {
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
                  height: style.cardMargin * 2,
                ),

                Padding(
                  padding: EdgeInsets.all(style.cardMargin),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextButton.icon(
                            style: ButtonStyle(
                                padding: MaterialStateProperty.all(
                                    EdgeInsets.symmetric(
                                        vertical: style.cardMargin)),
                                elevation: MaterialStateProperty.all(10),
                                overlayColor: MaterialStateProperty.resolveWith(
                                  (states) {
                                    return states
                                            .contains(MaterialState.pressed)
                                        ? style.secondaryColor
                                        : null;
                                  },
                                ),
                                backgroundColor: MaterialStateProperty.all(
                                    style.primaryColor),
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.horizontal(
                                      right: Radius.circular(
                                          style.cardBorderRadius * 2)),
                                ))),
                            onPressed: () {
                              controller.getData(param: {'page': 'clear'});
                            },
                            icon: Icon(Icons.search, color: Colors.white),
                            label: Text(
                              'search'.tr,
                              style: style.textMediumLightStyle,
                            )),
                      ),
                      Expanded(
                        flex: 1,
                        child: TextButton.icon(
                            style: ButtonStyle(
                                padding: MaterialStateProperty.all(
                                    EdgeInsets.symmetric(
                                        vertical: style.cardMargin)),
                                elevation: MaterialStateProperty.all(10),
                                overlayColor: MaterialStateProperty.resolveWith(
                                  (states) {
                                    return states
                                            .contains(MaterialState.pressed)
                                        ? style.secondaryColor
                                        : null;
                                  },
                                ),
                                backgroundColor: MaterialStateProperty.all(
                                    style.primaryColor),
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.horizontal(
                                      left: Radius.circular(
                                          style.cardBorderRadius * 2)),
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
                //     unselectedLabelColor: style.primaryColor,
                //     overlayColor:
                //         MaterialStateProperty.all(style.primaryColor),
                //     unselectedLabelStyle: style.textMediumStyle
                //         .copyWith(fontFamily: 'Shabnam'),
                //     labelColor: Colors.white,
                //     indicator: BoxDecoration(color: style.primaryColor),
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
