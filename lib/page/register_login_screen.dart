import 'dart:async';

import 'package:dabel_adl/controller/AnimationController.dart';
import 'package:dabel_adl/controller/SettingController.dart';
import 'package:dabel_adl/controller/UserController.dart';
import 'package:dabel_adl/helper/helpers.dart';
import 'package:dabel_adl/helper/styles.dart';
import 'package:dabel_adl/helper/variables.dart';
import 'package:dabel_adl/model/User.dart';
import 'package:dabel_adl/widget/blinkanimation.dart';
import 'package:dabel_adl/widget/loader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterLoginScreen extends StatelessWidget {
  final bool isLoading;
  final String? error;
  late final Style styleController;
  late final SettingController settingController;
  late final UserController userController = Get.find<UserController>();
  late TextEditingController textPhoneController;
  late TextEditingController textVerifyController;
  late TextEditingController textRefController;
  late TextEditingController textPasswordController;
  late TextEditingController textFullNameController;
  late TextEditingController textInviterCodeController;
  late TextEditingController textSmsCodeController;

  late MyAnimationController animationController;

  late RxString show = RxString('PHONE');
  late RxBool isLawyer = RxBool(false);
  late RxBool isAcceptedPolicy = RxBool(false);
  late Helper helper;
  late RxBool enableButton;
  late Timer _timer;
  RxInt time = 60.obs;

  late AnimationController animationTextPhoneController;
  late ButtonStyle buttonStyle;

  RegisterLoginScreen({Key? key, this.isLoading = false, String? this.error}) {
    // userController = Get.find<UserController>();
    styleController = Get.find<Style>();
    settingController = Get.find<SettingController>();
    helper = Get.find<Helper>();
    textPhoneController = TextEditingController();

    textVerifyController = TextEditingController();
    textSmsCodeController = TextEditingController();
    textRefController = TextEditingController();
    textPasswordController = TextEditingController();
    textFullNameController = TextEditingController();
    textInviterCodeController = TextEditingController();
    animationController = Get.find<MyAnimationController>();

    buttonStyle = styleController.buttonStyle(
      padding: EdgeInsets.symmetric(vertical: styleController.cardMargin),
      backgroundColor: styleController.primaryColor,
    );

    enableButton = true.obs;
    if (error != null) show.value = 'PHONE';
    animationController.showField();

    userController.addListener(() {});

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   textPhoneController.text = '09228641244';
    //   loginRegister();
    // });
  }

  @override
  Widget build(BuildContext context) {
    //error sms verify

    if (error != null)
      return Obx(
        () => Material(
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
            // width: Get.width,
            padding: EdgeInsets.all(styleController.cardMargin),
            child: FadeTransition(
              opacity: animationController.showFieldController,
              child: Center(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Image.asset('assets/images/icon-light.png',
                        height: styleController.cardVitrinHeight),

                    //phone field
                    if (show.value == 'PHONE' ||
                        show.value == 'LOGIN' ||
                        show.value == 'REGISTER')
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              styleController.cardBorderRadius * 2),
                        ),
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: ListTile(
                              contentPadding: EdgeInsets.only(
                                  left: styleController.cardMargin),
                              horizontalTitleGap: 2,
                              // contentPadding: EdgeInsets.symmetric(
                              //   horizontal: styleController.cardMargin / 4,
                              //
                              // ),
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
                                        vertical:
                                            styleController.cardMargin / 2),
                                    child: VerticalDivider(),
                                  ),
                                ],
                              ),
                              title: TextField(
                                controller: textPhoneController,
                                enabled: show.value == 'PHONE',
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.search,
                                decoration: InputDecoration(
                                    hintText: 'phone'.tr,
                                    border: InputBorder.none),
                                onSubmitted: (str) async {
                                  loginRegister();
                                },
                                // onEditingComplete: () {
                                //   controller.getData(param: {'page': 'clear'});
                                // },
                                onChanged: (str) {
                                  animationController
                                      .toggleClearPhoneIcon(str.length);
                                  toggleEnableButton(str);
                                },
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  FadeTransition(
                                    opacity: animationController
                                        .fadeShowClearPhoneIconController,
                                    child: IconButton(
                                      splashColor:
                                          styleController.secondaryColor,
                                      icon: Icon(Icons.close),
                                      onPressed: () {
                                        if (show.value != 'PHONE') return;
                                        textPhoneController.clear();
                                        animationController
                                            .toggleCloseSearchIcon(0);
                                      },
                                    ),
                                  ),
                                  if (show.value == 'LOGIN' ||
                                      show.value == 'REGISTER')
                                    TextButton(
                                        style: buttonStyle.copyWith(
                                            shape: MaterialStateProperty.all(
                                                RoundedRectangleBorder(
                                          borderRadius: BorderRadius.horizontal(
                                            right: Radius.circular(
                                                styleController
                                                    .cardBorderRadius),
                                          ),
                                        ))),
                                        onPressed: () {
                                          show.value = 'PHONE';
                                          animationController
                                              .fadeShowClearPhoneIconController
                                              .value = 1;
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal:
                                                  styleController.cardMargin),
                                          child: Text(
                                            'edit'.tr,
                                            style: styleController
                                                .textMediumLightStyle,
                                          ),
                                        ))
                                ],
                              )),
                        ),
                      ),

                    //fullname field
                    if (show.value == 'REGISTER')
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
                                  Icon(Icons.person),
                                  VerticalDivider(),
                                ],
                              ),
                              title: TextField(
                                controller: textFullNameController,
                                keyboardType: TextInputType.name,
                                textInputAction: TextInputAction.done,
                                enableSuggestions: true,
                                autocorrect: false,
                                decoration: InputDecoration(
                                    hintText: 'fullname'.tr,
                                    border: InputBorder.none),
                                onSubmitted: (str) {},
                                // onEditingComplete: () {
                                //   controller.getData(param: {'page': 'clear'});
                                // },
                                onChanged: (str) {
                                  animationController
                                      .toggleClearFullNameIcon(str.length);
                                },
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  FadeTransition(
                                    opacity: animationController
                                        .fadeShowClearFullNameIconController,
                                    child: IconButton(
                                      splashColor:
                                          styleController.secondaryColor,
                                      icon: Icon(Icons.close),
                                      onPressed: () {
                                        textFullNameController.clear();
                                        animationController
                                            .toggleClearFullNameIcon(0);
                                      },
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      ), //inviter code field

                    //password field
                    if (show.value == 'REGISTER' || show.value == 'LOGIN')
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
                                  Icon(Icons.lock),
                                  VerticalDivider(),
                                ],
                              ),
                              title: TextField(
                                controller: textPasswordController,
                                obscureText: true,
                                enableSuggestions: false,
                                autocorrect: false,
                                decoration: InputDecoration(
                                    hintText: 'password'.tr,
                                    border: InputBorder.none),
                                onSubmitted: (str) {},
                                // onEditingComplete: () {
                                //   controller.getData(param: {'page': 'clear'});
                                // },
                                onChanged: (str) {
                                  animationController
                                      .toggleClearPasswordIcon(str.length);
                                },
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  FadeTransition(
                                    opacity: animationController
                                        .fadeShowClearPasswordIconController,
                                    child: IconButton(
                                      splashColor:
                                          styleController.secondaryColor,
                                      icon: Icon(Icons.close),
                                      onPressed: () {
                                        textPasswordController.clear();
                                        animationController
                                            .toggleClearPasswordIcon(0);
                                      },
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      ),
                    //sms code field
                    if (show.value == 'REGISTER')
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
                                controller: textSmsCodeController,
                                textInputAction: TextInputAction.done,
                                autocorrect: false,
                                decoration: InputDecoration(
                                    hintText: 'sms_code'.tr,
                                    border: InputBorder.none),
                                onSubmitted: (str) {},
                                // onEditingComplete: () {
                                //   controller.getData(param: {'page': 'clear'});
                                // },
                                onChanged: (str) {
                                  animationController
                                      .toggleClearSmsCodeIcon(str.length);
                                },
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  FadeTransition(
                                    opacity: animationController
                                        .fadeShowClearSmsCodeIconController,
                                    child: IconButton(
                                      splashColor:
                                          styleController.secondaryColor,
                                      icon: Icon(Icons.close),
                                      onPressed: () {
                                        textSmsCodeController.clear();
                                        animationController
                                            .toggleClearSmsCodeIcon(0);
                                      },
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      ),
                    //inviter code field
                    if (show.value == 'REGISTER')
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
                                  Icon(Icons.person_add_alt_1),
                                  VerticalDivider(),
                                ],
                              ),
                              title: TextField(
                                controller: textInviterCodeController,
                                textInputAction: TextInputAction.done,
                                autocorrect: false,
                                decoration: InputDecoration(
                                    hintText: 'inviter_code'.tr,
                                    border: InputBorder.none),
                                onSubmitted: (str) {},
                                // onEditingComplete: () {
                                //   controller.getData(param: {'page': 'clear'});
                                // },
                                onChanged: (str) {
                                  animationController
                                      .toggleClearInviterCodeIcon(str.length);
                                },
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  FadeTransition(
                                    opacity: animationController
                                        .fadeShowClearInviterCodeIconController,
                                    child: IconButton(
                                      splashColor:
                                          styleController.secondaryColor,
                                      icon: Icon(Icons.close),
                                      onPressed: () {
                                        textInviterCodeController.clear();
                                        animationController
                                            .toggleClearInviterCodeIcon(0);
                                      },
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      ),
                    if (show.value == 'REGISTER')
                      InkWell(
                        onTap: () {
                          isLawyer.value = !isLawyer.value;
                        },
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'i_am_lawyer'.tr,
                                style: styleController.textMediumLightStyle
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              CupertinoSwitch(
                                activeColor: styleController.primaryColor,
                                trackColor: styleController.secondaryColor
                                    .withOpacity(.3),
                                value: isLawyer.value,
                                onChanged: (value) {
                                  isLawyer.value = value;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (show.value == 'REGISTER')
                      InkWell(
                        onTap: () {
                          isAcceptedPolicy.value = !isAcceptedPolicy.value;
                        },
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'i_accept_policy'.tr,
                                style: styleController.textMediumLightStyle
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              CupertinoSwitch(
                                activeColor: styleController.primaryColor,
                                trackColor: styleController.secondaryColor
                                    .withOpacity(.3),
                                value: isAcceptedPolicy.value,
                                onChanged: (value) {
                                  isAcceptedPolicy.value = value;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    //login|register  button
                    if (show.value == 'PHONE' ||
                        show.value == 'LOGIN' ||
                        show.value == 'REGISTER')
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: styleController.cardMargin),
                        child: TextButton(
                            style: buttonStyle.copyWith(
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(
                                    styleController.cardBorderRadius),
                              ),
                            ))),
                            onPressed: () {
                              loginRegister();
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: styleController.cardMargin),
                              child: Text(
                                show.value == 'REGISTER'
                                    ? 'register'.tr
                                    : 'login'.tr,
                                style: styleController.textMediumLightStyle,
                              ),
                            )),
                      ),
                    //password_recover button
                    if (show.value == 'LOGIN')
                      Obx(
                        () => Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: styleController.cardMargin / 2),
                          child: TextButton(
                              style: buttonStyle.copyWith(
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                      styleController.cardBorderRadius),
                                ),
                              ))),
                              onPressed: () {
                                if (time.value == 60) recoverPassword();
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: styleController.cardMargin),
                                child: Text(
                                  time.value != 60
                                      ? "${time.value}"
                                      : 'password_recover'.tr,
                                  style: styleController.textMediumLightStyle,
                                ),
                              )),
                        ),
                      ),
                    if (show.value == 'VERIFY')
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
                    if (show.value == 'VERIFY')
                      TextButton(
                          style: buttonStyle.copyWith(
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(styleController.cardBorderRadius),
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

                    Container(
                      margin: EdgeInsets.all(styleController.cardMargin),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            if (await canLaunchUrl(
                                Uri.parse(Variables.LINK_POLICY)))
                              launchUrl(Uri.parse(Variables.LINK_POLICY));
                          },
                          child: Text(
                            'policy'.tr,
                            textAlign: TextAlign.center,
                            style:
                                styleController.textMediumLightStyle.copyWith(
                              color: styleController.secondaryColor,
                              // shadows: [
                              //   Shadow(
                              //       color: Colors.black45,
                              //       offset: Offset(0, 2)),
                              // ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (show.value == 'LOADING') Loader(),
                  ],
                ),
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

  void preAuth() async {
    show.value = "LOADING";
    String p = getTruePhone();

    final res = await userController.preAuth(
      phone: p,
    );
    // Map<String, dynamic> res = {
    //   "status": "go_register",
    //   "message":
    //       "\u06a9\u0627\u0631\u0628\u0631 \u06af\u0631\u0627\u0645\u06cc \u0627\u0637\u0644\u0627\u0639\u0627\u062a \u0628\u0627\u0644\u0627 \u0631\u0627 \u062a\u06a9\u0645\u06cc\u0644 \u06a9\u0646\u06cc\u062f",
    //   "code": "4472"
    // };
    // print(res);
    if (res==null || res['error'] != null) {
      helper.showToast(msg: res['error'], status: 'danger');
      show.value = "PHONE";
      return;
    }
    switch (res["status"]) {
      case "go_login":
        helper.showToast(msg: res["message"]);
        show.value = "LOGIN";
        break;
      case "go_register":
        helper.showToast(msg: res["message"]);
        show.value = "REGISTER";
        break;
      case "success": //user info
        helper.showToast(msg: res["message"], status: 'success');
        show.value = "REGISTER";
        userController.ACCESS_TOKEN = res["auth_header"];

        userController.getUser(refresh: true);
        // userController.user = User(
        //   id: res["user_id"],
        //   mobile: p,
        //   fullName: res["fullname"],
        //   email: res["email"],
        //   tel: res["tel"],
        //   categories: res["categories"],
        //   isLawyer: res["is_lawyer"] != null ? res["is_lawyer"] == 1 : false,
        //   wallet: res["wallet"],
        //   avatar: res["avatar"],
        //   isLogin: true,
        //   expiredAt: res["expired_at"],
        //   dateNow: res["date_now"],
        //   token: res["auth_header"],
        //   lawyerNumber: res["lawyer_number"],
        //   lawyerMelicard: res["lawyer_melicard"],
        //   lawyerBirthday: res["lawyer_birthday"],
        //   lawyerAddress: res["lawyer_address"],
        //   lawyerSex: res["lawyer_sex"],
        //   lawyerDocument: res["lawyer_document"],
        //   cv: res["cv"],
        //   isExpert: res["is_expert"] != null ? res["is_expert"] == 1 : false,
        //   isShowLawyer: res["is_show_lawyer"] != null
        //       ? res["is_show_lawyer"] == 1
        //       : false,
        //   isVerify: res["is_verify"] != null ? res["is_verify"] == 1 : false,
        //   isBlock: res["is_block"] != null ? res["is_block"] == 1 : false,
        //   lawyerExpiredAt: res["lawyer_expired_at"],
        //   loginAt: res["login_at"],
        //   marketerCode: res["marketer_code"],
        //   cityId: res["cityId"],
        // );
        break;
    }
  }

  void sendActivationCode() async {
    show.value = "LOADING";
    String p = getTruePhone();
    bool res = await settingController.sendActivationCode(
      phone: p,
    );
    // print("sendActivationCode $p");
    // print(res);
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
    String p = getTruePhone();
    // print("loginRegister $p");
    String back = show.value;
    if (show.value == 'PHONE')
      preAuth();
    else if (show.value == 'LOGIN') {
      show.value = "LOADING";
      final res = await userController.login(
        phone: "$p",
        password: textPasswordController.text,
      );

      show.value = back;
    } else if (show.value == 'REGISTER') {
      if (!isAcceptedPolicy.value) {
        helper.showToast(msg: 'please_accept_policy'.tr, status: 'danger');
        return;
      }
      show.value = "LOADING";
      final res = await userController.register(
        phone: "$p",
        code: textSmsCodeController.text,
        fullname: textFullNameController.text,
        password: textPasswordController.text,
        inviter: textInviterCodeController.text,
        isLawyer: isLawyer.value,
      );
      print(res);
      show.value = back;
    }
    // show.value = 'VERIFY';
    // print(res);
  }

  void recoverPassword() async {
    var before = show.value;
    show.value = "LOADING";
    final res = await userController.recoverPassword(
      phone: getTruePhone(),
    );
    if (res["status"] == 'success') {
      helper.showToast(msg: res["message"], status: 'success');
      startTimer();
    } else if (res["message"] != null)
      helper.showToast(msg: res["message"], status: 'danger');
    show.value = before;
  }

  String getTruePhone() {
    String p = textPhoneController.text;
    if (p.length == 10)
      p = "0$p";
    else if (p.length == 9) p = "09$p";
    return p;
  }
}
