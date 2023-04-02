import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dabel_adl/controller/LawyerController.dart';
import 'package:dabel_adl/controller/SettingController.dart';
import 'package:dabel_adl/controller/UserController.dart';
import 'package:dabel_adl/helper/styles.dart';
import 'package:dabel_adl/helper/variables.dart';
import 'package:dabel_adl/model/Lawyer.dart';
import 'package:dabel_adl/widget/shakeanimation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../page/lawyer_details.dart';

class GridLawyer extends StatelessWidget {
  final LawyerController controller;
  final Style styleController;
  final SettingController settingController;
  final UserController userController;
  late Rx<Lawyer> data;

  late MaterialColor colors;

  late TextStyle titleStyle;

  GridLawyer({
    Key? key,
    required data,
    required this.controller,
    required this.settingController,
    required this.styleController,
    required this.userController,
    required this.colors,
  }) {
    titleStyle = styleController.textMediumStyle.copyWith(color: colors[900]);
    this.data = Rx<Lawyer>(data);
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
                    onTap: () => userController.hasPlan(
                            goShop: true, message: true)
                        ? Get.to(
                                LawyerDetails(data: data.value, colors: colors),
                                transition: Transition.topLevel,
                                duration: Duration(milliseconds: 400))
                            ?.then((value) async {
                            data.value = value;
                          })
                        : null,
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
                                  child: Card(
                                    child: CachedNetworkImage(
                                      height: styleController.imageHeight,
                                      width: styleController.imageHeight,
                                      imageUrl: "${data.value.avatar}",
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
                                                styleController.cardMargin / 2),
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
                                              "${data.value.fullName}",
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
                                            child: Center(
                                              child: SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: IntrinsicHeight(
                                                      child: Row(
                                                          children:
                                                              data.value
                                                                  .categories
                                                                  .asMap()
                                                                  .map((i, e) {
                                                                    return MapEntry(
                                                                        i,
                                                                        Row(children: [
                                                                          Text(
                                                                            "${e}",
                                                                            style:
                                                                                titleStyle.copyWith(fontWeight: FontWeight.bold),
                                                                          ),
                                                                          data.value.categories.length == i + 1
                                                                              ? Center()
                                                                              : VerticalDivider()
                                                                        ]));
                                                                  })
                                                                  .values
                                                                  .toList()))),
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
                                                        "${'cert_number'.tr}",
                                                        style: titleStyle,
                                                      ),
                                                      Text(
                                                        "${'county'.tr}",
                                                        style: titleStyle,
                                                      ),
                                                    ],
                                                  ),
                                                  VerticalDivider(),
                                                  Column(
                                                    children: [
                                                      Text(
                                                        "${data.value.lawyerNumber}",
                                                        style: titleStyle,
                                                      ),
                                                      Text(
                                                        "${controller.getCounty(data.value.cityId)}",
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
