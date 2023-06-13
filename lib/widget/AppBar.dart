import 'package:hamsignal/controller/AnimationController.dart';
import 'package:hamsignal/helper/styles.dart';
import 'package:hamsignal/widget/slide_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

class MyAppBar extends StatefulWidget {
  late final Style style;
  late final Widget child;
  final GlobalKey<SideMenuState> sideMenuKey;

  late MyAnimationController animationController;

  MyAppBar({Key? key, required Widget this.child, required this.sideMenuKey}) {
    animationController = Get.find<MyAnimationController>();
    style = Get.find<Style>();
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
  late final Style style;

  @override
  void dispose() async {
    // print('dispose');
    super.dispose();
  }

  @override
  void initState() {
    isOpen = false;
    // print('init');
    style = widget.style;

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
              height: style.cardVitrinHeight,

              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/texture.jpg"),
                    repeat: ImageRepeat.repeat,
                    fit: BoxFit.scaleDown,
                    filterQuality: FilterQuality.medium,
                    colorFilter: ColorFilter.mode(
                        style.primaryColor.withOpacity(.1), BlendMode.darken),
                    opacity: .1),
                boxShadow: [
                  BoxShadow(
                    color: style.primaryColor.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 10,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
                borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(style.cardBorderRadius * 4)),
                gradient: style.mainGradientBackground,
              ),
              child: Container(
                padding: EdgeInsets.all(style.cardMargin),
              ),
            ),
            Center()
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(style.cardMargin),
              child: SafeArea(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  // textDirection: TextDirection.ltr,
                  children: [
                    IconButton(
                      splashColor: Colors.white,
                      icon: AnimatedIcon(
                        size: widget.style.iconHeight,
                        color: widget.style.secondaryColor,
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
                      style: widget.style.textBigLightStyle,
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
            top: style.iconHeight * 2,
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
