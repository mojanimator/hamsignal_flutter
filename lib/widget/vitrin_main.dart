import 'package:dabel_sport/controller/SettingController.dart';
import 'package:dabel_sport/helper/styles.dart';
import 'package:dabel_sport/page/blogs.dart';
import 'package:dabel_sport/page/clubs.dart';
import 'package:dabel_sport/page/coaches.dart';
import 'package:dabel_sport/page/conductor_page.dart';
import 'package:dabel_sport/page/players.dart';
import 'package:dabel_sport/page/shops.dart';
import 'package:dabel_sport/page/tournaments.dart';
import 'package:dabel_sport/widget/shakeanimation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainVitrin extends StatelessWidget {
  late Style styleController;
  late SettingController settingController;
  late MaterialColor colors;
  late EdgeInsets margin;

  MainVitrin({EdgeInsets? margin, MaterialColor? colors}) {
    this.margin = margin ??
        EdgeInsets.symmetric(
          vertical: styleController.cardMargin / 8,
          horizontal: styleController.cardMargin,
        );
    styleController = Get.find<Style>();
    settingController = Get.find<SettingController>();
    this.colors = colors ?? styleController.primaryMaterial;
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
    //   Future.delayed(
    //       Duration(seconds: 1),
    //       () => Get.to(ConductorPage(),
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
        color: Colors.white.withOpacity(.98),
        elevation: 20,
        margin: margin,
        child: Padding(
          padding: EdgeInsets.all(styleController.cardMargin),
          child: Column(
            children: [
              IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/player.png',
                            color: styleController.primaryColor,
                            height: styleController.iconHeight,
                          ),
                          Text('player'.tr),
                        ],
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                      ),
                      onPressed: () {
                        Get.to(PlayersPage(),
                            transition: Transition.topLevel,
                            duration: Duration(milliseconds: 400));
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
                            'assets/images/coach.png',
                            color: styleController.primaryColor,
                            height: styleController.iconHeight,
                          ),
                          Text('coach'.tr),
                        ],
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                      ),
                      onPressed: () {
                        Get.to(CoachesPage(),
                            transition: Transition.topLevel,
                            duration: Duration(milliseconds: 400));
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
                            'assets/images/club.png',
                            color: styleController.primaryColor,
                            height: styleController.iconHeight,
                          ),
                          Text('club'.tr),
                        ],
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                      ),
                      onPressed: () {
                        Get.to(ClubsPage(),
                            transition: Transition.topLevel,
                            duration: Duration(milliseconds: 400));
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
                            'assets/images/shop.png',
                            color: styleController.primaryColor,
                            height: styleController.iconHeight,
                          ),
                          Text('shop'.tr),
                        ],
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                      ),
                      onPressed: () {
                        Get.to(ShopsPage(),
                            transition: Transition.topLevel,
                            duration: Duration(milliseconds: 400));
                      },
                    ),
                  ],
                ),
              ),
              IntrinsicHeight(
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
                      onPressed: () {Get.to(BlogsPage());},
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
                    TextButton(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/table.png',
                            color: styleController.primaryColor,
                            height: styleController.iconHeight,
                          ),
                          Text('tables'.tr),
                        ],
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                      ),
                      onPressed: () {
                        Get.to(TournamentsPage());
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
