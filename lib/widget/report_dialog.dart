import 'package:hamsignal/controller/UserController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../helper/helpers.dart';
import '../helper/styles.dart';

class ReportDialog extends StatelessWidget {
  Widget? widget;
  final Style style = Get.find<Style>();
  final UserController userController = Get.find<UserController>();
  final Helper helper = Get.find<Helper>();
  late MaterialColor colors;
  RxBool loading = RxBool(false);
  late String userId;
  String? text;
  TextEditingController descController = TextEditingController();

  ReportDialog({
    String? text,
    Widget? widget,
    MaterialColor? colors,
  }) {
    this.colors = colors ?? style.primaryMaterial;
    userId = userController.user?.id ?? '';
    this.text = text;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: style.cardMargin,
          vertical: style.cardMargin / 4),
      child: (widget != null)
          ? widget
          : Container(
              child: TextButton(
                style: style.buttonStyle(backgroundColor: colors[100]!),
                onPressed: () => Get.dialog(
                  Obx(
                    () => Center(
                      child: Material(
                        color: Colors.transparent,
                        child: Card(
                          margin: EdgeInsets.all(style.cardMargin),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                style.cardBorderRadius),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(style.cardMargin),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: style.cardMargin),
                                  margin: EdgeInsets.symmetric(
                                      vertical: style.cardMargin / 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    //background color of dropdown button
                                    border: Border.all(
                                        color: colors[500]!, width: 1),
                                    //border of dropdown button
                                    borderRadius: BorderRadius.circular(
                                        style.cardBorderRadius /
                                            2), //border raiuds of dropdown button
                                  ),
                                  child: TextField(
                                    minLines: 3,
                                    // expands: true,
                                    maxLines: null,
                                    autofocus: true,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: colors[500],
                                    ),
                                    controller: descController,

                                    textInputAction: TextInputAction.newline,
                                    keyboardType: TextInputType.multiline,

                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'description'.tr,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: style.cardMargin / 2),
                                  child: Visibility(
                                      visible: loading.value,
                                      child: LinearProgressIndicator(
                                          color: colors[500])),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: TextButton(
                                          style: ButtonStyle(
                                              overlayColor:
                                                  MaterialStateProperty
                                                      .resolveWith(
                                                (states) {
                                                  return states.contains(
                                                          MaterialState.pressed)
                                                      ? style
                                                          .secondaryColor
                                                      : null;
                                                },
                                              ),
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      colors[50]),
                                              shape: MaterialStateProperty.all(
                                                  RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.horizontal(
                                                  right: Radius.circular(
                                                      style
                                                              .cardBorderRadius /
                                                          2),
                                                  left: Radius.circular(
                                                      style
                                                              .cardBorderRadius /
                                                          4),
                                                ),
                                              ))),
                                          onPressed: () => Get.back(),
                                          child: Text(
                                            'cancel'.tr,
                                            style: style
                                                .textMediumStyle
                                                .copyWith(color: colors[500]),
                                          )),
                                    ),
                                    VerticalDivider(
                                      indent: style.cardMargin / 2,
                                      endIndent: style.cardMargin / 2,
                                    ),
                                    Expanded(
                                      child: TextButton(
                                          style: ButtonStyle(
                                              overlayColor:
                                                  MaterialStateProperty
                                                      .resolveWith(
                                                (states) {
                                                  return states.contains(
                                                          MaterialState.pressed)
                                                      ? style
                                                          .secondaryColor
                                                      : null;
                                                },
                                              ),
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      colors[500]),
                                              shape: MaterialStateProperty.all(
                                                  RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.horizontal(
                                                  left: Radius.circular(
                                                      style
                                                              .cardBorderRadius /
                                                          2),
                                                  right: Radius.circular(
                                                      style
                                                              .cardBorderRadius /
                                                          4),
                                                ),
                                              ))),
                                          onPressed: () async {
                                            if (descController.text == '')
                                              return;
                                            loading.value = true;
                                            var res = await Helper.sendError({
                                              'type': 'REPORT',
                                              'message':
                                                  "${'report_problem'.tr}\n${'user'.tr}: ${userId}\n${text}\n${'description'.tr}:\n${descController.text}"
                                            });

                                            loading.value = false;
                                            Get.back();

                                            if (res != null)
                                              await helper.showToast(
                                                  msg: 'done_successfully'.tr,
                                                  status: 'success');
                                          },
                                          child: Text(
                                            'send'.tr,
                                            style: style
                                                .textMediumLightStyle,
                                          )),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  //     ,
                  barrierDismissible: true,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment_late_outlined, color: colors[500]),
                    SizedBox(
                      width: style.cardMargin,
                    ),
                    Text(
                      'report_problem'.tr,
                      style: style.textMediumStyle.copyWith(
                          color: colors[500], fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
