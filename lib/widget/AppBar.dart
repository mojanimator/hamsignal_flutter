import 'package:dabel_sport/controller/AnimationController.dart';
import 'package:dabel_sport/helper/styles.dart';
import 'package:dabel_sport/widget/slide_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

class MyAppBar extends StatefulWidget {
  late final Style styleController;
  late final Widget child;
  final GlobalKey<SideMenuState> sideMenuKey;

  late MyAnimationController animationController;

  MyAppBar({Key? key, required Widget this.child,  required this.sideMenuKey}) {
    animationController = Get.find<MyAnimationController>();
    styleController = Get.find<Style>();
  }

  @override
  State<MyAppBar> createState() => _AppBarState();
}

class _AppBarState extends State<MyAppBar>
    with
        TickerProviderStateMixin,
        KeepAliveParentDataMixin,
        AutomaticKeepAliveClientMixin {
  bool isOpen = false;
  late final Style styleController;

  @override
  void dispose() async {
    // print('dispose');
    super.dispose();
  }

  @override
  void initState() {
    isOpen = false;
    // print('init');
    styleController = widget.styleController;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: styleController.cardVitrinHeight,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: styleController.primaryColor.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 10,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
                borderRadius: BorderRadius.vertical(
                    bottom:
                        Radius.circular(styleController.cardBorderRadius * 4)),
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      styleController.primaryMaterial[700]!,
                      styleController.primaryMaterial[500]!
                    ]),
              ),
              child: Container(
                padding: EdgeInsets.all(styleController.cardMargin),
              ),
            ),
            Center()
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(styleController.cardMargin),
              child: SafeArea(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  // textDirection: TextDirection.ltr,
                  children: [
                    IconButton(
                      splashColor: Colors.white,
                      icon: AnimatedIcon(
                        size: widget.styleController.iconHeight,
                        color: Colors.white,
                        progress: widget.animationController.controller,
                        icon: AnimatedIcons.menu_arrow,
                      ),
                      onPressed: () async {
                        final _state = widget.sideMenuKey.currentState;
                        if (_state!.isOpened) {
                          _state.closeSideMenu();
                          widget.animationController.closeDrawer();
                        } else {
                          _state.openSideMenu();
                          widget.animationController.openDrawer();
                        }
                      },
                    ),
                    Text(
                      'label'.tr,
                      style: widget.styleController.textBigLightStyle,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Center()
          ],
        ),
        Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: styleController.iconHeight * 2,
            child: widget.child),
      ],
    );
  }

  @override
  void detach() {
    // TODO: implement detach
  }

  @override
  // TODO: implement keptAlive
  bool get keptAlive => true;

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
