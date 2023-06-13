import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:hamsignal/controller/LawyerController.dart';
import 'package:hamsignal/controller/SettingController.dart';
import 'package:hamsignal/controller/UserController.dart';
import 'package:hamsignal/helper/styles.dart';
import 'package:hamsignal/helper/variables.dart';
import 'package:hamsignal/model/Lawyer.dart';
import 'package:hamsignal/widget/shakeanimation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../page/lawyer_details.dart';

class GridLawyer extends StatelessWidget {
  final LawyerController controller;
  final Style style;
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
    required this.style,
    required this.userController,
    required this.colors,
  }) {
    titleStyle = style.textMediumStyle.copyWith(color: colors[900]);
    this.data = Rx<Lawyer>(data);
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
                        padding: EdgeInsets.all(style.cardMargin / 2),
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              //image section
                              Hero(
                                tag: "preview${data.value.id}",
                                child: ShakeWidget(
                                  child: CachedNetworkImage(
                                   height: double.infinity,
                                    width: style.imageHeight,
                                    imageUrl: "${data.value.avatar}",
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(
                                          0,
                                          ),
                                          topRight: Radius.circular(
                                            style
                                                .cardBorderRadius
                                                 ,
                                          ),
                                          bottomRight: Radius.circular(
                                              style
                                                  .cardBorderRadius /
                                                  4),
                                          bottomLeft: Radius.circular(
                                          0),
                                        ),
                                        image: DecorationImage(
                                          // colorFilter: ColorFilter.mode(
                                          //     style.primaryColor
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
                                            style.cardBorderRadius /
                                                4,
                                          ),
                                          topRight: Radius.circular(
                                            style.cardBorderRadius,
                                          ),
                                          bottomRight: Radius.circular(
                                              style
                                                      .cardBorderRadius /
                                                  4),
                                          bottomLeft: Radius.circular(
                                              style
                                                      .cardBorderRadius /
                                                  4),
                                        ),
                                      ),
                                      child: Image.asset(
                                          'assets/images/icon-dark.png',
                                          fit: BoxFit.contain),
                                    ),
                                  ),
                                ),
                              ),
                              //text section
                              Expanded(
                                child: ShakeWidget(
                                  child: Card(
                                    margin: EdgeInsets.zero,
                                    shadowColor: colors[500]?.withOpacity(.5),
                                    color:Colors.white,
                                  shape: RoundedRectangleBorder(

                                      borderRadius: BorderRadius.horizontal(
                                      right:  Radius.circular(
                                         0,
                                        ),
                                      ).copyWith(
                                          topLeft: Radius.circular(
                                        style.cardBorderRadius,
                                      ),
                                      ),
                                     ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(
                                              style.cardMargin ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(
                                                style
                                                    .cardBorderRadius,
                                              ),
                                              topRight: Radius.circular(
                                             0,
                                              ),
                                              bottomRight: Radius.circular(
                                             0,
                                              ),
                                            ),
                                            color: colors[50],
                                          ),
                                          child: Text(
                                            "${data.value.fullName}",
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
                                              style.cardMargin  ),
                                          decoration: BoxDecoration(
                                            color:Colors.white,
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
                                              style.cardMargin / 4),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.vertical(
                                                bottom: Radius.circular(
                                                    style
                                                            .cardBorderRadius /
                                                        4)),

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
