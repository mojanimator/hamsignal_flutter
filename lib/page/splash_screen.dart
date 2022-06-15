import 'package:dabel_sport/controller/SettingController.dart';
import 'package:dabel_sport/helper/styles.dart';
import 'package:dabel_sport/widget/blinkanimation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatelessWidget {
  final bool isLoading;
  late final Style styleController;
  late final SettingController settingController;

  SplashScreen({Key? key, this.isLoading = false}) : super(key: key) {
    styleController = Get.find<Style>();
    settingController = Get.find<SettingController>();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading)
      return Material(
        child: Container(
          decoration: BoxDecoration(gradient: styleController.splashBackground),
          width: Get.width,
          padding: EdgeInsets.all(styleController.cardMargin),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BlinkAnimation(
                child: Image.asset('assets/images/icon-light.png',
                    height: styleController.cardVitrinHeight),
              ),
              CupertinoActivityIndicator()
            ],
          ),
        ),
      );
    else
      return Material(
        child: Container(
          decoration: BoxDecoration(
            gradient: styleController.splashBackground,
          ),
          width: Get.width,
          padding: EdgeInsets.all(styleController.cardMargin),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/icon-light.png',
                  height: styleController.cardVitrinHeight),
              Text(
                'check_network'.tr,
                style: styleController.textHeaderLightStyle,
              ),
              SizedBox(height: styleController.cardMargin),
              TextButton(
                  onPressed: settingController.getData,
                  style: styleController.buttonStyle(styleController.primaryColor),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: styleController.cardMargin / 2,
                      horizontal: styleController.cardMargin,
                    ),
                    child: Text(
                      'retry'.tr,
                      style: styleController.textHeaderLightStyle,
                    ),
                  ))
            ],
          ),
        ),
      );
  }
}
