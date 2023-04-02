import 'package:dabel_adl/controller/SettingController.dart';
import 'package:dabel_adl/helper/styles.dart';
import 'package:dabel_adl/widget/bounce.dart';
import 'package:dabel_adl/widget/shakeanimation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../page/Contents.dart';

class BannerCard extends StatelessWidget {
  late Style styleController;
  late SettingController settingController;
  late MaterialColor colors;
  late EdgeInsets margin;
  late List<dynamic> data;
    Color? titleColor;
  final icon;
  final title;
  final onClick;
  final background;

  BannerCard(
      {EdgeInsets? margin,
      MaterialColor? colors,
      required this.background,
      required this.title,
      required this.icon,
      this.onClick,   Color? this.titleColor}) {
    styleController = Get.find<Style>();
    settingController = Get.find<SettingController>();
    this.margin = margin ??
        EdgeInsets.symmetric(
          vertical: styleController.cardMargin / 8,
          horizontal: styleController.cardMargin,
        );
    this.colors = colors ?? styleController.primaryMaterial;

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
    return MyBounce(
      onTap: onClick,
      child: ShakeWidget(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(styleController.cardBorderRadius),
          ),
          shadowColor: styleController.primaryColor.withOpacity(.3),
          color: styleController.theme3,
          elevation: 20,
          margin: margin,
          child: Container(
            padding: EdgeInsets.all(styleController.cardMargin),
            decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(styleController.cardBorderRadius),
                image: DecorationImage(
                    image: AssetImage("assets/images/$background"),
                    fit: BoxFit.cover)),
            child: IntrinsicHeight(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    "$icon".startsWith('http')
                        ? Image.network(
                            "$icon",
                            fit: BoxFit.contain,
                      width: styleController.imageHeight * 2 / 3,
                      height: styleController.imageHeight * 2 / 3,
                          )
                        : Image.asset("assets/images/$icon",
                            width: styleController.imageHeight * 2 / 3,
                            height: styleController.imageHeight * 2 / 3,
                            fit: BoxFit.contain),
                    Expanded(
                        child: Center(
                            child: Text(
                      title,
                      style: styleController.textMediumLightStyle
                          .copyWith(fontWeight: FontWeight.bold,color: titleColor??Colors.white),
                      textAlign: TextAlign.center,
                    ))),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
