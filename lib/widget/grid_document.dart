import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:hamsignal/controller/DocumentController.dart';
import 'package:hamsignal/controller/SettingController.dart';
import 'package:hamsignal/controller/UserController.dart';
import 'package:hamsignal/helper/styles.dart';
import 'package:hamsignal/helper/variables.dart';
import 'package:hamsignal/model/Category.dart';
import 'package:hamsignal/model/Document.dart';
import 'package:hamsignal/widget/shakeanimation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../page/lawyer_details.dart';

class GridDocument extends StatelessWidget {
  final DocumentController controller;
  final Style style;
  final SettingController settingController;
  final UserController userController;
  final int categoryType;
  late Rx<Document> data;

  late MaterialColor colors;

  late TextStyle titleStyle;

  GridDocument({
    Key? key,
    required data,
    required this.controller,
    required this.settingController,
    required this.style,
    required this.userController,
    MaterialColor? colors,
    required this.categoryType,
  }) {
    this.data = Rx<Document>(data);

    if (colors == null) {
      if (categoryType == CategoryRelate.Opinions)
        this.colors = style.cardOpinionsColors;
      else if (categoryType == CategoryRelate.Votes)
        this.colors = style.cardVotesColors;
      else
        this.colors = style.cardConventionsColors;
    } else
      this.colors = colors;
    titleStyle =
        style.textMediumStyle.copyWith(color: this.colors[900]);
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
                          // "assets/images/back${categoryType == CategoryRelate.Votes ? '5' : categoryType == CategoryRelate.Opinions ? '1' : '2'}.png"),
                          fit: BoxFit.cover)),
                  child: InkWell(
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(style.cardBorderRadius),
                        bottom: Radius.circular(
                            style.cardBorderRadius / 4)),
                    splashColor: Colors.white,
                    onTap: () => controller.launchPage(
                        categoryType: categoryType,
                        data: data.value,
                        colors: colors),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                      child: Padding(
                        padding: EdgeInsets.all(style.cardMargin / 4),
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              if (false)
                                //image section
                                Hero(
                                  tag: "preview${data.value.id}",
                                  child: ShakeWidget(
                                    child: Center(
                                        child: Icon(
                                      Icons.arrow_circle_right,
                                      color: colors[50],
                                      size: style.imageHeight / 2,
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
                                    child: Card(
                                      margin: EdgeInsets.symmetric(
                                          vertical:
                                              style.cardMargin / 4),
                                      color:Colors.white,
                                      elevation: 10,
                                      shadowColor: colors[500]?.withOpacity(.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                      top:    Radius.circular(
                                            style.cardBorderRadius,
                                          ),bottom:    Radius.circular(
                                            style.cardBorderRadius/4,
                                          ),
                                        ) ,
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

                                            width: double.infinity,
                                            child: Text(
                                              data.value.body.length > 100
                                                  ? "${data.value.body.substring(0, 100)}..."
                                                  : data.value.body,
                                              style: titleStyle.copyWith(
                                                  color: colors[900]),
                                            ),
                                          ),
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
                                      var res = await controller.mark(
                                          data.value.id, categoryType);
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
