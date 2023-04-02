import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:dabel_adl/controller/ContentController.dart';
import 'package:dabel_adl/model/Content.dart';
import 'package:dabel_adl/page/content_details.dart';
import 'package:dabel_adl/page/Contents.dart';
import 'package:dabel_adl/page/lawyers.dart';
import 'package:dabel_adl/widget/loader.dart';
import 'package:dabel_adl/widget/shakeanimation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../helper/styles.dart';

class VitrinContent extends StatelessWidget {
  late EdgeInsets margin;
  late double swiperFraction;
  late MaterialColor colors;
  final _key = Get.key;
  var _dividerWidth = 0.0.obs;
  late ContentController controller;
  late Style styleController;

  VitrinContent(
      {EdgeInsets? margin, double? swiperFraction, MaterialColor? colors}) {
    styleController = Get.find<Style>();
    controller = ContentController();
    this.margin = margin ??
        EdgeInsets.symmetric(
          vertical: styleController.cardMargin / 8,
          horizontal: styleController.cardMargin,
        );
    this.swiperFraction = swiperFraction ?? 1;
    this.colors = colors ?? styleController.cardContentColors;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // _dividerWidth.value = (_key.currentContext?.size?.width ?? 0) / 2;
      controller.getMain(param: {'page': 'clear'});
      // controller.getData(param: {'page': 'clear'});
      // Future.delayed(
      //   Duration(seconds: 2),
      //   // () => Get.to(ContentDetails(data: controller.data[0])),
      //       () => Get.to(LawyersPage()),
      // );
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return controller.obx((data) {
      if (data != null)
        return ShakeWidget(
          key: _key,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(styleController.cardBorderRadius),
            ),
            shadowColor: colors[500]?.withOpacity(.3),
            color: colors[100]?.withOpacity(.8),
            elevation: 20,
            margin: EdgeInsets.symmetric(
              vertical: styleController.cardMargin / 8,
              horizontal: styleController.cardMargin,
            ),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(styleController.cardBorderRadius),
                  image: DecorationImage(
                      image: AssetImage("assets/images/back3.png"),
                      fit: BoxFit.cover)),
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: styleController.cardMargin / 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: styleController.cardMargin),
                            child: Text(
                              'blogs'.tr,
                              style: styleController.textHeaderStyle
                                  .copyWith(color: colors[900]),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          TextButton(
                              onPressed: () => {Get.to(ContentsPage())},
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      colors[300]!.withOpacity(.6)),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(
                                              styleController
                                                  .cardBorderRadius)),
                                    ),
                                  )),
                              child: Text(
                                'more'.tr,
                                style: styleController.textHeaderStyle
                                    .copyWith(color: colors[900]),
                                textAlign: TextAlign.right,
                              ))
                        ],
                      ),
                    ),
                    Obx(
                      () => Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: styleController.cardMargin,
                            vertical: styleController.cardMargin / 2),
                        child: Divider(
                          height: 1,
                          thickness: 3,
                          endIndent: _dividerWidth.value,
                          color: colors[900],
                        ),
                      ),
                    ),
                    Container(
                      height: styleController.cardVitrinHeight,
                      child: Swiper(
                        autoplay: true,
                        duration: 300,
                        autoplayDelay: 8000,
                        // itemWidth: Get.width -
                        //     ((styleController.cardMargin * 2.0).round()),
                        viewportFraction: swiperFraction,
                        layout: SwiperLayout.DEFAULT,
                        control: SwiperControl(color: Colors.transparent),
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
                                        color: styleController.primaryColor),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: DotSwiperPaginationBuilder(
                                              color: colors[300],
                                              activeColor:
                                                  colors[500]?.withOpacity(.8),
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
                            onTap: () =>
                                Get.to(ContentDetails(data: data[index])),
                            child: Container(
                              margin: EdgeInsets.only(
                                top: styleController.cardMargin / 2,
                                bottom: styleController.cardMargin,
                                left: styleController.cardMargin / 2,
                                right: styleController.cardMargin / 2,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  //***image section
                                  Expanded(
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl: data[index].image,
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(
                                                      styleController
                                                          .cardBorderRadius)),
                                              image: DecorationImage(
                                                  colorFilter: ColorFilter.mode(
                                                      colors[200]!
                                                          .withOpacity(.5),
                                                      BlendMode.darken),
                                                  image: imageProvider,
                                                  fit: BoxFit.cover,
                                                  filterQuality:
                                                      FilterQuality.medium),
                                            ),
                                          ),
                                          placeholder: (context, url) =>
                                              CupertinoActivityIndicator(),
                                          errorWidget: (context, url, error) =>
                                              Text(error.toString()),
                                        ),
                                        Positioned(
                                          bottom:
                                              0, // styleController.cardMargin,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                      begin: Alignment
                                                          .bottomCenter,
                                                      end: Alignment.topCenter,
                                                      colors: [
                                                        colors[800] as Color,
                                                        colors[800]
                                                            ?.withOpacity(
                                                                .8) as Color,
                                                        colors[800]
                                                            ?.withOpacity(
                                                                .6) as Color,
                                                        Colors.transparent
                                                      ]),
                                                  borderRadius: BorderRadius.vertical(
                                                      bottom: Radius.circular(
                                                          styleController
                                                              .cardBorderRadius))),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: styleController
                                                          .cardMargin /
                                                      2,
                                                  vertical: styleController
                                                          .cardMargin *
                                                      2),
                                              child: Text(
                                                data[index].title,
                                                textAlign: TextAlign.center,
                                                style: styleController
                                                    .textMediumLightStyle,
                                              )),
                                        ),
                                        Positioned(
                                            child: Container(
                                                decoration: BoxDecoration(
                                                    color: colors[500]
                                                        ?.withOpacity(.7),
                                                    borderRadius: BorderRadius.only(
                                                        topLeft: Radius.circular(
                                                            styleController
                                                                .cardMargin),
                                                        bottomRight: Radius.circular(
                                                            styleController
                                                                    .cardMargin /
                                                                2))),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: styleController
                                                            .cardMargin /
                                                        2,
                                                    vertical:
                                                        styleController.cardMargin / 2),
                                                child: Text(
                                                  data[index].created_at,
                                                  textAlign: TextAlign.center,
                                                  style: styleController
                                                      .textTinyLightStyle,
                                                )),
                                            left: 0,
                                            top: 0),
                                      ],
                                    ),
                                  ),
                                  //***text section
                                  Container(
                                    padding: EdgeInsets.all(
                                        styleController.cardMargin / 2),
                                    child: Text(
                                      data[index].short_body,
                                      style: styleController.textSmallStyle
                                          .copyWith(color: colors[900]),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        itemCount: data.length,
                      ),
                    ),
                  ]),
            ),
          ),
        );
      else
        return Center();
    }, onLoading: Loader(), onEmpty: Center());
  }
}
