import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:dabel_sport/helper/helpers.dart';
import 'package:dabel_sport/helper/styles.dart';
import 'package:dabel_sport/helper/variables.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class MyGallery extends StatelessWidget {
  late List<Rx<dynamic>> items;

  double height;
  bool autoplay = false;
  bool fullScreen = false;
  MaterialColor colors;
  int  current=0;
  int limit;

  double? ratio = 1.0;
  Style styleController;
  final String infoText;
  final String mode;
  final String? title;
  SwiperController swiperController = SwiperController();
  final ImagePicker _picker = ImagePicker();
  Function(dynamic index, File? file)? onChanged;

  MyGallery({
    Key? key,
    required items,
    required this.height,
    required this.autoplay,
    required this.fullScreen,
    required this.colors,
    required this.infoText,
    this.current=0,
    this.ratio,
    required this.styleController,
    String this.mode = 'view',
    String? this.title,
    int this.limit = 1,
    Function(dynamic index, File? file)? this.onChanged,
  }) {
    this.items = items.map<Rx<dynamic>>((e) => Rx<dynamic>(e)).toList();
    if (mode != 'view')
      this.items.addAll([
        for (int i = 0; i < limit - this.items.length; i++) Rx<dynamic>('')
      ]);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      for (int i = 0; i < items.length; i++)
        this.items[i].value = this.items[i].value;
      return Stack(
        fit: fullScreen ? StackFit.expand : StackFit.loose,
        children: [
          SizedBox(
            height: height,
            child: Swiper(
              itemCount: items.length,
              loop: true,
              autoplay: this.autoplay,
              duration: Random().nextInt(800) + 300,
              autoplayDelay: Random().nextInt(1000) + 5000,
              scale: .5,
              index: current,
              controller: swiperController,
              onIndexChanged: (idx) {
                // print(idx);
                // if (idx==items.length-1)
                //   idx=0;
                current = idx;
                // print(idx);
                // swiperController.move(index);
              },
              // itemWidth: Get.width -
              //     ((styleController.cardMargin * 2.0).round()),
              viewportFraction: 1,
              layout: SwiperLayout.DEFAULT,
              control: SwiperControl(color: Colors.transparent),
              pagination: SwiperPagination(
                  margin: EdgeInsets.all(1.0),
                  alignment: Alignment.bottomCenter,
                  builder: SwiperCustomPagination(builder:
                      (BuildContext context, SwiperPluginConfig config) {
                    return Row(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: colors[50]),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: DotSwiperPaginationBuilder(
                                    color: colors[300],
                                    activeColor: colors[500]?.withOpacity(.8),
                                    size: 5.0,
                                    activeSize: 8.0)
                                .build(context, config),
                          ),
                        )
                      ],
                    );
                  })),
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    Get.to(Obx(() {
                      for (int i = 0; i < items.length; i++)
                        this.items[i].value = this.items[i].value;
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          SizedBox(
                            height: height,
                            child: Hero(
                              tag: 'gallery',
                              child: Swiper(
                                itemCount: items.length,
                                loop: true,
                                autoplay: false,
                                duration: Random().nextInt(800) + 300,
                                autoplayDelay: Random().nextInt(1000) + 5000,
                                scale: .5,
                                index: current,
                                controller: swiperController,
                                onIndexChanged: (idx) {
                                  current = idx;
                                  swiperController.move(current);
                                },
                                viewportFraction: 1,
                                layout: SwiperLayout.DEFAULT,
                                control:
                                    SwiperControl(color: Colors.transparent),
                                pagination: SwiperPagination(
                                    margin: EdgeInsets.all(1.0),
                                    alignment: Alignment.bottomCenter,
                                    builder: SwiperCustomPagination(builder:
                                        (BuildContext context,
                                            SwiperPluginConfig config) {
                                      return Row(
                                        children: <Widget>[
                                          Container(
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: colors[50]),
                                          ),
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.bottomCenter,
                                              child: DotSwiperPaginationBuilder(
                                                      color: colors[300],
                                                      activeColor: colors[500]
                                                          ?.withOpacity(.8),
                                                      size: 5.0,
                                                      activeSize: 8.0)
                                                  .build(context, config),
                                            ),
                                          )
                                        ],
                                      );
                                    })),
                                itemBuilder: (BuildContext context, int index) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                top: Radius.circular(
                                                  styleController
                                                      .cardBorderRadius,
                                                ),
                                                bottom: Radius.circular(
                                                  styleController
                                                          .cardBorderRadius /
                                                      4,
                                                ),
                                              ),
                                              gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    colors[100]!,
                                                    colors[50]!,
                                                  ])),
                                          padding: EdgeInsets.only(bottom: 4),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Expanded(
                                                child: Stack(
                                                  fit: StackFit.expand,
                                                  children: [
                                                    Card(
                                                      child: items[index]
                                                                  .value
                                                                  .runtimeType ==
                                                              String
                                                          ? CachedNetworkImage(
                                                              imageUrl:
                                                                  items[index]
                                                                      .value,
                                                              imageBuilder:
                                                                  (context,
                                                                      imageProvider) {
                                                                return Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft:
                                                                          Radius
                                                                              .circular(
                                                                        styleController
                                                                            .cardBorderRadius,
                                                                      ),
                                                                      topRight:
                                                                          Radius
                                                                              .circular(
                                                                        styleController
                                                                            .cardBorderRadius,
                                                                      ),
                                                                      bottomRight:
                                                                          Radius.circular(styleController.cardBorderRadius /
                                                                              4),
                                                                      bottomLeft:
                                                                          Radius.circular(styleController.cardBorderRadius /
                                                                              4),
                                                                    ),
                                                                    image: DecorationImage(
                                                                        colorFilter: ColorFilter.mode(
                                                                            colors[800]!.withOpacity(
                                                                                .0),
                                                                            BlendMode
                                                                                .darken),
                                                                        image:
                                                                            imageProvider,
                                                                        fit: BoxFit
                                                                            .contain,
                                                                        filterQuality:
                                                                            FilterQuality.medium),
                                                                  ),
                                                                );
                                                              },
                                                              placeholder: (context,
                                                                      url) =>
                                                                  CupertinoActivityIndicator(),
                                                              errorWidget:
                                                                  (context, url,
                                                                          error) =>
                                                                      ClipRRect(
                                                                borderRadius: BorderRadius.all(
                                                                    Radius.circular(
                                                                        styleController
                                                                            .cardBorderRadius)),
                                                                child: Image.network(
                                                                    Variables
                                                                        .NOIMAGE_LINK),
                                                              ),
                                                            )
                                                          : Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                    styleController
                                                                        .cardBorderRadius,
                                                                  ),
                                                                  topRight: Radius
                                                                      .circular(
                                                                    styleController
                                                                        .cardBorderRadius,
                                                                  ),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          styleController.cardBorderRadius /
                                                                              4),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          styleController.cardBorderRadius /
                                                                              4),
                                                                ),
                                                                image: DecorationImage(
                                                                    colorFilter: ColorFilter.mode(
                                                                        colors[800]!.withOpacity(
                                                                            .0),
                                                                        BlendMode
                                                                            .darken),
                                                                    image: FileImage(
                                                                        items[index]
                                                                            .value),
                                                                    fit: BoxFit
                                                                        .contain,
                                                                    filterQuality:
                                                                        FilterQuality
                                                                            .medium),
                                                              ),
                                                            ),
                                                      elevation: 10,
                                                      shadowColor:
                                                          styleController
                                                              .primaryColor
                                                              .withOpacity(.5),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                styleController
                                                                    .cardBorderRadius),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      left: 0,
                                                      right: 0,
                                                      bottom: styleController
                                                              .cardMargin *
                                                          2,
                                                      child: Container(
                                                        color: colors[500]!
                                                            .withOpacity(.5),
                                                        padding: EdgeInsets.all(
                                                            styleController
                                                                    .cardMargin /
                                                                2),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            if (mode != 'view')
                                                              TextButton(
                                                                onPressed:
                                                                    () async {
                                                                  XFile?
                                                                      imageFile =
                                                                      await _picker.pickImage(
                                                                          source:
                                                                              ImageSource.gallery);
                                                                  if (imageFile !=
                                                                      null) {
                                                                    CroppedFile?
                                                                        cp =
                                                                        await ImageCropper()
                                                                            .cropImage(
                                                                      sourcePath:
                                                                          imageFile
                                                                              .path,

                                                                      aspectRatio: CropAspectRatio(
                                                                          ratioX: ratio
                                                                              as double,
                                                                          ratioY:
                                                                              1),
                                                                      // aspectRatioPresets: [
                                                                      // settingController.getAspectRatio('profile'),

                                                                      // ],

                                                                      uiSettings: [
                                                                        AndroidUiSettings(
                                                                            toolbarTitle: 'select_crop_section'
                                                                                .tr,
                                                                            toolbarColor: colors[
                                                                                500],
                                                                            toolbarWidgetColor: Colors
                                                                                .white,
                                                                            hideBottomControls:
                                                                                false,
                                                                            statusBarColor:
                                                                                colors[500],
                                                                            // initAspectRatio: settingController
                                                                            //     .getAspectRatio('profile'),
                                                                            lockAspectRatio: true),
                                                                        IOSUiSettings(
                                                                          title:
                                                                              'select_crop_section'.tr,
                                                                        ),
                                                                      ],
                                                                    );

                                                                    if (cp !=
                                                                        null) {
                                                                      items[index]
                                                                              .value =
                                                                          File(cp
                                                                              .path);
                                                                      if (onChanged !=
                                                                          null)
                                                                        onChanged!(
                                                                            index,
                                                                            items[index].value);
                                                                    }
                                                                  }
                                                                },
                                                                style:
                                                                    ButtonStyle(
                                                                        shape: MaterialStateProperty
                                                                            .all(
                                                                          CircleBorder(
                                                                              side: BorderSide(color: colors[50]!, width: 1)),
                                                                        ),
                                                                        backgroundColor: MaterialStateProperty.resolveWith((states) => states.contains(MaterialState.pressed)
                                                                            ? styleController.secondaryColor
                                                                            : Colors.transparent)),
                                                                child: Padding(
                                                                  padding: EdgeInsets.all(
                                                                      styleController
                                                                              .cardMargin /
                                                                          2),
                                                                  child: Icon(
                                                                    Icons
                                                                        .add_photo_alternate_outlined,
                                                                    color:
                                                                        colors[
                                                                            50],
                                                                  ),
                                                                ),
                                                              ),
                                                            if (mode !=
                                                                    'view' &&
                                                                items[index]
                                                                        .value !=
                                                                    '')
                                                              SizedBox(
                                                                width: styleController
                                                                        .cardMargin /
                                                                    2,
                                                              ),
                                                            if (mode !=
                                                                    'view' &&
                                                                items[index]
                                                                        .value !=
                                                                    '')
                                                              TextButton(
                                                                onPressed:
                                                                    () async {
                                                                  Get.dialog(
                                                                      Center(
                                                                        child: Material(
                                                                          color: Colors
                                                                              .transparent,
                                                                          child:
                                                                              Card(
                                                                            child:
                                                                                Padding(
                                                                              padding: EdgeInsets.all(styleController.cardMargin),
                                                                              child: Column(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                children: [
                                                                                  Text(
                                                                                    'delete_image?'.tr,
                                                                                    style: styleController.textMediumStyle.copyWith(color: Colors.red),
                                                                                  ),
                                                                                  Row(
                                                                                    children: [
                                                                                      Expanded(
                                                                                        child: TextButton(
                                                                                          style: ButtonStyle(
                                                                                              padding: MaterialStateProperty.all(EdgeInsets.all(styleController.cardMargin / 2)),
                                                                                              overlayColor: MaterialStateProperty.resolveWith(
                                                                                                (states) {
                                                                                                  return states.contains(MaterialState.pressed) ? styleController.secondaryColor : null;
                                                                                                },
                                                                                              ),
                                                                                              backgroundColor: MaterialStateProperty.all(Colors.red),
                                                                                              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                                                                                borderRadius: BorderRadius.all(
                                                                                                  Radius.circular(styleController.cardBorderRadius / 2),
                                                                                                ),
                                                                                              ))),
                                                                                          onPressed: () async {
                                                                                            items[index].value = '';

                                                                                            onChanged != null ? onChanged!(index, null) : null;
                                                                                            Get.back();
                                                                                          },
                                                                                          child: Icon(Icons.check, color: Colors.white),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      barrierDismissible:
                                                                          true);
                                                                },
                                                                style:
                                                                    ButtonStyle(
                                                                        shape: MaterialStateProperty
                                                                            .all(
                                                                          CircleBorder(
                                                                              side: BorderSide(color: colors[50]!, width: 1)),
                                                                        ),
                                                                        backgroundColor: MaterialStateProperty.resolveWith((states) => states.contains(MaterialState.pressed)
                                                                            ? styleController.secondaryColor
                                                                            : Colors.transparent)),
                                                                child: Padding(
                                                                  padding: EdgeInsets.all(
                                                                      styleController
                                                                              .cardMargin /
                                                                          2),
                                                                  child: Icon(
                                                                    Icons
                                                                        .delete_outline,
                                                                    color:
                                                                        colors[
                                                                            50],
                                                                  ),
                                                                ),
                                                              ),
                                                            if (mode !=
                                                                'create')
                                                              TextButton(
                                                                onPressed:
                                                                    () async {
                                                                  Helper.shareFile(
                                                                      path: items[
                                                                              index]
                                                                          .value,
                                                                      text:
                                                                          infoText);
                                                                },
                                                                style:
                                                                    ButtonStyle(
                                                                        shape: MaterialStateProperty
                                                                            .all(
                                                                          CircleBorder(
                                                                              side: BorderSide(color: colors[50]!, width: 1)),
                                                                        ),
                                                                        backgroundColor: MaterialStateProperty.resolveWith((states) => states.contains(MaterialState.pressed)
                                                                            ? styleController.secondaryColor
                                                                            : Colors.transparent)),
                                                                child: Padding(
                                                                  padding: EdgeInsets.all(
                                                                      styleController
                                                                              .cardMargin /
                                                                          2),
                                                                  child: Icon(
                                                                    Icons.share,
                                                                    color:
                                                                        colors[
                                                                            50],
                                                                  ),
                                                                ),
                                                              ),
                                                            SizedBox(
                                                              width: styleController
                                                                      .cardMargin /
                                                                  2,
                                                            ),
                                                            TextButton(
                                                              onPressed:
                                                                  () async {
                                                                Get.back();
                                                              },
                                                              style:
                                                                  ButtonStyle(
                                                                      shape: MaterialStateProperty
                                                                          .all(
                                                                        CircleBorder(
                                                                            side:
                                                                                BorderSide(color: colors[50]!, width: 1)),
                                                                      ),
                                                                      backgroundColor: MaterialStateProperty.resolveWith((states) => states.contains(MaterialState
                                                                              .pressed)
                                                                          ? styleController
                                                                              .secondaryColor
                                                                          : Colors
                                                                              .transparent)),
                                                              child: Padding(
                                                                padding: EdgeInsets.all(
                                                                    styleController
                                                                            .cardMargin /
                                                                        2),
                                                                child: Icon(
                                                                  Icons.clear,
                                                                  color: colors[
                                                                      50],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: styleController
                                                        .cardMargin),
                                                child: Text(
                                                  "${index + 1}",
                                                  style: styleController
                                                      .textMediumStyle
                                                      .copyWith(
                                                          color: colors[900]),
                                                  textAlign: TextAlign.right,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    }));
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(
                                  styleController.cardBorderRadius,
                                ),
                                bottom: Radius.circular(
                                  styleController.cardBorderRadius / 4,
                                ),
                              ),
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    colors[100]!,
                                    colors[50]!,
                                  ])),
                          padding: EdgeInsets.only(bottom: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Card(
                                      child: items[index].value.runtimeType ==
                                              String
                                          ? CachedNetworkImage(
                                              imageUrl: items[index].value,
                                              imageBuilder:
                                                  (context, imageProvider) {
                                                return Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft: Radius.circular(
                                                        styleController
                                                            .cardBorderRadius,
                                                      ),
                                                      topRight: Radius.circular(
                                                        styleController
                                                            .cardBorderRadius,
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
                                                        colorFilter:
                                                            ColorFilter.mode(
                                                                colors[800]!
                                                                    .withOpacity(
                                                                        .0),
                                                                BlendMode
                                                                    .darken),
                                                        image: imageProvider,
                                                        fit: BoxFit.contain,
                                                        filterQuality:
                                                            FilterQuality
                                                                .medium),
                                                  ),
                                                );
                                              },
                                              placeholder: (context, url) =>
                                                  CupertinoActivityIndicator(),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      ClipRRect(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(
                                                        styleController
                                                            .cardBorderRadius)),
                                                child: Image.network(
                                                    Variables.NOIMAGE_LINK),
                                              ),
                                            )
                                          : Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(
                                                    styleController
                                                        .cardBorderRadius,
                                                  ),
                                                  topRight: Radius.circular(
                                                    styleController
                                                        .cardBorderRadius,
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
                                                    colorFilter:
                                                        ColorFilter.mode(
                                                            colors[800]!
                                                                .withOpacity(
                                                                    .0),
                                                            BlendMode.darken),
                                                    image: FileImage(
                                                        items[index].value),
                                                    fit: BoxFit.contain,
                                                    filterQuality:
                                                        FilterQuality.medium),
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
                                    Positioned.fill(
                                      bottom: styleController.cardMargin,
                                      left: styleController.cardMargin,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.zoom_out_map_sharp,
                                            color: colors[50],
                                          ),
                                          if (title != null &&
                                              items[index].value == '')
                                            Text(
                                              title!,
                                              style: styleController
                                                  .textMediumStyle
                                                  .copyWith(
                                                      color: colors[500],
                                                      fontWeight:
                                                          FontWeight.bold),
                                            )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(
                                    styleController.cardMargin / 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
