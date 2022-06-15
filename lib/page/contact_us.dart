import 'package:dabel_sport/controller/SettingController.dart';
import 'package:dabel_sport/helper/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class ContactUsPage extends StatelessWidget {
  late Style styleController;
  late SettingController settingController;

  ContactUsPage() {
    styleController = Get.find<Style>();
    settingController = Get.find<SettingController>();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => Get.back(),
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
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    TextButton(
                      style: styleController.buttonStyle(Colors.orange),
                      onPressed: () async {
                        settingController.goTo('site');
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.link, color: Colors.white),
                          SizedBox(
                            width: styleController.cardMargin,
                          ),
                          Text(
                            'site'.tr,
                            style: styleController.textMediumStyle.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      style: styleController.buttonStyle(Colors.teal),
                      onPressed: () async {
                        settingController.goTo('whatsapp');
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.whatsapp_outlined, color: Colors.white),
                          SizedBox(
                            width: styleController.cardMargin,
                          ),
                          Text(
                            'whatsapp'.tr,
                            style: styleController.textMediumStyle.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      style: styleController.buttonStyle(Colors.pink),
                      onPressed: () async {
                        settingController.goTo('instagram');
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo_camera_outlined,
                              color: Colors.white),
                          SizedBox(
                            width: styleController.cardMargin,
                          ),
                          Text(
                            'instagram'.tr,
                            style: styleController.textMediumStyle.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      style: styleController.buttonStyle(Colors.blue),
                      onPressed: () async {
                        settingController.goTo('telegram');
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.telegram_outlined, color: Colors.white),
                          SizedBox(
                            width: styleController.cardMargin,
                          ),
                          Text(
                            'telegram'.tr,
                            style: styleController.textMediumStyle.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      style: styleController.buttonStyle(Colors.red),
                      onPressed: () async {
                        settingController.goTo('email');
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.email_outlined, color: Colors.white),
                          SizedBox(
                            width: styleController.cardMargin,
                          ),
                          Text(
                            'email'.tr,
                            style: styleController.textMediumStyle.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
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
