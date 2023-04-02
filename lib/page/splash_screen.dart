import 'package:dabel_adl/controller/SettingController.dart';
import 'package:dabel_adl/helper/styles.dart';
import 'package:dabel_adl/widget/blinkanimation.dart';
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
          decoration: BoxDecoration(
            gradient: styleController.splashBackground,
            image: DecorationImage(
                image: AssetImage("assets/images/texture.jpg"),
                repeat: ImageRepeat.repeat,
                fit: BoxFit.scaleDown,
                filterQuality: FilterQuality.medium,
                colorFilter: ColorFilter.mode(
                    styleController.primaryColor.withOpacity(.4),
                    BlendMode.colorBurn),
                opacity: .03),
          ),
          width: Get.width,
          padding: EdgeInsets.all(styleController.cardMargin),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BlinkAnimation(
                child: Image.asset('assets/images/icon-light.png',
                    height: styleController.cardVitrinHeight),
              ),
              CupertinoActivityIndicator(
                color: styleController.secondaryColor,
              )
            ],
          ),
        ),
      );
    else
      return Material(
        child: Container(
          decoration: BoxDecoration(
            gradient: styleController.splashBackground,
            image: DecorationImage(
                image: AssetImage("assets/images/texture.jpg"),
                repeat: ImageRepeat.repeat,
                fit: BoxFit.scaleDown,
                filterQuality: FilterQuality.medium,
                colorFilter: ColorFilter.mode(
                    styleController.primaryColor.withOpacity(.4),
                    BlendMode.colorBurn),
                opacity: .03),
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
                textAlign: TextAlign.center,
              ),
              SizedBox(height: styleController.cardMargin),
              TextButton(
                  onPressed: settingController.getData,
                  style: styleController.buttonStyle(
                      backgroundColor: styleController.primaryColor,
                      splashColor: styleController.secondaryColor),
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
