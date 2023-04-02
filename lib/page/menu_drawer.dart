import 'dart:ui';

import 'package:dabel_adl/controller/SettingController.dart';
import 'package:dabel_adl/helper/helpers.dart';
import 'package:dabel_adl/helper/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class DrawerMenu extends StatelessWidget {
  late final VoidCallback onTap;
  Style styleController = Get.find<Style>();
  late ButtonStyle buttonStyle;
  SettingController settingController = Get.find<SettingController>();

  DrawerMenu({required this.onTap}) {
    buttonStyle = ButtonStyle(
        padding: MaterialStateProperty.all(
            EdgeInsets.all(styleController.cardMargin / 2)),
        overlayColor: MaterialStateProperty.resolveWith(
          (states) {
            return states.contains(MaterialState.pressed)
                ? styleController.secondaryColor
                : null;
          },
        ),
        backgroundColor: MaterialStateProperty.all(
            styleController.secondaryColor.withOpacity(.2)),
        shape: MaterialStateProperty.all(RoundedRectangleBorder(
          side: BorderSide(color: styleController.secondaryColor),
          borderRadius: BorderRadius.all(
            Radius.circular(styleController.cardBorderRadius / 2),
          ),
        )));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration( ),
        child: Stack(
          children: [
            ListView(
              children: [
                Padding(
                  padding: EdgeInsets.all(styleController.cardMargin),
                  child: ClipRRect(
                    child: Image.asset('assets/images/icon-light.png'),
                    borderRadius:
                        BorderRadius.circular(styleController.cardBorderRadius),
                  ),
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                  child: Padding(
                    padding: EdgeInsets.all(styleController.cardMargin),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextButton.icon(
                          style: buttonStyle,
                          onPressed: () async { settingController.goTo('site');},
                          label: Text(
                            'site'.tr,
                            style: styleController.textBigStyle.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          icon: Icon(Icons.link, color: Colors.white),
                        ),
                        TextButton.icon(
                          style: buttonStyle,
                          onPressed: () async {  settingController.goTo('contact_us');},
                          label: Text(
                            'contact_us'.tr,
                            style: styleController.textBigStyle.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          icon: Icon(Icons.headset_mic_rounded, color: Colors.white),
                        ),
                        TextButton.icon(
                          style: buttonStyle,
                          onPressed: () async {
                            settingController.goTo('your_comments');
                          },
                          label: Text(
                            'your_comments'.tr,
                            style: styleController.textBigStyle.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          icon: Icon(Icons.star_border,
                              color: Colors.white),
                        ),
                        TextButton.icon(
                          style: buttonStyle,
                          onPressed: () async {
                            settingController.goTo('update');
                          },
                          label: Text(
                            'update'.tr,
                            style: styleController.textBigStyle.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          icon: Icon(Icons.download_outlined,
                              color: Colors.white),
                        ),
                        TextButton.icon(
                          style: buttonStyle,
                          onPressed: () async {
                            SystemChannels.platform
                                .invokeMethod('SystemNavigator.pop');
                          },
                          label: Text(
                            'exit'.tr,
                            style: styleController.textBigStyle.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          icon: Icon(Icons.exit_to_app, color: Colors.white),
                        ),
                        Padding(
                          padding:   EdgeInsets.only(top:styleController.cardMargin),
                          child: Text(
                            "${'label'.tr} (${'version'.tr} ${settingController.appInfo.versionName})",
                           textAlign: TextAlign.center, style: styleController.textSmallLightStyle.copyWith(
                                color: Colors.white.withOpacity(.5),

                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
