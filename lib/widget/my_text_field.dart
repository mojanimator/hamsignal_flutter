import 'package:hamsignal/helper/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class MyTextField extends StatelessWidget {
  TextEditingController controller;
  String hintText;
  TextInputType? keyboardType;
  late EdgeInsets margin;
  late IconData icon;
  late BorderRadius borderRadius;
  late int minLines;
  late Color backgroundColor;
  Style style = Get.find<Style>();
  late MyTextFieldAnimationController animationController;
  late bool obscure;

  MyTextField({
    required this.controller,
    required this.hintText,
    TextInputType? keyboardType,
    EdgeInsets? margin,
    IconData? icon,
    BorderRadius? borderRadius,
    Color? backgroundColor,
    int? minLines,
    bool? obscure,
  }) {
    animationController = MyTextFieldAnimationController();
    this.margin = margin ?? EdgeInsets.zero;
    this.icon = icon ?? Icons.textsms;
    this.borderRadius = borderRadius ?? BorderRadius.zero;
    this.minLines = minLines ?? 1;
    this.backgroundColor = backgroundColor ?? Colors.white;
    this.obscure = obscure ?? false;

    if (controller.text.length > 0)
      animationController.toggleCloseSearchIcon(controller.text.length);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      decoration:
          BoxDecoration(color: backgroundColor,  border: Border(bottom: BorderSide(color: style.primaryMaterial[50]!))),
      margin: margin,
      child: ListTile(
          dense: true,
          visualDensity: VisualDensity(horizontal: 0, vertical: -4),
          minVerticalPadding: 0.0,
          contentPadding: EdgeInsets.all(0),
          tileColor: style.primaryColor,
          leading: IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                IconButton(
                    onPressed: () => null,
                    icon: Icon(
                      icon,
                      color: style.primaryColor,
                    )),
              ],
            ),
          ),
          title: TextField(
            obscureText: obscure,
            minLines: minLines,
            maxLines: minLines > 1 ? minLines + 10 : minLines,
            keyboardType: keyboardType,
            controller: controller,
            textInputAction: TextInputAction.next,
            style: TextStyle(color: style.primaryColor),
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: style.primaryMaterial[50]!),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: style.primaryMaterial[50]!),
              ),
              hintText: hintText,
              hintStyle: TextStyle(color: style.primaryColor),
              border: InputBorder.none,

              // isDense: true,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 0, vertical: style.cardMargin),
            ),
            onSubmitted: (str) {},
            // onEditingComplete: () {
            //   controller.getData(param: {'page': 'clear'});
            // },
            onChanged: (str) {
              animationController.toggleCloseSearchIcon(str.length);
            },
          ),
          trailing: FadeTransition(
            opacity: animationController.fadeShowController,
            child: IconButton(
              splashColor: style.secondaryColor,
              icon: Icon(Icons.close),
              onPressed: () {
                controller.clear();
                animationController.toggleCloseSearchIcon(0);
              },
            ),
          )),
    );
  }
}

class MyTextFieldAnimationController extends GetxController
    with GetTickerProviderStateMixin {
  late Animation<double> animation_height_filter;

  MyTextFieldAnimationController({Key? key}) {
    fadeShowController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    fadeShowController.value = 0;
  }

  late AnimationController fadeShowController;

  @override
  void onInit() {
    super.onInit();
  }

  void dispose() {
    fadeShowController.dispose();
    super.dispose();
  }

  toggleCloseSearchIcon(int length) {
    if (length > 1)
      fadeShowController.forward();
    else if (length == 0) fadeShowController.reverse();
  }
}
