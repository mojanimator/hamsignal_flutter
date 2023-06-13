import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/AnimationController.dart';
import '../controller/SettingController.dart';
import '../helper/styles.dart';
import '../widget/AppBar.dart';
import '../widget/slide_menu.dart';
import 'menu_drawer.dart';

class TutorialsPage extends StatelessWidget {
  GlobalKey<SideMenuState> _sideMenuKey =
      GlobalKey<SideMenuState>(debugLabel: 'sideMenuKey');
  late SettingController settingController;
  late MyAnimationController animationController;
  late Style style;

  TutorialsPage() {
    settingController = Get.find<SettingController>();
    style = Get.find<Style>();
    animationController = Get.find<MyAnimationController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: RefreshIndicator(
            onRefresh: () {
              settingController.update();
              return Future(() => null);
            },
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
                      gradient: style.mainGradientBackground,
                      image: DecorationImage(
                          image: AssetImage("assets/images/texture.jpg"),
                          repeat: ImageRepeat.repeat,
                          fit: BoxFit.scaleDown,
                          filterQuality: FilterQuality.medium,
                          colorFilter: ColorFilter.mode(
                              style.secondaryColor.withOpacity(.2),
                              BlendMode.colorBurn),
                          opacity: .05),
                    ),
                    child: MyAppBar(
                      sideMenuKey: _sideMenuKey,
                      child: Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: style.cardMargin),
                            ),
                          ),
                        ],
                      ),
                    )))));
  }
}
