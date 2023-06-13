import 'package:hamsignal/controller/SettingController.dart';
import 'package:hamsignal/controller/UserController.dart';
import 'package:hamsignal/helper/styles.dart';
import 'package:hamsignal/widget/blinkanimation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatelessWidget {
  final bool isLoading;
  late final Style style;
  late final UserController userController;

  SplashScreen({Key? key, this.isLoading = false}) : super(key: key) {
    style = Get.find<Style>();
    userController = Get.find<UserController>();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading)
      return Material(
        child: Container(
          decoration: BoxDecoration(
            gradient: style.splashBackground,
            image: DecorationImage(
                image: AssetImage("assets/images/splash.jpg"),
                repeat: ImageRepeat.repeat,
                fit: BoxFit.scaleDown,
                filterQuality: FilterQuality.medium,
                colorFilter: ColorFilter.mode(
                    style.primaryColor.withOpacity(.1),
                    BlendMode.colorBurn),
                opacity: 1),
          ),
          width: Get.width,
          padding: EdgeInsets.all(style.cardMargin),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Padding(
              //   padding:   EdgeInsets.symmetric(vertical:style.imageHeight),
              //   child: BlinkAnimation(
              //     child: Image.asset('assets/images/icon-light.png',
              //         height: style.cardVitrinHeight),
              //   ),
              // ),
              CupertinoActivityIndicator(
                color: style.secondaryColor,
              )
            ],
          ),
        ),
      );
    else
      return Material(
        child: Container(
          decoration: BoxDecoration(
            gradient: style.splashBackground,
            image: DecorationImage(
                image: AssetImage("assets/images/texture.jpg"),
                repeat: ImageRepeat.repeat,
                fit: BoxFit.scaleDown,
                filterQuality: FilterQuality.medium,
                colorFilter: ColorFilter.mode(
                    style.primaryColor.withOpacity(.1),
                    BlendMode.darken),
                opacity: .15),
          ),
          width: Get.width,
          padding: EdgeInsets.all(style.cardMargin),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/icon-dark.png',
                  height: style.cardVitrinHeight),
              SizedBox(height: style.cardMargin*2),
              Text(
                'check_network'.tr,
                style: style.textHeaderStyle.copyWith(color:style.primaryMaterial[900]!),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: style.cardMargin*2),
              TextButton(
                  onPressed: userController.getUser,
                  style: style.buttonStyle(
                      backgroundColor: style.primaryColor,
                      splashColor: style.secondaryColor),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: style.cardMargin / 2,
                      horizontal: style.cardMargin,
                    ),
                    child: Text(
                      'retry'.tr,
                      style: style.textHeaderLightStyle,
                    ),
                  ))
            ],
          ),
        ),
      );
  }
}
