import 'package:hamsignal/controller/SettingController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

class MyAnimationController extends GetxController
    with GetTickerProviderStateMixin {
  late Animation<double> animation_height_filter;

  MyAnimationController({Key? key}) {}

  late AnimationController _filterSearchHeightController;

  AnimationController get filterSearchHeightController =>
      _filterSearchHeightController;

  set filterSearchHeightController(AnimationController value) {
    _filterSearchHeightController = value;
  }

  late AnimationController _animationController;
  late AnimationController _fadeShowController;
  late AnimationController _bottomNavigationBarController;
  late AnimationController _showFieldController;
  late AnimationController fadeShowClearPhoneIconController;
  late AnimationController fadeShowClearPasswordIconController;
  late AnimationController fadeShowClearFullNameIconController;
  late AnimationController fadeShowClearInviterCodeIconController;
  late AnimationController fadeShowClearSmsCodeIconController;
  late AnimationController fadeShowClearEmailIconController;
  late AnimationController fadeShowClearUsernameIconController;
  late AnimationController fadeShowClearPasswordVerifyIconController;

  AnimationController get showFieldController => _showFieldController;

  set showFieldController(AnimationController value) {
    _showFieldController = value;
  }

  late SettingController settingController;

  get controller => _animationController;

  get bottomNavigationBarController => _bottomNavigationBarController;

  get fadeShowController => _fadeShowController;

  @override
  void onInit() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    _showFieldController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    _filterSearchHeightController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _bottomNavigationBarController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 200),
        lowerBound: 0,
        upperBound: 1);
    _bottomNavigationBarController.value = 1;
    _fadeShowController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _fadeShowController.value = 0;
    fadeShowClearPhoneIconController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    fadeShowClearPhoneIconController.value = 0;
    fadeShowClearPasswordIconController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    fadeShowClearPasswordIconController.value = 0;
    fadeShowClearInviterCodeIconController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    fadeShowClearInviterCodeIconController.value = 0;
    fadeShowClearSmsCodeIconController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    fadeShowClearSmsCodeIconController.value = 0;

    fadeShowClearFullNameIconController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    fadeShowClearFullNameIconController.value = 0;

    fadeShowClearEmailIconController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    fadeShowClearEmailIconController.value = 0;

    fadeShowClearUsernameIconController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    fadeShowClearUsernameIconController.value = 0;

    fadeShowClearPasswordVerifyIconController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    fadeShowClearPasswordVerifyIconController.value = 0;

    animation_height_filter = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
        parent: _filterSearchHeightController,
        curve: Interval(0, 1.0, curve: Curves.ease)));
    super.onInit();
  }

  void openDrawer() {
    _animationController.forward();
  }

  void closeDrawer() {
    _animationController.reverse();
  }

  void openBottomNavigationBar() {
    _bottomNavigationBarController.forward();
  }

  void closeBottomNavigationBar() {
    _bottomNavigationBarController.reverse();
  }

  void showField() {
    _showFieldController.value = 0;
    _showFieldController.forward();
  }

  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool handleScrollNotification(ScrollNotification notification) {
    if (notification.depth == 0) {
      if (notification is UserScrollNotification) {
        final UserScrollNotification userScroll = notification;

        switch (userScroll.direction) {
          case ScrollDirection.forward:
            openBottomNavigationBar();
            break;
          case ScrollDirection.reverse:
            closeBottomNavigationBar();
            break;
          case ScrollDirection.idle:
            break;
        }
      }
    }
    return false;
  }

  toggleCloseSearchIcon(int length) {
    if (length >0)
      _fadeShowController.forward();
    else if (length == 0) _fadeShowController.reverse();
  }

  toggleClearPhoneIcon(int length) {
    if (length >0)
      fadeShowClearPhoneIconController.forward();
    else if (length == 0) fadeShowClearPhoneIconController.reverse();
  }

  toggleClearFullNameIcon(int length) {
    if (length >0)
      fadeShowClearFullNameIconController.forward();
    else if (length == 0) fadeShowClearFullNameIconController.reverse();
  }

  toggleClearPasswordIcon(int length) {
    if (length >0)
      fadeShowClearPasswordIconController.forward();
    else if (length == 0) fadeShowClearPasswordIconController.reverse();
  }

  toggleClearInviterCodeIcon(int length) {
    if (length >0)
      fadeShowClearInviterCodeIconController.forward();
    else if (length == 0) fadeShowClearInviterCodeIconController.reverse();
  }

  toggleClearSmsCodeIcon(int length) {
    if (length >0)
      fadeShowClearSmsCodeIconController.forward();
    else if (length == 0) fadeShowClearSmsCodeIconController.reverse();
  }

  toggleClearEmailIcon(int length) {
    if (length >0)
      fadeShowClearEmailIconController.forward();
    else if (length == 0) fadeShowClearEmailIconController.reverse();
  }

  toggleClearUsernameIcon(int length) {
    if (length >0)
      fadeShowClearUsernameIconController.forward();
    else if (length == 0) fadeShowClearUsernameIconController.reverse();
  }

  toggleClearPasswordVerifyIcon(int length) {
    if (length >0)
      fadeShowClearUsernameIconController.forward();
    else if (length == 0) fadeShowClearUsernameIconController.reverse();
  }

  void toggleFilterSearch({bool? open}) {
    if (open != null && open == true)
      _filterSearchHeightController.forward();
    else if (open != null && open == false)
      _filterSearchHeightController.reverse();
    else if (_filterSearchHeightController.value == 0)
      _filterSearchHeightController.forward();
    else
      _filterSearchHeightController.reverse();
  }
}
