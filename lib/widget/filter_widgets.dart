import 'package:hamsignal/controller/UserFilterController.dart';
import 'package:hamsignal/helper/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../controller/APIController.dart';

class MyRangeFilter extends StatelessWidget {
  String type;
  Style style;
  dynamic controller;
  late List<DropdownMenuItem> items;

  late EdgeInsets margin;
  late TextEditingController textControllerL;

  late TextEditingController textControllerH;

  MyRangeFilter(
      {required this.type,
      required this.controller,
      required this.style,
      EdgeInsets? margin}) {
    this.margin = margin ??
        EdgeInsets.symmetric(
            horizontal: style.cardMargin, vertical: style.cardMargin / 2);
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
        border: Border.all(color: style.primaryColor, width: 1),
        borderRadius: BorderRadius.circular(style.cardBorderRadius * 2),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: style.cardMargin),
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
                        color: style.primaryColor,
                        border: Border.all(color: style.primaryColor, width: 1),
                      ),
                      child: Row(
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: IconButton(
                                color: Colors.white,
                                onPressed: () {
                                  controller.filters["${type}_l"] = '';
                                  controller.filters["${type}_h"] = '';
                                  controller.toggleFilter("${type}_h");
                                },
                                icon: Icon(Icons.close)),
                          ),
                          Text(
                            "${type}_limit".tr,
                            style: style.textMediumLightStyle,
                          )
                        ],
                      ))
                  : Container(
                      decoration: BoxDecoration(
                        border: Border.symmetric(
                            vertical: BorderSide(
                                color: style.primaryColor, width: 1)),
                      ),
                      child: Center(
                          child: Text(
                        "${type}_limit".tr,
                        style: style.textMediumStyle,
                      ))),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: style.cardMargin),
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
  Style style;
  APIController controller;
  late List<DropdownMenuItem> items;
  List<dynamic> children;
  late EdgeInsets margin;
  Function? onChanged;

  MyDropdownButton(
      {required this.type,
      required this.controller,
      required this.children,
      required this.style,
      this.onChanged,
      EdgeInsets? margin}) {
    items = children.map<DropdownMenuItem>((e) {
      return DropdownMenuItem(
        child: Container(
          child: Center(child: Text(e['name'])),
        ),
        value: e['id'],
      );
    }).toList();
    this.margin = margin ?? EdgeInsets.symmetric(horizontal: style.cardMargin);
  }

  @override
  Widget build(BuildContext context) {
    return controller.obx(
        (data) => Padding(
              padding: margin,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  //background color of dropdown button
                  border: Border.all(color: style.primaryColor, width: 1),
                  //border of dropdown button
                  borderRadius: BorderRadius.circular(style.cardBorderRadius *
                      2), //border raiuds of dropdown button
                ),
                child: DropdownButton<dynamic>(
                  elevation: 10,

                  borderRadius: BorderRadius.circular(style.cardBorderRadius),
                  dropdownColor: Colors.white,
                  underline: Container(),
                  items: items,
                  isExpanded: true,
                  value: controller.filters[type] != ''
                      ? controller.filters[type]
                      : null,
                  icon: Center(),
                  // underline: Container(),
                  hint: Center(
                      child: Text(
                    type.tr,
                    style: TextStyle(color: style.primaryColor),
                  )),
                  onChanged: (idx) {
                    controller.toggleFilter(type, idx: idx);
                    if (onChanged != null) onChanged!(idx);
                  },
                  selectedItemBuilder: (BuildContext context) => children
                      .map((e) => Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(style.cardBorderRadius),
                              color: style.primaryColor,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (onChanged != null)
                                      onChanged!(null);
                                    else
                                      controller.toggleFilter(type, idx: null);
                                  },
                                  icon: Icon(Icons.close),
                                  color: Colors.white,
                                ),
                                Expanded(
                                  child: Center(
                                      child: Text(
                                    e['name'],
                                    style: style.textMediumLightStyle,
                                  )),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
        onEmpty: Center(),
        onError: (er) => Center(),
        onLoading: Center());
  }
}

class MyToggleButtons extends StatelessWidget {
  String type;
  Style style;
  APIController controller;
  List<Widget> children;

  MyToggleButtons(
      {required this.type,
      required this.controller,
      required this.children,
      required this.style}) {}

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return this.controller.obx(
        (data) => Padding(
              padding: EdgeInsets.symmetric(vertical: style.cardMargin / 2),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                      Radius.circular(style.cardBorderRadius * 2)),
                ),
                child: ToggleButtons(
                    constraints: BoxConstraints.expand(
                        width: Get.width / (children.length) -
                            (style.cardMargin * (children.length * 2))),
                    children: children,
                    selectedColor: Colors.white,
                    splashColor: Colors.white,
                    disabledColor: Colors.white,
                    fillColor: style.primaryColor,
                    color: style.primaryColor,
                    borderColor: style.primaryColor,
                    selectedBorderColor: Colors.white,
                    borderWidth: 1,
                    onPressed: (idx) {
                      controller.toggleFilter(type, idx: idx);
                    },
                    borderRadius: BorderRadius.all(
                        Radius.circular(style.cardBorderRadius * 2)),
                    isSelected: controller.getFilterSelected(type)),
              ),
            ),
        onEmpty: Center(),
        onError: (er) => Center(),
        onLoading: Center());
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

class MyMultiSelect extends StatelessWidget {
  late Style style;
  APIController controller;
  late Rx<List> children;
  late MaterialColor colors;
  late Function onChanged;
  late Rx<List> selecteds;

  MyMultiSelect(
      {required children,
      required this.controller,
      required this.style,
      MaterialColor? colors,
      required this.onChanged}) {
    this.colors = colors ?? style.primaryMaterial;
    this.children = Rx(children);
  }

  @override
  Widget build(BuildContext context) {
    return controller.obx(
        (data) => Card(
              child: Column(
                children: [
                  ListTile(
                    tileColor: Colors.white,
                    splashColor: colors[100],
                    leading: Icon(
                      Icons.account_tree,
                      color: colors[500],
                    ),
                    trailing: Icon(
                      Icons.arrow_back_ios_new_outlined,
                      color: colors[500],
                    ),
                    title: Text(
                      'activity_fields'.tr,
                      style: style.textMediumStyle,
                    ),
                    onTap: () => Get.dialog(Card(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(style.cardBorderRadius),
                      ),
                      margin: EdgeInsets.symmetric(
                          vertical: style.cardMargin,
                          horizontal: style.cardMargin / 2),
                      child: Padding(
                        padding: EdgeInsets.all(style.cardMargin),
                        child: Column(
                          children: [
                            Expanded(
                              child: Obx(
                                () => ListView(
                                  children: children.value
                                      .map<Widget>((e) => ListTile(
                                            splashColor: colors[500],
                                            onTap: () {
                                              e['selected'] = !e['selected'];
                                              onChanged(children.value);
                                              children.refresh();
                                            },
                                            leading: Checkbox(
                                                fillColor:
                                                    MaterialStateProperty.all(
                                                        colors[500]),
                                                value: e['selected'],
                                                onChanged: (s) {
                                                  e['selected'] =
                                                      !e['selected'];
                                                  onChanged(children.value);
                                                  children.refresh();
                                                }),
                                            title: Text(
                                              e['title'],
                                              style: style.textMediumStyle,
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ),
                            ),
                            TextButton(
                              style: style.buttonStyle(
                                  backgroundColor: colors[500],
                                  padding: EdgeInsets.symmetric(
                                      vertical: style.cardMargin * 2)),
                              onPressed: () {
                                Get.back();
                              },
                              child: Center(
                                  child: Text(
                                'select'.tr,
                                style: style.textMediumLightStyle,
                              )),
                            )
                          ],
                        ),
                      ),
                    )),
                  ),
                  Obx(
                    () => Align(
                      alignment: Alignment.centerRight,
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        runSpacing: 0,
                        spacing: style.cardMargin / 4,
                        children: children.value
                            .where((e) => e['selected'] == true)
                            .map<Widget>((e) => TextButton.icon(
                                  style: style.buttonStyle(
                                      radius: BorderRadius.all(Radius.circular(
                                          style.cardMargin / 4)),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: style.cardMargin / 2),
                                      backgroundColor: colors[50]),
                                  onPressed: () {
                                    e['selected'] = false;
                                    children.refresh();
                                    onChanged(children.value);
                                  },
                                  label: Text(
                                    e['title'],
                                    style: TextStyle(color: colors[500]),
                                  ),
                                  icon: Icon(Icons.close),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        onEmpty: Center(),
        onError: (er) => Center(),
        onLoading: Center());
  }
}

class MyDatePicker extends StatelessWidget {
  late Style style;
  APIController controller;
  late Map children;
  late MaterialColor colors;
  late Function onChanged;
  DateTime? beforeData;
  late List<DropdownMenuItem> days;
  late List<DropdownMenuItem> months;
  late List<DropdownMenuItem> years;

  MyDatePicker(
      {required this.children,
      required this.controller,
      required this.style,
      MaterialColor? colors,
      DateTime? beforeData,
      required this.onChanged}) {
    this.colors = colors ?? style.primaryMaterial;

    days = children['days'].map<DropdownMenuItem>((e) {
      return DropdownMenuItem(
        child: Container(
          child: Center(
              child: Text(
            "$e",
            style: style.textMediumStyle,
          )),
        ),
        value: "$e",
      );
    }).toList();
    months = children['months'].map<DropdownMenuItem>((e) {
      return DropdownMenuItem(
        child: Container(
          child: Center(
              child: Text(
            "$e",
            style: style.textMediumStyle,
          )),
        ),
        value: "$e",
      );
    }).toList();
    years = children['years'].map<DropdownMenuItem>((e) {
      return DropdownMenuItem(
        child: Container(
          child: Center(
              child: Text(
            "$e",
            style: style.textMediumStyle,
          )),
        ),
        value: "$e",
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return controller.obx(
        (data) => IntrinsicHeight(
              child: Row(
                  children: [
                {'type': 'day', 'data': days},
                {'type': 'month', 'data': months},
                {'type': 'year', 'data': years},
              ]
                      .map<Widget>((e) => Expanded(
                              child: Card(
                            child: DropdownButton<dynamic>(
                              elevation: 10,
                              borderRadius: BorderRadius.circular(
                                  style.cardBorderRadius / 4),
                              dropdownColor: Colors.white,
                              underline: Container(),
                              items: e['data'] as List<DropdownMenuItem>,
                              isExpanded: true,
                              value: controller.filters[e['type']] != ''
                                  ? controller.filters[e['type']]
                                  : null,
                              icon: Center(),
                              // underline: Container(),
                              hint: Center(
                                  child: Text(
                                "${e['type']}".tr,
                                style: TextStyle(color: style.primaryColor),
                              )),
                              onChanged: (idx) {
                                controller.toggleFilter("${e['type']}",
                                    idx: "$idx");
                              },
                              selectedItemBuilder: (BuildContext context) =>
                                  children["${e['type']}s"]
                                      .map<Widget>((el) => Container(
                                            margin: EdgeInsets.zero,
                                            padding: EdgeInsets.zero,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                IconButton(
                                                  padding: EdgeInsets.zero,
                                                  onPressed: () {
                                                    controller.toggleFilter(
                                                        "${e['type']}",
                                                        idx: null);
                                                  },
                                                  icon: Icon(
                                                    Icons.close,
                                                    color: colors[500],
                                                  ),
                                                  color: Colors.white,
                                                ),
                                                Center(
                                                    child: Text(
                                                  "$el",
                                                  style: style.textMediumStyle,
                                                )),
                                                Icon(
                                                  Icons.keyboard_arrow_down,
                                                  color: colors[300],
                                                ),
                                              ],
                                            ),
                                          ))
                                      .toList(),
                            ),
                          )))
                      .toList()),
            ),
        onEmpty: Center(),
        onError: (er) => Center(),
        onLoading: Center());
  }
}
