import 'package:dabel_sport/helper/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyRangeFilter extends StatelessWidget {
  String type;
  Style styleController;
  dynamic controller;
  late List<DropdownMenuItem> items;

  late EdgeInsets margin;
  late TextEditingController textControllerL;

  late TextEditingController textControllerH;

  MyRangeFilter(
      {required this.type,
      required this.controller,
      required this.styleController,
      EdgeInsets? margin}) {
    this.margin = margin ??
        EdgeInsets.symmetric(
            horizontal: styleController.cardMargin,
            vertical: styleController.cardMargin / 2);
    textControllerL = TextEditingController();
    textControllerH = TextEditingController();
    textControllerL.text = controller.filters["${type}_l"];
    textControllerH.text = controller.filters["${type}_h"];
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: styleController.primaryColor, width: 1),
        borderRadius:
            BorderRadius.circular(styleController.cardBorderRadius * 2),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: styleController.cardMargin),
                child: TextField(
                  textAlign: TextAlign.center,
                  controller: textControllerL,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                      hintText: "${type}_l".tr, border: InputBorder.none),
                  onSubmitted: (str) {
                    controller.parent.getData(param: {'page': 'clear'});
                  },
                  onChanged: (str) {
                    // controller.toggleFilter("${type}_l", idx: str);
                    controller.filters["${type}_l"] = str;
                  },
                ),
              ),
            ),
            Expanded(
              child: controller.filters["${type}_l"] != '' ||
                      controller.filters["${type}_h"] != ''
                  ? Container(
                      decoration: BoxDecoration(
                        color: styleController.primaryColor,
                        border: Border.all(
                            color: styleController.primaryColor, width: 1),
                      ),
                      child: Row(
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: IconButton(
                                color: Colors.white,
                                onPressed: () {
                                  controller.filters["${type}_l"]='';
                                  controller.filters["${type}_h"]='';
                                  controller.toggleFilter("${type}_h" );
                                },
                                icon: Icon(Icons.close)),
                          ),
                          Text(
                            "${type}_limit".tr,
                            style: styleController.textMediumLightStyle,
                          )
                        ],
                      ))
                  : Container(
                      decoration: BoxDecoration(
                        border: Border.symmetric(
                            vertical: BorderSide(
                                color: styleController.primaryColor, width: 1)),
                      ),
                      child: Center(
                          child: Text(
                        "${type}_limit".tr,
                        style: styleController.textMediumStyle,
                      ))),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: styleController.cardMargin),
                child: TextField(
                  textAlign: TextAlign.center,
                  controller: textControllerH,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                      hintText: "${type}_h".tr, border: InputBorder.none),
                  onSubmitted: (str) {
                    controller.parent.getData(param: {'page': 'clear'});
                  },
                  onChanged: (str) {
                    controller.filters["${type}_h"] = str;
                    // controller.toggleFilter("${type}_h", idx: str);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyDropdownButton extends StatelessWidget {
  String type;
  Style styleController;
  dynamic controller;
  late List<DropdownMenuItem> items;
  List<dynamic> children;
  late EdgeInsets margin;

  MyDropdownButton(
      {required this.type,
      required this.controller,
      required this.children,
      required this.styleController,
      EdgeInsets? margin}) {
    items = children.map<DropdownMenuItem>((e) {

      return DropdownMenuItem(
        child: Container(
          child: Center(child: Text(e['name'])),
        ),
        value: e['id'],
      );
    }).toList();
    this.margin =
        margin ?? EdgeInsets.symmetric(horizontal: styleController.cardMargin);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          //background color of dropdown button
          border: Border.all(color: styleController.primaryColor, width: 1),
          //border of dropdown button
          borderRadius: BorderRadius.circular(styleController.cardBorderRadius *
              2), //border raiuds of dropdown button
        ),
        child: DropdownButton<dynamic>(
          elevation: 10,

          borderRadius: BorderRadius.circular(styleController.cardBorderRadius),
          dropdownColor: Colors.white,
          underline: Container(),
          items: items,
          isExpanded: true,
          value: controller.filters[type] !=''?controller.filters[type]:null,
          icon: Center(),
          // underline: Container(),
          hint: Center(
              child: Text(
            type.tr,
            style: TextStyle(color: styleController.primaryColor),
          )),
          onChanged: (idx) {
            controller.toggleFilter(type, idx: idx);
          },
          selectedItemBuilder: (BuildContext context) => children
              .map((e) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          styleController.cardBorderRadius),
                      color: styleController.primaryColor,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        IconButton(
                          onPressed: () {
                            controller.toggleFilter(type, idx: null);
                          },
                          icon: Icon(Icons.close),
                          color: Colors.white,
                        ),
                        Expanded(
                          child: Center(
                              child: Text(
                            e['name'],
                            style: styleController.textMediumLightStyle,
                          )),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class MyToggleButtons extends StatelessWidget {
  String type;
  Style styleController;
  dynamic controller;
  List<Widget> children;

  MyToggleButtons(
      {required this.type,
      required this.controller,
      required this.children,
      required this.styleController}) {}

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: EdgeInsets.symmetric(vertical: styleController.cardMargin / 2),
      child: Container(
        decoration: BoxDecoration(        color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(styleController.cardBorderRadius * 2)),),
        child: ToggleButtons(
            constraints: BoxConstraints.expand(
                width: Get.width / 3 - (styleController.cardMargin * 3 / 2)),
            children: children,
            selectedColor: Colors.white,
            splashColor: Colors.white,
            disabledColor: Colors.white,

            fillColor: styleController.primaryColor,
            color: styleController.primaryColor,
            borderColor: styleController.primaryColor,
            selectedBorderColor: Colors.white,
            borderWidth: 1,
            onPressed: (idx) {
              controller.toggleFilter(type, idx: idx);
            },
            borderRadius: BorderRadius.all(
                Radius.circular(styleController.cardBorderRadius * 2)),
            isSelected: controller.getFilterSelected(type)),
      ),
    );
  }
}

class MyTabController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController controller;
  final int length;

  MyTabController({required this.length}) {
    controller = TabController(vsync: this, length: length);
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    controller.dispose();
    super.onClose();
  }
}
