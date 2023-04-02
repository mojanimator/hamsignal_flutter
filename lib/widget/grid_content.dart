import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dabel_adl/controller/ContentController.dart';
import 'package:dabel_adl/controller/SettingController.dart';
import 'package:dabel_adl/helper/styles.dart';
import 'package:dabel_adl/helper/variables.dart';
import 'package:dabel_adl/model/Content.dart';
import 'package:dabel_adl/page/content_details.dart';
import 'package:dabel_adl/widget/shakeanimation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../page/content_details.dart';

class GridContent extends StatelessWidget {
  final ContentController controller;
  final Style styleController;
  final SettingController settingController;
  late Rx<Content> data;

  late MaterialColor colors;

  late TextStyle titleStyle;

  GridContent({
    Key? key,
    required data,
    required this.controller,
    required this.settingController,
    required this.styleController,
    colors,
  }) {
    titleStyle = styleController.textMediumStyle.copyWith(color: colors[900]);
    this.colors = colors ?? styleController.cardContentColors;
    this.data = Rx<Content>(data);
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
                          image: AssetImage("assets/images/back3.png"),
                          fit: BoxFit.cover)),
                  child: InkWell(
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(styleController.cardBorderRadius),
                        bottom: Radius.circular(
                            styleController.cardBorderRadius / 4)),
                    splashColor: Colors.white,
                    onTap: () => Get.to(
                        ContentDetails(
                          data: data.value,
                        ),
                        transition: Transition.topLevel,
                        duration: Duration(milliseconds: 400)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                      child: Padding(
                        padding: EdgeInsets.all(styleController.cardMargin / 4),
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              //image section
                              Hero(
                                tag: "news${data.value.id}",
                                child: ShakeWidget(
                                  child: Card(
                                    child: CachedNetworkImage(
                                      height: styleController.imageHeight,
                                      width: styleController.imageHeight,
                                      imageUrl: controller.getThumbLink(
                                          image: data.value.image,
                                          photos: data.value.photos),
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(
                                              styleController.cardBorderRadius /
                                                  4,
                                            ),
                                            topRight: Radius.circular(
                                              styleController.cardBorderRadius,
                                            ),
                                            bottomRight: Radius.circular(
                                                styleController
                                                        .cardBorderRadius /
                                                    4),
                                            bottomLeft: Radius.circular(
                                                styleController
                                                        .cardBorderRadius /
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
                                          Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(
                                              styleController.cardBorderRadius /
                                                  4,
                                            ),
                                            topRight: Radius.circular(
                                              styleController.cardBorderRadius,
                                            ),
                                            bottomRight: Radius.circular(
                                                styleController
                                                        .cardBorderRadius /
                                                    4),
                                            bottomLeft: Radius.circular(
                                                styleController
                                                        .cardBorderRadius /
                                                    4),
                                          ),
                                        ),
                                        child: Image.asset(
                                            'assets/images/icon-dark.png',
                                            fit: BoxFit.cover),
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
                                            styleController.cardBorderRadius /
                                                4,
                                          ),
                                        ).copyWith(
                                            topLeft: Radius.circular(
                                          styleController.cardBorderRadius,
                                        )),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(
                                                styleController.cardMargin / 2),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                  styleController
                                                          .cardBorderRadius /
                                                      4,
                                                ),
                                              ).copyWith(
                                                  topLeft: Radius.circular(
                                                styleController
                                                    .cardBorderRadius),
                                                  bottomRight: Radius.zero),
                                              color: true
                                                  ? colors[500]
                                                  : Colors.red.withOpacity(.5),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(
                                                    styleController.cardMargin)
                                                .copyWith(bottom: 0),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.vertical(
                                                  bottom: Radius.circular(
                                                      styleController
                                                              .cardBorderRadius /
                                                          4)),
                                              color: colors[50],
                                            ),
                                            child: Center(
                                              child: Text(
                                                data.value.title,
                                                style: titleStyle.copyWith(
                                                    color: colors[800],
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          Spacer(flex: 1),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    styleController.cardMargin),
                                            child: Divider(
                                              color:
                                                  colors[200]?.withOpacity(.2),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    styleController.cardMargin),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.vertical(
                                                  bottom: Radius.circular(
                                                      styleController
                                                              .cardBorderRadius /
                                                          4)),
                                              color: colors[50],
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(
                                                styleController.cardMargin / 2),
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
                                              child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        Text(
                                                          " ",
                                                          style: styleController
                                                              .textSmallStyle
                                                              .copyWith(
                                                                  color: colors[
                                                                      200]),
                                                        ),
                                                      ],
                                                    ),
                                                    VerticalDivider(),
                                                    Column(
                                                      children: [
                                                        Text(
                                                          "${data.value.created_at}",
                                                          style: styleController
                                                              .textSmallStyle
                                                              .copyWith(
                                                                  color: colors[
                                                                      400]),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
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
