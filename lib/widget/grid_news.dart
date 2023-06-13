import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:hamsignal/controller/NewsController.dart';
import 'package:hamsignal/controller/SettingController.dart';
import 'package:hamsignal/helper/styles.dart';
import 'package:hamsignal/helper/variables.dart';
import 'package:hamsignal/model/News.dart';
import 'package:hamsignal/widget/shakeanimation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../page/news_details.dart';

class GridNews extends StatelessWidget {
  final NewsController controller;
  final Style style;
  final SettingController settingController;
  late Rx<News> data;

  late MaterialColor colors;

  late TextStyle titleStyle;

  GridNews({
    Key? key,
    required data,
    required this.controller,
    required this.settingController,
    required this.style,
    colors,
  }) {
    titleStyle = style.textMediumStyle.copyWith(color: colors[900]);
    this.colors = colors ?? style.cardNewsColors;
    this.data = Rx<News>(data);
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
                    bottom: Radius.circular(style.cardBorderRadius / 4)),
              ),
              shadowColor: colors[500]?.withOpacity(.7),
              margin: EdgeInsets.symmetric(
                  horizontal: style.cardMargin, vertical: style.cardMargin / 4),
              color: colors[50]?.withOpacity(1),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(style.cardBorderRadius),
                    bottom: Radius.circular(style.cardBorderRadius / 4)),
                child: Container(
                  padding: EdgeInsets.all(style.cardMargin / 4),
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/images/back3.png"),
                          fit: BoxFit.cover)),
                  child: InkWell(
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(style.cardBorderRadius),
                        bottom: Radius.circular(style.cardBorderRadius / 4)),
                    splashColor: Colors.white,
                    onTap: () => Get.to(
                        NewsDetails(
                          data: data.value,
                        ),
                        transition: Transition.topLevel,
                        duration: Duration(milliseconds: 400)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                      child: Padding(
                        padding: EdgeInsets.all(style.cardMargin / 4),
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              //image section
                              Hero(
                                tag: "news${data.value.id}",
                                child: ShakeWidget(
                                  child: Card(
                                    margin: EdgeInsets.zero,
                                    child: CachedNetworkImage(
                                      height: double.infinity,
                                      width: style.imageHeight,
                                      imageUrl: data.value.image,
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(
                                              0,
                                            ),
                                            topRight: Radius.circular(
                                              style.cardBorderRadius,
                                            ),
                                            bottomRight: Radius.circular(
                                                style.cardBorderRadius / 4),
                                            bottomLeft: Radius.circular(0),
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
                                              0,
                                            ),
                                            topRight: Radius.circular(
                                              style.cardBorderRadius,
                                            ),
                                            bottomRight: Radius.circular(
                                                style.cardBorderRadius / 4),
                                            bottomLeft: Radius.circular(0),
                                          ),
                                        ),
                                        child: Image.asset(
                                            'assets/images/icon-dark.png',
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                                    elevation: 10,
                                    shadowColor:
                                        style.primaryColor.withOpacity(.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          style.cardBorderRadius),
                                    ),
                                  ),
                                ),
                              ),

                              //text section
                              Expanded(
                                child: ShakeWidget(
                                  child: Card(
                                    margin: EdgeInsets.zero,
                                    color: colors[50],
                                    elevation: 10,
                                    shadowColor: colors[500]?.withOpacity(.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(
                                          0,
                                        ),
                                      ).copyWith(
                                        topLeft: Radius.circular(
                                          style.cardBorderRadius * 2,
                                        ),
                                        bottomLeft: Radius.circular(
                                          style.cardBorderRadius,
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(
                                              style.cardMargin / 2),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(
                                                style.cardBorderRadius / 4,
                                              ),
                                            ).copyWith(
                                                topLeft: Radius.circular(
                                                    style.cardBorderRadius * 2),
                                                bottomRight: Radius.zero),
                                            color: true
                                                ? colors[500]
                                                : Colors.red.withOpacity(.5),
                                          ),
                                        ),
                                        Container(
                                          padding:
                                              EdgeInsets.all(style.cardMargin)
                                                  .copyWith(bottom: 0),
                                          decoration: BoxDecoration(
                                            color: colors[50],
                                          ),
                                          child: Center(
                                            child: Text(
                                              data.value.title,
                                              style: titleStyle.copyWith(
                                                  color: colors[800],
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        Spacer(flex: 1),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: style.cardMargin),
                                          child: Divider(
                                            color: colors[200]?.withOpacity(.2),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: style.cardMargin),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.vertical(
                                                bottom: Radius.circular(
                                                    style.cardBorderRadius /
                                                        4)),
                                            color: colors[50],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(
                                              style.cardMargin / 2),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.vertical(
                                                bottom: Radius.circular(
                                                    style.cardBorderRadius /
                                                        4)),
                                            color: colors[50],
                                          ),
                                          width: double.infinity,
                                          child: IntrinsicHeight(
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Column(
                                                    children: [
                                                      Text(
                                                        " ",
                                                        style: style
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
                                                        style: style
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
