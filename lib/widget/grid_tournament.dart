import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dabel_sport/controller/SettingController.dart';
import 'package:dabel_sport/controller/TournamentController.dart';
import 'package:dabel_sport/helper/styles.dart';
import 'package:dabel_sport/helper/variables.dart';
import 'package:dabel_sport/model/Tournament.dart';
import 'package:dabel_sport/page/tournament_details.dart';
import 'package:dabel_sport/widget/shakeanimation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GridTournament extends StatelessWidget {
  final TournamentController controller;
  final Style styleController;
  final SettingController settingController;
  late Rx<Tournament> data;

  late MaterialColor colors;

  late TextStyle titleStyle;

  GridTournament({
    Key? key,
    required data,
    required this.controller,
    required this.settingController,
    required this.styleController,
    required this.colors,
  }) {
    titleStyle = styleController.textMediumStyle.copyWith(color: colors[900]);
    this.data = Rx<Tournament>(data);
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
                child: InkWell(
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(styleController.cardBorderRadius),
                      bottom: Radius.circular(
                          styleController.cardBorderRadius / 4)),
                  splashColor: Colors.white,
                  onTap: () => Get.to(
                      TournamentDetails(data: data.value, colors: colors),
                      transition: Transition.topLevel,
                      duration: Duration(milliseconds: 400)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                    child: Padding(
                      padding: EdgeInsets.all(styleController.cardMargin / 4),
                      child: Row(
                        children: [
                          //image section
                          Hero(
                            tag: "preview${data.value.id}",
                            child: ShakeWidget(
                              child: Card(
                                child: CachedNetworkImage(
                                  height: styleController.imageHeight,
                                  width: styleController.imageHeight,
                                  imageUrl:
                                      "${controller.getProfileLink(data.value.id)}",
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(
                                          styleController.cardBorderRadius,
                                        ),
                                        topRight: Radius.circular(
                                          styleController.cardBorderRadius,
                                        ),
                                        bottomRight: Radius.circular(
                                            styleController.cardBorderRadius /
                                                4),
                                        bottomLeft: Radius.circular(
                                            styleController.cardBorderRadius /
                                                4),
                                      ),
                                      image: DecorationImage(
                                        // colorFilter: ColorFilter.mode(
                                        //     styleController.primaryColor
                                        //         .withOpacity(.0),
                                        //     BlendMode.darken),
                                        image: imageProvider,
                                        fit: BoxFit
                                            .cover, /*filterQuality: FilterQuality.medium*/
                                      ),
                                    ),
                                  ),
                                  placeholder: (context, url) =>
                                      CupertinoActivityIndicator(),
                                  errorWidget: (context, url, error) =>
                                      ClipRRect(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            styleController.cardBorderRadius)),
                                    child:
                                        Image.network(Variables.NOIMAGE_LINK),
                                  ),
                                ),
                                elevation: 10,
                                shadowColor: styleController.primaryColor
                                    .withOpacity(.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      styleController.cardBorderRadius),
                                ),
                              ),
                            ),
                          ),
                          //text section
                          Expanded(
                            child: ShakeWidget(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: styleController.cardMargin / 2),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Card(
                                      margin: EdgeInsets.symmetric(
                                          vertical:
                                              styleController.cardMargin / 4),
                                      color: colors[50],
                                      elevation: 10,
                                      shadowColor: colors[500]?.withOpacity(.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            styleController.cardBorderRadius),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(
                                                styleController.cardMargin / 4),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.vertical(
                                                  top: Radius.circular(
                                                      styleController
                                                              .cardBorderRadius /
                                                          2)),
                                              color: data.value.active
                                                  ? colors[500]
                                                  : Colors.red.withOpacity(.5),
                                            ),
                                            child: Text(
                                              "${data.value.name}",
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
                                                styleController.cardMargin / 4),
                                            decoration: BoxDecoration(
                                              color: colors[50],
                                            ),
                                            width: double.infinity,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Text(
                                                  "${controller.getSport(data.value.sport_id)}",
                                                  style: titleStyle.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(
                                                styleController.cardMargin / 4),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.vertical(
                                                  bottom: Radius.circular(
                                                      styleController
                                                              .cardBorderRadius /
                                                          4)),
                                              color: colors[50],
                                            ),
                                            width: double.infinity,
                                            child: IntrinsicHeight(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Column(
                                                    children: [
                                                      Text(
                                                        "updated_at".tr,
                                                        style: titleStyle,
                                                      ),
                                                    ],
                                                  ),
                                                  VerticalDivider(),
                                                  Column(
                                                    children: [
                                                      Text(
                                                        data.value.updated_at
                                                            .split('|')[0],
                                                        style: titleStyle,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
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
