import 'package:dabel_sport/controller/AnimationController.dart';
import 'package:dabel_sport/controller/SettingController.dart';
import 'package:dabel_sport/helper/styles.dart';
import 'package:dabel_sport/page/contact_us.dart';
import 'package:dabel_sport/page/menu_drawer.dart';
import 'package:dabel_sport/widget/AppBar.dart';
import 'package:dabel_sport/widget/slide_menu.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessagesPage extends StatelessWidget {
  late SettingController settingController;
  late Style styleController;
  late MyAnimationController animationController;
  GlobalKey<SideMenuState> _sideMenuKey =
      GlobalKey<SideMenuState>(debugLabel: 'sideMenuKey');

  MessagesPage({Key? key}) : super(key: key) {
    settingController = Get.find<SettingController>();
    styleController = Get.find<Style>();
    animationController = Get.find<MyAnimationController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // key: _key,
      body: Container(
        decoration: BoxDecoration(gradient: styleController.splashBackground),
        child: RefreshIndicator(
          child: SideMenu(
            key: _sideMenuKey,
            inverse: true,
            closeIcon: Icon(
              Icons.close,
              color: styleController.primaryColor,
            ),
            radius: BorderRadius.circular(styleController.cardBorderRadius),
            closeDrawer: animationController.closeDrawer,
            menu: DrawerMenu(onTap: () {
              final _state = _sideMenuKey.currentState;
              if (_state!.isOpened) {
                _state.closeSideMenu();
                animationController.closeDrawer();
              } else {
                _state.openSideMenu();
                animationController.openDrawer();
                // _animationButtonController.reverse();
              }
            }),
            background: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                  gradient: styleController.mainGradientBackground),
              child: MyAppBar(
                sideMenuKey: _sideMenuKey,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [ContactUsPage()]),
                ),
              ),
            ),
          ),
          onRefresh: () {
            settingController.update();
            return Future(() => null);
          },
        ),
      ),
    );
  }
}
