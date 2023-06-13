import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:hamsignal/controller/AdvController.dart';
import 'package:hamsignal/model/adv.dart';
import 'package:hamsignal/widget/MyNativeAdv.dart';
import 'package:hamsignal/widget/loader.dart';
import 'package:hamsignal/widget/shakeanimation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../helper/styles.dart';

class VitrinAdv extends StatelessWidget {
  late EdgeInsets margin;
  late double swiperFraction;
  late MaterialColor colors;
  final _key = Get.key;
  var _dividerWidth = 0.0.obs;
  late AdvController controller;
  late Style style;
  Widget failedWidget;

  VitrinAdv(
      {EdgeInsets? margin,
      double? swiperFraction,
      MaterialColor? colors,
      required Widget this.failedWidget}) {
    style = Get.find<Style>();
    controller = AdvController();
    this.margin = margin ??
        EdgeInsets.symmetric(
          vertical: style.cardMargin / 8,
          horizontal: style.cardMargin,
        );
    this.swiperFraction = swiperFraction ?? 1;
    this.colors = colors ?? style.cardNewsColors;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // _dividerWidth.value = (_key.currentContext?.size?.width ?? 0) / 2;
      controller.getData(param: {'page': 'clear'});
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
      if (data != null) {
        List<AdvItem> advs = data.advs;
        if (data.type['native'] == null) return failedWidget;
        if (data.type['native'] != 'dabel')
          return MyNativeAdv(
              controller: controller, failedWidget: failedWidget);
        return ShakeWidget(
          key: _key,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(style.cardBorderRadius),
            ),
            shadowColor: colors[500]?.withOpacity(.3),
            color: colors[100]?.withOpacity(.8),
            elevation: 20,
            margin: EdgeInsets.symmetric(
              vertical: style.cardMargin / 8,
              horizontal: style.cardMargin,
            ),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(style.cardBorderRadius),
                  image: DecorationImage(
                      image: AssetImage("assets/images/back3.png"),
                      fit: BoxFit.cover)),
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (data.type['native'] == 'dabel')
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: style.cardMargin / 2),
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
                                          color: style.primaryColor),
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
                            return GestureDetector(
                              onTap: () => controller.launchUrl(advs[index]),
                              child: Container(
                                margin: EdgeInsets.only(
                                  top: style.cardMargin / 2,
                                  bottom: style.cardMargin,
                                  left: style.cardMargin / 2,
                                  right: style.cardMargin / 2,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    //***image section
                                    Expanded(
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          CachedNetworkImage(
                                            imageUrl: advs[index].bannerLink,
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(
                                                        style
                                                            .cardBorderRadius)),
                                                image: DecorationImage(
                                                    colorFilter:
                                                        ColorFilter.mode(
                                                            colors[200]!
                                                                .withOpacity(
                                                                    .5),
                                                            BlendMode.darken),
                                                    image: imageProvider,
                                                    fit: BoxFit.cover,
                                                    filterQuality:
                                                        FilterQuality.medium),
                                              ),
                                            ),
                                            placeholder: (context, url) =>
                                                CupertinoActivityIndicator(),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Text(error.toString()),
                                          ),
                                        ],
                                      ),
                                    ),
                                    //***text section
                                    if (advs[index].title != '')
                                      Container(
                                        padding: EdgeInsets.all(
                                            style.cardMargin / 2),
                                        child: Text(
                                          advs[index].title,
                                          style: style
                                              .textHeaderLightStyle
                                              .copyWith(color: colors[50]),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                          itemCount: advs.length,
                        ),
                      ),
                  ]),
            ),
          ),
        );
      } else
        return Center();
    }, onLoading: Loader(), onEmpty: Center());
  }
}
