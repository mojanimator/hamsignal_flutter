import 'dart:async';

import 'package:dabel_sport/controller/AnimationController.dart';
import 'package:dabel_sport/controller/SettingController.dart';
import 'package:dabel_sport/controller/UserController.dart';
import 'package:dabel_sport/helper/helpers.dart';
import 'package:dabel_sport/helper/styles.dart';
import 'package:dabel_sport/widget/loader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterLoginScreen extends StatelessWidget {
  final bool isLoading;
  final String? error;
  late final Style styleController;
  late final SettingController settingController;
  late final UserController userController = Get.find<UserController>();
  late TextEditingController textPhoneController;
  late TextEditingController textVerifyController;
  late TextEditingController textRefController;
  late MyAnimationController animationController;
  late RxString show = RxString('PHONE');
  late Helper helper;
  late RxBool enableButton;
  late Timer _timer;
  RxInt time = 60.obs;

  RegisterLoginScreen({Key? key, this.isLoading = false, String? this.error}) {
    // userController = Get.find<UserController>();
    styleController = Get.find<Style>();
    settingController = Get.find<SettingController>();
    helper = Get.find<Helper>();
    textPhoneController = TextEditingController();
    textVerifyController = TextEditingController();
    textRefController = TextEditingController();
    animationController = Get.find<MyAnimationController>();
    enableButton = true.obs;
    if (error != null) show.value = 'PHONE';
    animationController.showField();

    userController.addListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    //error sms verify

    if (error != null)
      return Obx(
            () =>
            Material(
              child: Container(
                decoration:
                BoxDecoration(gradient: styleController.splashBackground),
                // width: Get.width,
                padding: EdgeInsets.all(styleController.cardMargin),
                child: FadeTransition(
                  opacity: animationController.showFieldController,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (show == 'PHONE')
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                styleController.cardBorderRadius * 2),
                          ),
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: ListTile(
                                leading: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '09',
                                      style: styleController.textHeaderStyle
                                          .copyWith(
                                          color: styleController.primaryColor
                                              .withOpacity(.8)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: styleController.cardMargin /
                                              2),
                                      child: VerticalDivider(),
                                    ),
                                  ],
                                ),
                                title: TextField(
                                  controller: textPhoneController,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.search,
                                  decoration: InputDecoration(
                                      hintText: 'phone'.tr,
                                      border: InputBorder.none),
                                  onSubmitted: (str) async {
                                    sendActivationCode();
                                  },
                                  // onEditingComplete: () {
                                  //   controller.getData(param: {'page': 'clear'});
                                  // },
                                  onChanged: (str) {
                                    animationController
                                        .toggleCloseSearchIcon(str.length);
                                    toggleEnableButton(str);
                                  },
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    FadeTransition(
                                      opacity:
                                      animationController.fadeShowController,
                                      child: IconButton(
                                        splashColor: styleController
                                            .secondaryColor,
                                        icon: Icon(Icons.close),
                                        onPressed: () {
                                          textPhoneController.clear();

                                          animationController
                                              .toggleCloseSearchIcon(0);
                                        },
                                      ),
                                    ),
                                    TextButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                            MaterialStateProperty.resolveWith(
                                                  (states) {
                                                return states.contains(
                                                    MaterialState.disabled)
                                                    ? styleController
                                                    .primaryColor
                                                    .withOpacity(.4)
                                                    : styleController
                                                    .primaryColor;
                                              },
                                            ),
                                            overlayColor:
                                            MaterialStateProperty.resolveWith(
                                                  (states) {
                                                return states.contains(
                                                    MaterialState.pressed)
                                                    ? styleController
                                                    .secondaryColor
                                                    : null;
                                              },
                                            ),
                                            shape: MaterialStateProperty.all(
                                                RoundedRectangleBorder(
                                                  borderRadius: BorderRadius
                                                      .horizontal(
                                                    right: Radius.circular(
                                                        styleController
                                                            .cardBorderRadius),
                                                    left: Radius.circular(
                                                        styleController
                                                            .cardBorderRadius /
                                                            4),
                                                  ),
                                                ))),
                                        onPressed: enableButton.value
                                            ? () {
                                          sendActivationCode();
                                        }
                                            : null,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal:
                                              styleController.cardMargin),
                                          child: Text(
                                            "${time.value != 60 ? '(${time
                                                .value})' : ''} ${'receive_code'
                                                .tr}",
                                            style: styleController
                                                .textMediumLightStyle,
                                          ),
                                        )),
                                  ],
                                )),
                          ),
                        ),
                      if (show == 'PHONE')
                        TextButton(
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            styleController.cardBorderRadius),
                                      ),
                                    ))),
                            onPressed: null,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: styleController.cardMargin),
                              child: Text(
                                '',
                                style: styleController.textMediumLightStyle,
                              ),
                            )),
                      if (show == 'VERIFY')
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                styleController.cardBorderRadius * 2),
                          ),
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: ListTile(
                                leading: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.sms),
                                    VerticalDivider(),
                                  ],
                                ),
                                title: TextField(
                                  controller: textVerifyController,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.search,
                                  decoration: InputDecoration(
                                      hintText: 'phone_verify'.tr,
                                      border: InputBorder.none),
                                  onSubmitted: (str) {},
                                  // onEditingComplete: () {
                                  //   controller.getData(param: {'page': 'clear'});
                                  // },
                                  onChanged: (str) {
                                    if (str.length == 5) loginRegister();
                                  },
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    FadeTransition(
                                      opacity:
                                      animationController.fadeShowController,
                                      child: IconButton(
                                        splashColor: styleController
                                            .secondaryColor,
                                        icon: Icon(Icons.close),
                                        onPressed: () {
                                          textVerifyController.clear();

                                          animationController
                                              .toggleCloseSearchIcon(0);
                                        },
                                      ),
                                    ),
                                    TextButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                            MaterialStateProperty.resolveWith(
                                                  (states) {
                                                return states.contains(
                                                    MaterialState.disabled)
                                                    ? styleController
                                                    .primaryColor
                                                    .withOpacity(.4)
                                                    : styleController
                                                    .primaryColor;
                                              },
                                            ),
                                            overlayColor:
                                            MaterialStateProperty.resolveWith(
                                                  (states) {
                                                return states.contains(
                                                    MaterialState.pressed)
                                                    ? styleController
                                                    .secondaryColor
                                                    : null;
                                              },
                                            ),
                                            shape: MaterialStateProperty.all(
                                                RoundedRectangleBorder(
                                                  borderRadius: BorderRadius
                                                      .horizontal(
                                                    right: Radius.circular(
                                                        styleController
                                                            .cardBorderRadius),
                                                  ),
                                                ))),
                                        onPressed: () {
                                          loginRegister();
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal:
                                              styleController.cardMargin),
                                          child: Text(
                                            'verify'.tr,
                                            style: styleController
                                                .textMediumLightStyle,
                                          ),
                                        )),
                                  ],
                                )),
                          ),
                        ),
                      if (show == 'VERIFY')
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                styleController.cardBorderRadius * 2),
                          ),
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: ListTile(
                                leading: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.group),
                                    VerticalDivider(),
                                  ],
                                ),
                                title: TextField(
                                  controller: textRefController,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.search,
                                  decoration: InputDecoration(
                                      hintText:
                                      "${'ref_code'.tr} (${'optional'.tr})",
                                      border: InputBorder.none),
                                  onSubmitted: (str) {},
                                  // onEditingComplete: () {
                                  //   controller.getData(param: {'page': 'clear'});
                                  // },
                                  onChanged: (str) {},
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [],
                                )),
                          ),
                        ),
                      if (show == 'VERIFY')
                        TextButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty
                                    .resolveWith(
                                      (states) {
                                    return states.contains(
                                        MaterialState.disabled)
                                        ? styleController.primaryColor
                                        .withOpacity(.4)
                                        : styleController.primaryColor;
                                  },
                                ),
                                overlayColor: MaterialStateProperty.resolveWith(
                                      (states) {
                                    return states.contains(
                                        MaterialState.pressed)
                                        ? styleController.secondaryColor
                                        : null;
                                  },
                                ),
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            styleController.cardBorderRadius),
                                      ),
                                    ))),
                            onPressed: () {
                              show.value = 'PHONE';
                              animationController.showField();
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: styleController.cardMargin),
                              child: Text(
                                'edit_phone'.tr,
                                style: styleController.textMediumLightStyle,
                              ),
                            )),
                      if (show == 'LOADING') Loader(),
                    ],
                  ),
                ),
              ),
            ),
      );
    return Center();
  }

  void toggleEnableButton(String str) {
    if (str.length >= 9 && time.value == 60) {
      enableButton.value = true;
    } else
      enableButton.value = false;
  }

  void sendActivationCode() async {
    show.value = "LOADING";
    String p = textPhoneController.text;
    if (p.length == 10)
      p = "0$p";
    else if (p.length == 9) p = "09$p";
    bool res = await settingController.sendActivationCode(
      phone: p,
    );
    if (res == true) {
      enableButton.value = false;
      startTimer();
      show.value = 'VERIFY';
      animationController.toggleCloseSearchIcon(0);
    } else
      show.value = "PHONE";
    animationController.showField();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (time.value <= 0) {
        timer.cancel();
        enableButton.value = true;
        time.value = 60;
      } else {
        time.value--;
      }
    });
  }

  void loginRegister() async {
    show.value = "LOADING";
    String p = textPhoneController.text;
    if (p.length == 10)
      p = "0$p";
    else if (p.length == 9) p = "09$p";
    await userController.loginOrRegister(
        phone: "$p",
        code: textVerifyController.text,
        ref_code: textRefController.text);
    show.value = 'VERIFY';
    // print(res);
  }
}
