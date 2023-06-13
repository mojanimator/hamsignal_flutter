import 'package:hamsignal/controller/AnimationController.dart';
import 'package:hamsignal/controller/SettingController.dart';
import 'package:hamsignal/helper/styles.dart';
import 'package:hamsignal/page/contact_us.dart';
import 'package:hamsignal/page/menu_drawer.dart';
import 'package:hamsignal/widget/AppBar.dart';
import 'package:hamsignal/widget/slide_menu.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SupportPage extends StatelessWidget {
  late SettingController settingController;
  late Style style;
  late MyAnimationController animationController;
  GlobalKey<SideMenuState> _sideMenuKey =
      GlobalKey<SideMenuState>(debugLabel: 'sideMenuKey');

  SupportPage({Key? key}) : super(key: key) {
    settingController = Get.find<SettingController>();
    style = Get.find<Style>();
    animationController = Get.find<MyAnimationController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // key: _key,
      body: Container(
        decoration: BoxDecoration(gradient: style.splashBackground),
        child: RefreshIndicator(
          child: SideMenu(
            key: _sideMenuKey,
            inverse: true,
            closeIcon: Icon(
              Icons.close,
              color: style.primaryColor,
            ),
            radius: BorderRadius.circular(style.cardBorderRadius),
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
                  gradient: style.mainGradientBackground),
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
