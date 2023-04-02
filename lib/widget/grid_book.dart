import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dabel_adl/controller/BookController.dart';
import 'package:dabel_adl/controller/SettingController.dart';
import 'package:dabel_adl/controller/UserController.dart';
import 'package:dabel_adl/helper/styles.dart';
import 'package:dabel_adl/helper/variables.dart';
import 'package:dabel_adl/model/Book.dart';
import 'package:dabel_adl/widget/shakeanimation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../page/lawyer_details.dart';

class GridBook extends StatelessWidget {
  final BookController controller;
  final Style styleController;
  final SettingController settingController;
  final UserController userController;
  late Rx<Book> data;

  late MaterialColor colors;

  late TextStyle titleStyle;

  bool needBuy = false;
  RxBool loading = RxBool(false);

  GridBook({
    Key? key,
    required data,
    required this.controller,
    required this.settingController,
    required this.styleController,
    required this.userController,
    required this.colors,
  }) {
    titleStyle = styleController.textMediumStyle.copyWith(color: colors[900]);
    this.data = Rx<Book>(data);

    needBuy = !(this.data.value.price == '0.00' ||
        double.tryParse(this.data.value.price) == null ||
        this.data.value.reserve == true);
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
                          image: AssetImage("assets/images/back4.png"),
                          fit: BoxFit.cover)),
                  child: InkWell(
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(styleController.cardBorderRadius),
                        bottom: Radius.circular(
                            styleController.cardBorderRadius / 4)),
                    splashColor: Colors.white,
                    onTap: () async {
                      if (data.value.download == '') {
                        final tmp =
                            await controller.find({'id': data.value.id});

                        if (tmp != null) data.value = tmp;
                        needBuy = !(data.value.price == '0.00' ||
                            double.tryParse(data.value.price) == null ||
                            data.value.reserve == true);
                      }
                      if (needBuy) {
                        loading.value = true;
                        bool res = await controller.buy(data.value.id);
                        loading.value = false;
                        if (res) {
                          data.update((val) {
                            val?.reserve = true;
                          });
                          needBuy = false;
                        }
                      } else
                        controller.launchFile(link: data.value.download);
                    },
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
                                    Icons.download_for_offline_rounded,
                                    color: colors[50],
                                    size: styleController.imageHeight / 2,
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
                                              color: colors[50],
                                            ),
                                            child: Text(
                                              "${data.value.title}",
                                              textAlign: TextAlign.center,
                                              style: styleController
                                                  .textMediumLightStyle
                                                  .copyWith(
                                                      color: colors[500],
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
                                              color: colors[500],
                                            ),
                                            width: double.infinity,
                                            child: Center(
                                              child: Obx(
                                                () => loading.value
                                                    ? CupertinoActivityIndicator(
                                                        color: colors[50],
                                                      )
                                                    : Text(
                                                        !needBuy
                                                            ? "download".tr
                                                            : "${'buy'.tr} | ${data.value.price.replaceFirst('.00', " ${'currency'.tr} ")}",
                                                        style:
                                                            titleStyle.copyWith(
                                                                color:
                                                                    colors[50]),
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
                              if (false)
                                Obx(
                                  () => CircleAvatar(
                                    backgroundColor: colors[50],
                                    child: IconButton(
                                      onPressed: () async {
                                        var res = await controller
                                            .mark(data.value.id);
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
