import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:hamsignal/controller/SignalController.dart';
import 'package:hamsignal/controller/SettingController.dart';
import 'package:hamsignal/controller/UserController.dart';
import 'package:hamsignal/helper/helpers.dart';
import 'package:hamsignal/helper/styles.dart';
import 'package:hamsignal/helper/variables.dart';
import 'package:hamsignal/model/Signal.dart';
import 'package:hamsignal/model/User.dart';
import 'package:hamsignal/page/signal_details.dart';
import 'package:hamsignal/widget/shakeanimation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GridSignal extends StatelessWidget {
  final SignalController controller;
  final Style style;
  final SettingController settingController;
  late final UserController userController;
  late Rx<Signal> data;

  MaterialColor colors;

  late TextStyle titleStyle;

  GridSignal({
    Key? key,
    required data,
    required this.controller,
    required this.settingController,
    required this.style,
    required this.colors,
  }) {
    titleStyle = style.textMediumStyle.copyWith(color: colors[900]);
    userController = Get.find<UserController>();
    this.data = Rx<Signal>(data);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ShakeWidget(
        child: Row(
          children: [
            Expanded(
              child: Card(
                elevation: 20,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(style.cardBorderRadius),
                ),
                shadowColor: colors[500]?.withOpacity(.7),
                margin: EdgeInsets.symmetric(
                    horizontal: style.cardMargin,
                    vertical: style.cardMargin / 4),
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/images/texture.jpg"),
                        repeat: ImageRepeat.repeat,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.medium,
                        opacity: .3),
                    borderRadius: BorderRadius.circular(style.cardBorderRadius),
                    gradient: style.cardGradientBackgroundReverse,
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                              style: style.buttonStyle(
                                  splashColor: colors[100],
                                  radius: BorderRadius.circular(
                                      style.cardBorderRadius),
                                  backgroundColor:
                                      Colors.white.withOpacity(.8)),
                              onPressed: () => controller.goTo(data.value.link),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(style.cardMargin),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Text(
                                          data.value.name,
                                          style: titleStyle.copyWith(
                                              color: colors[800],
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          "${data.value.created_at}",
                                          style: style.textSmallStyle
                                              .copyWith(color: colors[400]),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: style.cardMargin,
                                        vertical: style.cardMargin / 2),
                                    child: Divider(
                                      height: 1,
                                      thickness: 3,
                                      indent: style.cardMargin,
                                      endIndent: style.cardMargin,
                                      color: colors[100],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: style.cardMargin),
                                    child: IntrinsicHeight(
                                      child: Row(
                                        children: [
                                          if (data.value.vorood != '')
                                            miniCell(
                                                title: 'vorood'.tr,
                                                colors: Colors.indigo,
                                                child: data.value.vorood),
                                          if (data.value.target1 != '')
                                            miniCell(
                                                title: 'target1'.tr,
                                                colors: Colors.teal,
                                                child: data.value.target1),
                                          if (data.value.target2 != '')
                                            miniCell(
                                                title: 'target2'.tr,
                                                colors: Colors.teal,
                                                child: data.value.target2),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: style.cardMargin),
                                    child: IntrinsicHeight(
                                      child: Row(
                                        children: [
                                          if (data.value.hadeZarar != '')
                                            miniCell(
                                                title: 'hade_zarar'.tr,
                                                colors: Colors.red,
                                                child: data.value.hadeZarar),
                                          if (data.value.target1 != '')
                                            miniCell(
                                                title: 'time_tahlil'.tr,
                                                colors: Colors.brown,
                                                child:
                                                    "${data.value.timeTahlil} ${data.value.vahedeTimeTahlil.tr}"),
                                          if (data.value.target2 != '')
                                            miniCell(
                                                title: 'position'.tr,
                                                colors: data.value.position ==
                                                        'Sell'
                                                    ? Colors.red
                                                    : Colors.green,
                                                child: "${data.value.position}"
                                                    .tr),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (data.value.description != '')
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: style.cardMargin),
                                      child: Divider(
                                        color: colors[200]?.withOpacity(.3),
                                      ),
                                    ),
                                  if (data.value.description != '')
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: style.cardMargin / 2,
                                          horizontal: style.cardMargin * 2),
                                      child: Text(
                                        data.value.description,
                                        textAlign: TextAlign.start,
                                        style: style.textMediumStyle
                                            .copyWith(color: colors[900]),
                                      ),
                                    ),
                                ],
                              )),
                        )
                        //text section
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Obx(
              () => CircleAvatar(
                backgroundColor: colors[50],
                child: IconButton(
                  onPressed: () async {
                    var res = await controller.mark(data.value.id);

                    if (res != null && res['status'] == 'created')
                      data.update((val) {
                        val?.isBookmark = true;
                      });
                    else if (res != null && res['status'] == 'deleted')
                      data.update((val) {
                        val?.isBookmark = false;
                      });
                  },
                  icon: Icon(
                    data.value.isBookmark
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: colors[500],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget miniCell(
      {required String title,
      required MaterialColor colors,
      required dynamic child}) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(style.cardMargin)),
        child: Column(
          children: [
            TextButton(
                style: style.buttonStyle(
                    splashColor: colors[100],
                    radius: BorderRadius.circular(style.cardMargin),
                    backgroundColor: colors[50]),
                onPressed: () => controller.goTo(data.value.link),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Center(
                      child: Text(
                        title,
                        style: titleStyle.copyWith(
                            color: colors[800], fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: style.cardMargin,
                          vertical: style.cardMargin / 2),
                      child: Divider(
                        height: 1,
                        thickness: 3,
                        indent: style.cardMargin,
                        endIndent: style.cardMargin,
                        color: colors[100],
                      ),
                    ),
                    Center(
                      child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: style.cardMargin),
                          child: child.runtimeType == String
                              ? Text(
                                  child,
                                  style: style.textMediumStyle
                                      .copyWith(color: colors[500]),
                                )
                              : child),
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
