import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:hamsignal/controller/LocationController.dart';
import 'package:hamsignal/controller/SettingController.dart';
import 'package:hamsignal/controller/UserController.dart';
import 'package:hamsignal/helper/styles.dart';
import 'package:hamsignal/helper/variables.dart';
import 'package:hamsignal/model/Location.dart';
import 'package:hamsignal/widget/shakeanimation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../page/lawyer_details.dart';

class GridLocation extends StatelessWidget {
  final LocationController controller;
  final Style style;
  final SettingController settingController;
  final UserController userController;
  late Rx<Location> data;

  late MaterialColor colors;

  late TextStyle titleStyle;

  GridLocation({
    Key? key,
    required data,
    required this.controller,
    required this.settingController,
    required this.style,
    required this.userController,
    MaterialColor? colors,
  }) {
    this.data = Rx<Location>(data);
    this.colors = colors ?? style.cardLocationColors;
    titleStyle = style.textMediumStyle.copyWith(color: this.colors[900]);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ShakeWidget(
        child: Container(
          // height: style.gridHeight,
          child: Card(
              elevation: 20,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(style.cardBorderRadius),
                    bottom:
                        Radius.circular(style.cardBorderRadius / 4)),
              ),
              shadowColor: colors[500]?.withOpacity(.7),
              margin: EdgeInsets.symmetric(
                  horizontal: style.cardMargin,
                  vertical: style.cardMargin / 4),
              color: colors[50]?.withOpacity(1),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(style.cardBorderRadius),
                    bottom:
                        Radius.circular(style.cardBorderRadius / 4)),
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/images/back.png"),
                          fit: BoxFit.cover)),
                  child: InkWell(
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(style.cardBorderRadius),
                        bottom: Radius.circular(
                            style.cardBorderRadius / 4)),
                    splashColor: Colors.white,
                    onTap: () => controller.openMap(
                        latitude: data.value.lat,
                        longitude: data.value.long,
                        label: 'address'.tr),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                      child: Padding(
                        padding: EdgeInsets.all(style.cardMargin / 4),
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              //image section
                              Hero(
                                tag: "preview${data.value.id}",
                                child: ShakeWidget(
                                  child: Center(
                                      child: Icon(
                                    Icons.location_on_rounded,
                                    color: colors[200],
                                    size: style.imageHeight / 3,
                                  )),
                                ),
                              ),
                              //text section
                              Expanded(
                                child: ShakeWidget(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            style.cardMargin / 2),
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                          vertical:
                                              style.cardMargin / 4),


                                      decoration:   BoxDecoration(color:Colors.white,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(
                                            style.cardBorderRadius,
                                          ),
                                        ).copyWith(
                                            topLeft: Radius.circular(
                                          style.cardBorderRadius,
                                        )),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(
                                                style.cardMargin),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(
                                                  style
                                                      .cardBorderRadius,
                                                ),
                                                topRight: Radius.circular(
                                                  style
                                                          .cardBorderRadius /
                                                      2,
                                                ),
                                              ),
                                              color: colors[50],
                                            ),
                                            child: Text(
                                              "${data.value.title}",
                                              textAlign: TextAlign.center,
                                              style: style
                                                  .textMediumLightStyle
                                                  .copyWith(
                                                      color: colors[500],
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(
                                                style.cardMargin*2),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.vertical(
                                                  bottom: Radius.circular(
                                                      style
                                                              .cardBorderRadius /
                                                          4)),
                                              color: Colors.white,
                                            ),
                                            width: double.infinity,
                                            child: Center(
                                              child: Text(
                                                "${data.value.address}",
                                                style: titleStyle,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Obx(
                                () => Padding(
                                  padding:   EdgeInsets.all(1),
                                  child: CircleAvatar(

                                    backgroundColor: colors[50],
                                    child: IconButton(
                                      onPressed: () async {
                                        var res =
                                            await controller.mark(data.value.id);
                                        if (res != null &&
                                            res['status'] == 'created')
                                          data.update((val) {
                                            val?.mark = true;
                                          });
                                        else if (res != null &&
                                            res['status'] == 'deleted')
                                          data.update((val) {
                                            val?.mark = false;
                                          });
                                      },
                                      icon: Icon(
                                        data.value.mark
                                            ? Icons.bookmark
                                            : Icons.bookmark_border,
                                        color: colors[500],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )),
        ),
      ),
    );
  }
}
