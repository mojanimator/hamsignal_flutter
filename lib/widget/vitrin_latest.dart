import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:dabel_sport/controller/LatestController.dart';
import 'package:dabel_sport/controller/SettingController.dart';
import 'package:dabel_sport/model/Club.dart';
import 'package:dabel_sport/model/Coach.dart';
import 'package:dabel_sport/model/Player.dart';
import 'package:dabel_sport/model/Product.dart';
import 'package:dabel_sport/model/Shop.dart';
import 'package:dabel_sport/model/latest.dart';
import 'package:dabel_sport/page/club_details.dart';
import 'package:dabel_sport/page/coach_details.dart';
import 'package:dabel_sport/page/player_details.dart';
import 'package:dabel_sport/page/product_details.dart';
import 'package:dabel_sport/page/shop_details.dart';
import 'package:dabel_sport/widget/shakeanimation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../helper/styles.dart';
import '../helper/variables.dart';

class VitrinLatest extends StatelessWidget {
  final LatestController controller;

  final List<Latest> data;
  final _key = GlobalKey();
  late EdgeInsets margin;
  late double swiperFraction;
  late MaterialColor colors;
  var _dividerWidth = 0.0.obs;
  final SettingController settingController = Get.find<SettingController>();
  final Style styleController = Get.find<Style>();

  VitrinLatest(this.data, this.controller,
      {EdgeInsets? margin, double? swiperFraction, MaterialColor? colors}) {
    this.margin = margin ??
        EdgeInsets.symmetric(
          vertical: styleController.cardMargin / 8,
          horizontal: styleController.cardMargin,
        );
    this.swiperFraction = swiperFraction ?? 1;
    this.colors = colors ?? styleController.primaryMaterial;
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        _dividerWidth.value = (_key.currentContext?.size?.width ?? 0) / 2);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ShakeWidget(
      key: _key,
      child: Card(
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
                  'latest'.tr,
                  style: styleController.textHeaderStyle
                      .copyWith(color: colors[900]),
                  textAlign: TextAlign.right,
                ),
                TextButton(
                    onPressed: () => {},
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.transparent),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(
                                    styleController.cardBorderRadius)),
                          ),
                        )),
                    child: Text(
                      "",
                      style: styleController.textHeaderStyle
                          .copyWith(color: colors[900]),
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
              autoplay: true,
              duration: 300,
              autoplayDelay: 8000,
              scale: .7,
              // itemWidth: Get.width -
              //     ((styleController.cardMargin * 2.0).round()),
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
                // print(data[index].id);
                return InkWell(
                  onTap: () => goToPage(
                      {'type': data[index].type, 'id': "${data[index].id}"}),
                  child: Container(
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
                                borderRadius: BorderRadius.all(Radius.circular(
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
                                        child: CachedNetworkImage(
                                          imageUrl: "${data[index].docLink}",
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  Container(
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
                                                  colorFilter: ColorFilter.mode(
                                                      styleController
                                                          .primaryColor
                                                          .withOpacity(.0),
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
                                              ClipRRect(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(styleController
                                                    .cardBorderRadius)),
                                            child: Image.network(
                                                Variables.NOIMAGE_LINK),
                                          ),
                                          // errorWidget: (context, url, error) =>
                                          //     Text(error.toString()),
                                        ),
                                        elevation: 10,
                                        shadowColor: styleController
                                            .primaryColor
                                            .withOpacity(.5),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              styleController.cardBorderRadius),
                                        ),
                                      ),
                                      Positioned(
                                        child: Container(
                                            decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                    begin: Alignment
                                                        .bottomCenter,
                                                    end: Alignment.topCenter,
                                                    colors: [
                                                      colors[800] as Color,
                                                      colors[800]
                                                              ?.withOpacity(.8)
                                                          as Color,
                                                      colors[800]
                                                              ?.withOpacity(.5)
                                                          as Color,
                                                      Colors.transparent
                                                    ]),
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                        bottom: Radius.circular(
                                                            4))),
                                            padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    styleController.cardMargin /
                                                        2,
                                                vertical:
                                                    styleController.cardMargin /
                                                        2),
                                            child: Text(
                                              data[index].name,
                                              textAlign: TextAlign.center,
                                              style: styleController
                                                  .textHeaderLightStyle,
                                            )),
                                        bottom:
                                            styleController.cardBorderRadius /
                                                5,
                                        left: styleController.cardBorderRadius /
                                            5,
                                        right:
                                            styleController.cardBorderRadius /
                                                5,
                                      ),
                                    ],
                                  ),
                                ),
                                IntrinsicHeight(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        data[index].type == 'pr'
                                            ? "${data[index].price}"
                                            : "${settingController.province(data[index].province_id)}",
                                        style: styleController.textSmallStyle,
                                        textAlign: TextAlign.center,
                                      ),
                                      VerticalDivider(
                                        color: styleController.primaryColor,
                                      ),
                                      Text(
                                        data[index].type == 'pr'
                                            ? "${data[index].discount_price}"
                                            : "${settingController.county(data[index].county_id)}",
                                        style: data[index].type == 'pr'
                                            ? styleController.textSmallStyle
                                                .copyWith(
                                                    decoration: TextDecoration
                                                        .lineThrough)
                                            : styleController.textSmallStyle,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
    );
  }

  goToPage(params) async {
    var data = await controller.find(params);

    switch (data.runtimeType) {
      case Player:
        Get.to(
            PlayerDetails(
              data: data,
              colors: styleController.cardPlayerColors,
            ),
            transition: Transition.topLevel,
            duration: Duration(milliseconds: 400));
        break;
      case Coach:
        Get.to(
            CoachDetails(
              data: data,
              colors: styleController.cardCoachColors,
            ),
            transition: Transition.topLevel,
            duration: Duration(milliseconds: 400));
        break;
      case Club:
        Get.to(
            ClubDetails(
              data: data,
              colors: styleController.cardClubColors,
            ),
            transition: Transition.topLevel,
            duration: Duration(milliseconds: 400));
        break;
      case Shop:
        Get.to(
            ShopDetails(
              data: data,
              colors: styleController.cardShopColors,
            ),
            transition: Transition.topLevel,
            duration: Duration(milliseconds: 400));
        break;
      case Product:
        Get.to(
            ProductDetails(
              data: data,
              colors: styleController.cardProductColors,
            ),
            transition: Transition.topLevel,
            duration: Duration(milliseconds: 400));
        break;
    }
  }
}
