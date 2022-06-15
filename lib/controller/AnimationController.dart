import 'package:dabel_sport/controller/SettingController.dart';
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
    if (length == 1)
      _fadeShowController.forward();
    else if (length == 0) _fadeShowController.reverse();
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
