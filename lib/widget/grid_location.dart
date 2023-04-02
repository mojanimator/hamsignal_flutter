import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dabel_adl/controller/LocationController.dart';
import 'package:dabel_adl/controller/SettingController.dart';
import 'package:dabel_adl/controller/UserController.dart';
import 'package:dabel_adl/helper/styles.dart';
import 'package:dabel_adl/helper/variables.dart';
import 'package:dabel_adl/model/Location.dart';
import 'package:dabel_adl/widget/shakeanimation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../page/lawyer_details.dart';

class GridLocation extends StatelessWidget {
  final LocationController controller;
  final Style styleController;
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
    required this.styleController,
    required this.userController,
    MaterialColor? colors,
  }) {
    this.data = Rx<Location>(data);
    this.colors = colors ?? styleController.cardLocationColors;
    titleStyle = styleController.textMediumStyle.copyWith(color: this.colors[900]);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ShakeWidget(
        child: Container(
          // height: styleController.gridHeight,
          child: Card(
              elevation: 20,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(styleController.cardBorderRadius),
                    bottom:
                        Radius.circular(styleController.cardBorderRadius / 4)),
              ),
              shadowColor: colors[500]?.withOpacity(.7),
              margin: EdgeInsets.symmetric(
                  horizontal: styleController.cardMargin,
                  vertical: styleController.cardMargin / 4),
              color: colors[50]?.withOpacity(1),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(styleController.cardBorderRadius),
                    bottom:
                        Radius.circular(styleController.cardBorderRadius / 4)),
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/images/back1.png"),
                          fit: BoxFit.cover)),
                  child: InkWell(
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(styleController.cardBorderRadius),
                        bottom: Radius.circular(
                            styleController.cardBorderRadius / 4)),
                    splashColor: Colors.white,
                    onTap: () => controller.openMap(
                        latitude: data.value.lat,
                        longitude: data.value.long,
                        label: 'address'.tr),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                      child: Padding(
                        padding: EdgeInsets.all(styleController.cardMargin / 4),
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
                                    color: colors[50],
                                    size: styleController.imageHeight / 3,
                                  )),
                                ),
                              ),
                              //text section
                              Expanded(
                                child: ShakeWidget(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            styleController.cardMargin / 2),
                                    child: Card(
                                      margin: EdgeInsets.symmetric(
                                          vertical:
                                              styleController.cardMargin / 4),
                                      color: colors[50],
                                      elevation: 10,
                                      shadowColor: colors[500]?.withOpacity(.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(
                                            styleController.cardBorderRadius,
                                          ),
                                        ).copyWith(
                                            topLeft: Radius.circular(
                                          styleController.cardBorderRadius,
                                        )),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(
                                                styleController.cardMargin),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(
                                                  styleController
                                                      .cardBorderRadius,
                                                ),
                                                topRight: Radius.circular(
                                                  styleController
                                                          .cardBorderRadius /
                                                      2,
                                                ),
                                              ),
                                              color: colors[500],
                                            ),
                                            child: Text(
                                              "${data.value.title}",
                                              textAlign: TextAlign.center,
                                              style: styleController
                                                  .textMediumLightStyle
                                                  .copyWith(
                                                      color: colors[50],
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(
                                                styleController.cardMargin),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.vertical(
                                                  bottom: Radius.circular(
                                                      styleController
                                                              .cardBorderRadius /
                                                          4)),
                                              color: colors[50],
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
