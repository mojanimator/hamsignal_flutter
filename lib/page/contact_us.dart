import 'package:dabel_adl/controller/SettingController.dart';
import 'package:dabel_adl/controller/UserController.dart';
import 'package:dabel_adl/helper/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../controller/AnimationController.dart';
import '../widget/my_text_field.dart';

class ContactUsPage extends StatelessWidget {
  late Style styleController;
  late SettingController settingController;

  late List questions;

  TextEditingController textNameCtrl = TextEditingController();
  TextEditingController textPhoneCtrl = TextEditingController();
  TextEditingController textTitleCtrl = TextEditingController();
  TextEditingController textTextCtrl = TextEditingController();
  MyAnimationController animationController = Get.find<MyAnimationController>();
  UserController userController = Get.find<UserController>();
  RxBool loading = RxBool(false);

  ContactUsPage() {
    styleController = Get.find<Style>();
    settingController = Get.find<SettingController>();
    settingController.appInfo.questions.forEach((e) {
      e['visible'] = RxBool(false);
    });
    questions = settingController.appInfo.questions;

    textNameCtrl.text = userController.user?.fullName ?? '';
    textPhoneCtrl.text =
        userController.user?.mobile ?? userController.user?.tel ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: Card(
            elevation: 5,
            margin: EdgeInsets.all(styleController.cardMargin),
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(styleController.cardBorderRadius)),
            child: Padding(
              padding: EdgeInsets.all(styleController.cardMargin),
              child: Obx(
                () => ListView(
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(styleController.cardMargin / 2),
                      child: Text(
                        'read_before_send'.tr,
                        style: styleController.textMediumStyle,
                      ),
                    ),
                    ...settingController.appInfo.questions
                        .map<Widget>((e) => Padding(
                              padding: EdgeInsets.all(
                                  styleController.cardMargin / 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextButton.icon(
                                    icon: Icon(
                                      Icons.circle,
                                      color: styleController.secondaryColor,
                                    ),
                                    label: Text(
                                      e['q'],
                                      style: styleController
                                          .textMediumLightStyle
                                          .copyWith(
                                              color: styleController
                                                  .secondaryColor),
                                    ),
                                    onPressed: () {
                                      e['visible'].value = !e['visible'].value;
                                    },
                                    style: styleController.buttonStyle(
                                        radius: BorderRadius.vertical(
                                            bottom: Radius.circular(
                                                styleController.cardMargin / 2),
                                            top: Radius.circular(
                                                styleController.cardMargin)),
                                        splashColor: styleController
                                            .primaryMaterial[600]),
                                  ),
                                  Visibility(
                                    visible: e['visible'].value,
                                    child: Container(
                                      padding: EdgeInsets.all(
                                          styleController.cardMargin),
                                      decoration: BoxDecoration(
                                          color: styleController.secondaryColor,
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(
                                                  styleController.cardMargin /
                                                      2),
                                              bottom: Radius.circular(
                                                  styleController.cardMargin))),
                                      child: Text(
                                        e['a'],
                                        style: styleController.textMediumStyle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                    // contact form
                    Container(
                      margin: EdgeInsets.all(styleController.cardMargin / 4),
                      padding: EdgeInsets.all(styleController.cardMargin),
                      decoration: BoxDecoration(
                        color: styleController.primaryColor,
                        borderRadius: BorderRadius.all(
                            Radius.circular(styleController.cardMargin)),
                      ),
                      child: Column(
                        children: [
                          //name field
                          MyTextField(
                              borderRadius: BorderRadius.all(Radius.circular(
                                  styleController.cardMargin / 2)),
                              margin: EdgeInsets.symmetric(
                                  vertical: styleController.cardMargin / 4),
                              controller: textNameCtrl,
                              hintText: 'name'.tr,
                              icon: Icons.person,
                              keyboardType: TextInputType.number),
                          //phone field
                          MyTextField(
                              margin: EdgeInsets.symmetric(
                                  vertical: styleController.cardMargin / 4),
                              controller: textPhoneCtrl,
                              hintText: 'phone'.tr,
                              icon: Icons.phone,
                              keyboardType: TextInputType.number),
                          //title field
                          MyTextField(
                              margin: EdgeInsets.symmetric(
                                  vertical: styleController.cardMargin / 4),
                              controller: textTitleCtrl,
                              hintText: 'title'.tr,
                              icon: Icons.textsms,
                              keyboardType: TextInputType.text),
                          //message field
                          MyTextField(
                              margin: EdgeInsets.symmetric(
                                  vertical: styleController.cardMargin / 4),
                              controller: textTextCtrl,
                              minLines: 3,
                              hintText: 'message'.tr,
                              icon: Icons.message,
                              keyboardType: TextInputType.multiline),
                          if (!loading.value)
                            TextButton.icon(
                              icon: Icon(
                                Icons.arrow_forward_ios,
                                textDirection: TextDirection.ltr,
                                color: styleController.secondaryColor,
                              ),
                              label: Center(
                                child: Text(
                                  'send'.tr,
                                  style: styleController.textBigStyle.copyWith(
                                      color: styleController.secondaryColor),
                                ),
                              ),
                              onPressed: () async {
                                loading.value = true;
                                bool res =
                                    await userController.sendContact(params: {
                                  'fullname': textNameCtrl.text,
                                  'mobile': textPhoneCtrl.text,
                                  'title': textTitleCtrl.text,
                                  'text': textTextCtrl.text,
                                });
                                loading.value = false;
                                if (res) {
                                  textNameCtrl.clear();
                                  textPhoneCtrl.clear();
                                  textTitleCtrl.clear();
                                  textTextCtrl.clear();
                                }
                              },
                              style: styleController.buttonStyle(
                                  radius: BorderRadius.vertical(
                                      bottom: Radius.circular(
                                          styleController.cardMargin / 2),
                                      top: Radius.circular(
                                          styleController.cardMargin)),
                                  splashColor: styleController.secondaryColor),
                            ),
                          if (loading.value)
                            CupertinoActivityIndicator(
                              color: styleController.secondaryColor,
                            )
                        ],
                      ),
                    ),
                    Padding(
                      padding:   EdgeInsets.symmetric(vertical:  styleController.cardMargin,horizontal: styleController.cardMargin/4 ),
                      child: Wrap(

                        spacing: styleController.cardMargin/2,
                        runSpacing: styleController.cardMargin/2,
                        children: [
                          Container(

                            child: TextButton.icon(
                              style: styleController.buttonStyle(
                                  backgroundColor: Colors.orange,
                                  radius: BorderRadius.circular(
                                      styleController.cardMargin / 2)),
                              onPressed: () async {
                                settingController.goTo('site');
                              },
                              icon: Icon(Icons.link, color: Colors.white),
                              label: Text(
                                'site'.tr,
                                style: styleController.textMediumStyle.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Container(

                            child: TextButton.icon(
                              style: styleController.buttonStyle(
                                  backgroundColor: Colors.teal,
                                  radius: BorderRadius.circular(
                                      styleController.cardMargin / 2)),
                              onPressed: () async {
                                settingController.goTo('whatsapp');
                              },
                              icon: Icon(Icons.perm_phone_msg_rounded,
                                  color: Colors.white),
                              label: Text(
                                'whatsapp'.tr,
                                style: styleController.textMediumStyle.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Container(

                            child: TextButton.icon(
                              style: styleController.buttonStyle(
                                  backgroundColor: Colors.pink,
                                  radius: BorderRadius.circular(
                                      styleController.cardMargin / 2)),
                              onPressed: () async {
                                settingController.goTo('instagram');
                              },
                              icon: Icon(Icons.photo_camera_outlined,
                                  color: Colors.white),
                              label: Text(
                                'instagram'.tr,
                                style: styleController.textMediumStyle.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Container(

                            child: TextButton.icon(
                              style: styleController.buttonStyle(
                                  backgroundColor: Colors.blue,
                                  radius: BorderRadius.circular(
                                      styleController.cardMargin / 2)),
                              onPressed: () async {
                                settingController.goTo('telegram');
                              },
                              icon: Icon(Icons.telegram_outlined,
                                  color: Colors.white),
                              label: Text(
                                'telegram'.tr,
                                style: styleController.textMediumStyle.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Container(

                            child: TextButton.icon(
                              style: styleController.buttonStyle(
                                  backgroundColor: Colors.red,
                                  radius: BorderRadius.circular(
                                      styleController.cardMargin / 2)),
                              onPressed: () async {
                                settingController.goTo('email');
                              },
                              icon:
                                  Icon(Icons.email_outlined, color: Colors.white),
                              label: Text(
                                'email'.tr,
                                style: styleController.textMediumStyle.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
