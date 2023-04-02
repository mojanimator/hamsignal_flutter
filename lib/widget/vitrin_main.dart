import 'package:dabel_adl/controller/SettingController.dart';
import 'package:dabel_adl/helper/styles.dart';
import 'package:dabel_adl/widget/shakeanimation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../page/Contents.dart';

class MainVitrin extends StatelessWidget {
  late Style styleController;
  late SettingController settingController;
  late MaterialColor colors;
  late EdgeInsets margin;
  late List<dynamic> data;

  MainVitrin({EdgeInsets? margin, MaterialColor? colors}) {
    styleController = Get.find<Style>();
    settingController = Get.find<SettingController>();
    this.margin = margin ??
        EdgeInsets.symmetric(
          vertical: styleController.cardMargin / 8,
          horizontal: styleController.cardMargin,
        );
    this.colors = colors ?? styleController.primaryMaterial;
    data = [
      {'title': 'قوانین'},
      {'title': 'دادخواست/لایحه'},
      {'title': 'جستجو وکیل'},
      {'title': 'قرارداد'},
      {'title': 'جستجو کارشناس'},
      {'title': 'اخبار حقوقی'},
      {'title': 'دفاتر قضایی'},
      {'title': 'کنوانسیون ها'},
      {'title': 'نظریات مشورتی/آرای وحدت رویه'},
    ];
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
    //   Future.delayed(
    //       Duration(seconds: 1),
    //       () => Get.to(PlayerCreate(),
    //           transition: Transition.circularReveal,
    //           duration: Duration(milliseconds: 500)));
    //   //   var data=await LatestController().find({'id':'20','type':'cl'});
    //   // Get.to(ClubDetails(data: data, colors: styleController.cardClubColors));
    // });
  }

  @override
  Widget build(BuildContext context) {
    return ShakeWidget(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(styleController.cardBorderRadius),
        ),
        shadowColor: styleController.primaryColor.withOpacity(.3),
        color: styleController.theme3,
        elevation: 20,
        margin: margin,
        child: Padding(
          padding: EdgeInsets.all(styleController.cardMargin),
          child: Column(
            children: [
              IntrinsicHeight(
                child: FittedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const VerticalDivider(
                        endIndent: 15,
                        indent: 15,
                      ),
                    ],
                  ),
                ),
              ),
              IntrinsicHeight(
                child: FittedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/blog.png',
                              color: styleController.primaryColor,
                              height: styleController.iconHeight,
                            ),
                            Text('blogs'.tr),
                          ],
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                        ),
                        onPressed: () {
                          Get.to(ContentsPage());
                        },
                      ),
                      const VerticalDivider(
                        endIndent: 15,
                        indent: 15,
                      ),
                      TextButton(
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/conductor.png',
                              color: styleController.primaryColor,
                              height: styleController.iconHeight,
                            ),
                            Text('conductor'.tr),
                          ],
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                        ),
                        onPressed: () {
                          settingController.currentPageIndex = 1;
                        },
                      ),
                      const VerticalDivider(
                        endIndent: 15,
                        indent: 15,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
