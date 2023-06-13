import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:hamsignal/controller/ContractController.dart';
import 'package:hamsignal/controller/SettingController.dart';
import 'package:hamsignal/controller/UserController.dart';
import 'package:hamsignal/helper/styles.dart';
import 'package:hamsignal/helper/variables.dart';
import 'package:hamsignal/model/Contract.dart';
import 'package:hamsignal/widget/shakeanimation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../page/lawyer_details.dart';

class GridContract extends StatelessWidget {
  final ContractController controller;
  final Style style;
  final SettingController settingController;
  final UserController userController;
  late Rx<Contract> data;

  late MaterialColor colors;

  late TextStyle titleStyle;

  GridContract({
    Key? key,
    required data,
    required this.controller,
    required this.settingController,
    required this.style,
    required this.userController,
    required this.colors,
  }) {
    titleStyle = style.textMediumStyle.copyWith(color: colors[900]);
    this.data = Rx<Contract>(data);
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
              color:Colors.white,
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
                    onTap: () => controller.launchFile(link: data.value.download)  ,
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
                                    Icons.download_for_offline_rounded,
                                    color: colors[500],
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
                                                style.cardMargin*2),
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
                                                style.cardMargin),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.vertical(
                                                  bottom: Radius.circular(
                                                      style
                                                              .cardBorderRadius /
                                                          4)),
                                              color: colors[50],
                                            ),
                                            width: double.infinity,
                                            child: Center(
                                              child: Text(
                                                "download".tr,
                                                style: titleStyle.copyWith(color:colors[500] ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if(false)
                              Obx(
                                    () => CircleAvatar(
                                  backgroundColor:  colors[50],
                                  child: IconButton(
                                    onPressed: () async {
                                      var res =
                                      await controller.mark(data.value.id);
                                      if (res != null &&
                                          res['status'] == 'created')
                                        data.update((val) {
                                          val?.reserve = true;
                                        });
                                      else if (res != null &&
                                          res['status'] == 'deleted')
                                        data.update((val) {
                                          val?.reserve = false;
                                        });
                                    },
                                    icon: Icon(
                                      data.value.reserve
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
