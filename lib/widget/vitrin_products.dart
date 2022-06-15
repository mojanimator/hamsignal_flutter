import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:dabel_sport/controller/ProductController.dart';
import 'package:dabel_sport/controller/SettingController.dart';
import 'package:dabel_sport/helper/variables.dart';
import 'package:dabel_sport/model/Product.dart';
import 'package:dabel_sport/page/product_details.dart';
import 'package:dabel_sport/page/products.dart';
import 'package:dabel_sport/widget/shakeanimation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:get/get.dart';

import '../helper/styles.dart';

class VitrinProducts extends StatelessWidget {
  final ProductController controller;

  final List<Product> data;

  late final EdgeInsets margin;
  late final double swiperFraction;
  late final MaterialColor colors;
  final _key = GlobalKey();
  final int? shop_id;
  var _dividerWidth = 0.0.obs;
  final SettingController settingController = Get.find<SettingController>();
  final Style styleController = Get.find<Style>();
  final bool autoPlay;

  Map<String, dynamic> initFilters;

  VitrinProducts(this.data, this.controller,
      {EdgeInsets? margin,
      double? swiperFraction,
      MaterialColor? colors,
      bool this.autoPlay = true,
      int? this.shop_id,
      Map<String,dynamic> this.initFilters=const{}}) {
    this.margin = margin ??
        EdgeInsets.symmetric(
          vertical: styleController.cardMargin / 8,
          horizontal: styleController.cardMargin,
        );
    this.swiperFraction = swiperFraction ?? 1;
    this.colors = colors ?? styleController.primaryMaterial;

    // WidgetsBinding.instance?.addPostFrameCallback((_) =>
    //
    //     _dividerWidth.value = (_key.currentContext?.size?.width ?? 0) / 2);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    // print(_key.currentContext?.size?.width);
    return ShakeWidget(
      child: Card(
        key: _key,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(styleController.cardBorderRadius),
        ),
        shadowColor: styleController.primaryColor.withOpacity(.3),
        color: colors[100]?.withOpacity(.8),
        elevation: 20,
        margin: margin,
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: styleController.cardMargin / 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'products'.tr,
                  style: styleController.textHeaderStyle
                      .copyWith(color: colors[500]),
                  textAlign: TextAlign.right,
                ),
                TextButton(
                    onPressed: () {
                      if (shop_id != null)
                        controller.filterController.filters['shop'] = shop_id;
                      Get.to(ProductsPage(initFilter: initFilters,));
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(colors[200]),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(
                                    styleController.cardBorderRadius)),
                          ),
                        )),
                    child: Text(
                      'more'.tr,
                      style: styleController.textHeaderStyle
                          .copyWith(color: colors[500]),
                      textAlign: TextAlign.right,
                    ))
              ],
            ),
          ),
          Obx(
            () => Divider(
              height: 1,
              thickness: 3,
              endIndent: _dividerWidth.value,
              color: colors[900],
            ),
          ),
          Container(
            height: styleController.cardVitrinHeight,
            child: Swiper(
              // onIndexChanged: (idx) {
              //   controller.swiperIndex = idx;
              //   if (idx == data.length - 1) controller.getData();
              // },
              index: controller.swiperIndex,
              autoplay: autoPlay,
              duration: Random().nextInt(800) + 300,
              autoplayDelay: Random().nextInt(8000) + 8000,
              scale: .7,
              viewportFraction: swiperFraction,
              layout: SwiperLayout.DEFAULT,
              control: SwiperControl(color: Colors.transparent),
              pagination: SwiperPagination(
                  margin: EdgeInsets.all(1.0),
                  alignment: Alignment.bottomCenter,
                  builder: SwiperCustomPagination(builder:
                      (BuildContext context, SwiperPluginConfig config) {
                    return Row(
                      children: <Widget>[
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
                return SizedBox(
                  width: 50,
                  child: GestureDetector(
                    onTap: () => Get.to(
                        ProductDetails(data: data[index], colors: colors),
                        transition: Transition.fade,
                        duration: Duration(milliseconds: 400)),
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 10),
                      margin: EdgeInsets.only(
                        top: 0,
                        bottom: styleController.cardMargin,
                        left: styleController.cardMargin / 2,
                        right: styleController.cardMargin / 2,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(
                                          styleController.cardBorderRadius)),
                                  gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.white,
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
                                          child: Stack(
                                            children: [
                                              CachedNetworkImage(
                                                imageUrl:
                                                    "${controller.getProfileLink(data[index].docLinks)}",
                                                imageBuilder:
                                                    (context, imageProvider) =>
                                                        Container(
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
                                                                styleController
                                                                    .primaryColor
                                                                    .withOpacity(
                                                                        .0),
                                                                BlendMode
                                                                    .darken),
                                                        image: imageProvider,
                                                        fit: BoxFit.cover,
                                                        filterQuality:
                                                            FilterQuality
                                                                .medium),
                                                  ),
                                                ),
                                                placeholder: (context, url) =>
                                                    CupertinoActivityIndicator(),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        ClipRRect(
                                                  borderRadius: BorderRadius
                                                      .all(Radius.circular(
                                                          styleController
                                                              .cardBorderRadius)),
                                                  child: Image.network(
                                                      Variables.NOIMAGE_LINK),
                                                ),
                                              ),
                                              if (data[index].salePercent !=
                                                  '0%')
                                                Positioned(
                                                  bottom: 0,
                                                  top: 0,
                                                  left: 0,
                                                  child: Center(
                                                    child: Container(
                                                      padding: EdgeInsets.all(
                                                          styleController
                                                                  .cardMargin /
                                                              4),
                                                      decoration: BoxDecoration(
                                                          color: Colors.red,
                                                          borderRadius: BorderRadius
                                                              .horizontal(
                                                                  right: Radius
                                                                      .circular(
                                                                          styleController
                                                                              .cardBorderRadius))),
                                                      child: Text(
                                                        "${data[index].salePercent}",
                                                        style: styleController
                                                            .textMediumLightStyle,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          elevation: 10,
                                          shadowColor: styleController
                                              .primaryColor
                                              .withOpacity(.5),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                styleController
                                                    .cardBorderRadius),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    "${data[index].name}",
                                    style: styleController.textMediumStyle
                                        .copyWith(
                                            color: colors[900],
                                            fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                  Divider(
                                    color: colors[900],
                                  ),
                                  IntrinsicHeight(
                                      child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        data[index].price,
                                        style: styleController.textSmallStyle
                                            .copyWith(color: colors[800]),
                                      ),
                                      VerticalDivider(),
                                      Text(
                                        data[index].discount_price,
                                        style: styleController.textSmallStyle
                                            .copyWith(
                                                color: colors[800],
                                                decoration:
                                                    TextDecoration.lineThrough),
                                      ),
                                    ],
                                  )),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              itemCount: data.length,
            ),
          ),
        ]),
      ),
    );
  }
}
