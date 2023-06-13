import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:hamsignal/controller/NewsController.dart';
import 'package:hamsignal/model/News.dart';
import 'package:hamsignal/page/lawyers.dart';
import 'package:hamsignal/page/news_details.dart';
import 'package:hamsignal/page/newses.dart';
import 'package:hamsignal/widget/loader.dart';
import 'package:hamsignal/widget/shakeanimation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../helper/styles.dart';

class VitrinNews extends StatelessWidget {
  late EdgeInsets margin;
  late double swiperFraction;
  late MaterialColor colors;
  final _key = Get.key;
  var _dividerWidth = 0.0.obs;
  late NewsController controller;
  late Style style;

  VitrinNews(
      {EdgeInsets? margin, double? swiperFraction, MaterialColor? colors}) {
    style = Get.find<Style>();
    controller = NewsController();
    this.margin = margin ??
        EdgeInsets.symmetric(
          vertical: style.cardMargin / 8,
          horizontal: style.cardMargin,
        );
    this.swiperFraction = swiperFraction ?? 1;
    this.colors = colors ?? style.cardNewsColors;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // _dividerWidth.value = (_key.currentContext?.size?.width ?? 0) / 2;
      controller.getMain(param: {'page': 'clear'});
      // controller.getData(param: {'page': 'clear'});
      // Future.delayed(
      //   Duration(seconds: 2),
      //   // () => Get.to(NewsDetails(data: controller.data[0])),
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
              BorderRadius.circular(style.cardBorderRadius),
            ),
            shadowColor: colors[500]?.withOpacity(.3),
            color: colors[50]?.withOpacity(.2),
            elevation: 20,
            margin: EdgeInsets.symmetric(
              vertical: style.cardMargin / 8,
              horizontal: style.cardMargin,
            ),
            child: Container(

              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/texture.jpg"),
                    repeat: ImageRepeat.repeat,
                    fit: BoxFit.scaleDown,
                    filterQuality: FilterQuality.medium,
                    colorFilter: ColorFilter.mode(
                        style.primaryColor.withOpacity(.1), BlendMode.darken),
                    opacity: .1),
                  borderRadius:
                  BorderRadius.vertical(top:Radius.circular(style.cardBorderRadius)),

                gradient: style.cardGradientBackground ,
                  // image: DecorationImage(
                  //     image: AssetImage("assets/images/back.png"),
                  //     fit: BoxFit.cover)
              ),
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: style.cardMargin / 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: style.cardMargin),
                            child: Text(
                              'blogs'.tr,
                              style: style.textHeaderStyle
                                  .copyWith(color: colors[900]),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          TextButton(
                              onPressed: () => {Get.to(NewsPage())},
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      colors[300]!.withOpacity(.2)),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(
                                              style
                                                  .cardBorderRadius)),
                                    ),
                                  )),
                              child: Text(
                                'more'.tr,
                                style: style.textHeaderStyle
                                    .copyWith(color: colors[900]),
                                textAlign: TextAlign.right,
                              ))
                        ],
                      ),
                    ),
                    Obx(
                          () =>
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: style.cardMargin,
                                vertical: style.cardMargin / 2),
                            child: Divider(
                              height: 1,
                              thickness: 3,
                              endIndent: _dividerWidth.value,
                              color: colors[900],
                            ),
                          ),
                    ),
                    Container(
                      height: style.cardVitrinHeight,
                      child: Swiper(
                        autoplay: true,
                        duration: 300,
                        autoplayDelay: 8000,
                        // itemWidth: Get.width -
                        //     ((style.cardMargin * 2.0).round()),
                        viewportFraction: swiperFraction,
                        layout: SwiperLayout.DEFAULT,
                        control: SwiperControl(color: Colors.transparent),
                        pagination: SwiperPagination(
                            margin: EdgeInsets.all(4.0),
                            alignment: Alignment.bottomCenter,
                            builder: SwiperCustomPagination(builder:
                                (BuildContext context,
                                SwiperPluginConfig config) {
                              return Row(
                                children: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: style.primaryColor),
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
                                Get.to(NewsDetails(data: data[index])),
                            child: Container(
                              margin: EdgeInsets.only(
                                top: style.cardMargin / 2,
                                bottom: style.cardMargin,
                                left: style.cardMargin  ,
                                right: style.cardMargin ,
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
                                                  borderRadius: BorderRadius
                                                      .all(
                                                      Radius.circular(
                                                          style
                                                              .cardBorderRadius)),
                                                  image: DecorationImage(
                                                      colorFilter: ColorFilter
                                                          .mode(
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
                                          0, // style.cardMargin,
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
                                                  borderRadius: BorderRadius
                                                      .vertical(
                                                      bottom: Radius.circular(
                                                          style
                                                              .cardBorderRadius))),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: style
                                                      .cardMargin /
                                                      2,
                                                  vertical: style
                                                      .cardMargin *
                                                      2),
                                              child: Text(
                                                data[index].title,
                                                textAlign: TextAlign.center,
                                                style: style
                                                    .textMediumLightStyle,
                                              )),
                                        ),
                                        Positioned(
                                            child: Container(
                                                decoration: BoxDecoration(
                                                    color: colors[500]
                                                        ?.withOpacity(.7),
                                                    borderRadius: BorderRadius
                                                        .only(
                                                        topLeft: Radius
                                                            .circular(
                                                            style
                                                                .cardBorderRadius),
                                                        bottomRight: Radius
                                                            .circular(
                                                            style
                                                                .cardMargin /
                                                                2))),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: style
                                                        .cardMargin  ,
                                                    vertical:
                                                    style.cardMargin /
                                                        2),
                                                child: Text(
                                                  data[index].created_at,
                                                  textAlign: TextAlign.center,
                                                  style: style
                                                      .textTinyLightStyle,
                                                )),
                                            left: 0,
                                            top: 0),
                                      ],
                                    ),
                                  ),
                                  //***text section
                                  if(true)
                                    Container(
                                      padding: EdgeInsets.all(
                                          style.cardMargin / 2),
                                      // child: Text(
                                      //   data[index].title,
                                      //   style: style.textSmallStyle
                                      //       .copyWith(color: colors[900]),
                                      //   textAlign: TextAlign.right,
                                      // ),
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
