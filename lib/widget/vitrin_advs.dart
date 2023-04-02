import 'package:cached_network_image/cached_network_image.dart';
import 'package:dabel_adl/controller/LinkController.dart';
import 'package:dabel_adl/controller/SettingController.dart';
import 'package:dabel_adl/helper/styles.dart';
import 'package:dabel_adl/model/Link.dart';
import 'package:dabel_adl/widget/MyNetWorkImage.dart';
import 'package:dabel_adl/widget/banner_card.dart';
import 'package:dabel_adl/widget/loader.dart';
import 'package:dabel_adl/widget/shakeanimation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'ScrollingText.dart';

class AdvVitrin extends StatelessWidget {
  late Style styleController;
  late LinkController linkController;
  late SettingController settingController;
  late MaterialColor colors;
  late EdgeInsets margin;
  RxDouble _dividerWidth = 0.0.obs;
  final _key = Get.key;

  LinkVitrin({EdgeInsets? margin, MaterialColor? colors}) {
    this.margin = margin ??
        EdgeInsets.symmetric(
          vertical: styleController.cardMargin / 8,
          horizontal: styleController.cardMargin,
        );
    styleController = Get.find<Style>();
    settingController = Get.find<SettingController>();
    linkController = Get.find<LinkController>();
    this.colors = colors ?? styleController.primaryMaterial;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _dividerWidth.value = (_key.currentContext?.size?.width ?? 0) / 2;

      await linkController.getData(param: {'page': 'clear'});

      //   Future.delayed(
      //       Duration(seconds: 1),
      //       () => Get.to(PlayerCreate(),
      //           transition: Transition.circularReveal,
      //           duration: Duration(milliseconds: 500)));
      //   //   var data=await LatestController().find({'id':'20','type':'cl'});
      //   // Get.to(ClubDetails(data: data, colors: styleController.cardClubColors));
    });
  }

  @override
  Widget build(BuildContext context) {
    return linkController.obx((data) {
      if (data != null && data.length > 0) {
        var first = data[0];
        data.removeWhere((e) => e.name.contains('ثنا'));
        return ShakeWidget(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(styleController.cardBorderRadius),
            ),
            shadowColor: styleController.primaryColor.withOpacity(.3),
            color: styleController.secondaryColor,
            elevation: 20,
            margin: margin,
            child: Padding(
                padding: EdgeInsets.all(styleController.cardMargin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(styleController.cardMargin / 2),
                      child: Text(
                        'links'.tr,
                        style: styleController.textHeaderStyle
                            .copyWith(color: colors[900]),
                        textAlign: TextAlign.right,
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
                    BannerCard(
                      margin: EdgeInsets.all(  styleController.cardMargin ),
                      onClick: () => linkController.launchUrl(first),
                      background: 'back6.png',
                      titleColor: styleController.primaryColor,
                      title: first.name,
                      icon: linkController.getIconLink(first.id),
                    ),
                    if (false)
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              styleController.cardBorderRadius / 2),
                        ),
                        child: ListTile(
                          contentPadding:
                              EdgeInsets.all(styleController.cardMargin),
                          onTap: () => linkController.launchUrl(data[0]),
                          leading: MyNetWorkImage(
                            width: styleController.cardVitrinHeight / 2,
                            url: linkController.getIconLink(data[0].id),
                            loadingWidgetBuilder: (double) =>
                                CupertinoActivityIndicator(),
                            fit: BoxFit.contain,
                          ),
                          title: Text(
                            first.name,
                            maxLines: 2,
                            style: styleController.textMediumStyle,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    GridView(
                        padding: EdgeInsets.zero,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          mainAxisSpacing: styleController.cardMargin/2,
                            crossAxisCount: styleController.linksGridCount,
                            childAspectRatio: styleController.linksRatio),
                        children: renderItems(data)),
                    // Center(
                    //   child: Wrap(
                    //       // spacing: styleController.cardMargin / 4,
                    //       crossAxisAlignment: WrapCrossAlignment.center,
                    //       alignment: WrapAlignment.center,
                    //       children: renderItems(data)),
                    // ),
                  ],
                )),
          ),
        );
      } else
        return Center();
    }, onLoading: Loader(), onEmpty: Center());
  }

  List<Widget> renderItems(List<Link>? data) {
    bool first = true;

    return (data ?? []).map<Widget>((link) {
      return BannerCard(
        onClick: () => linkController.launchUrl(link),
        background: 'back6.png',
        titleColor: styleController.primaryColor,
        title: link.name,
        icon: linkController.getIconLink(link.id),
      );
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(styleController.cardBorderRadius / 2),
        ),
        child: TextButton(
          onPressed: () {
            linkController.launchUrl(link);
          },
          child: Column(
            children: [
              MyNetWorkImage(
                height: styleController.iconHeight,
                url: linkController.getIconLink(link.id),
                loadingWidgetBuilder: (double) => CupertinoActivityIndicator(),
                fit: BoxFit.contain,
              ),

              // IntrinsicWidth(
              //   child: SingleChildScrollView(
              //     scrollDirection: Axis.horizontal,
              //     physics: BouncingScrollPhysics(),
              //     child: Text(
              //       link.name,
              //       softWrap: true,
              //       maxLines: 2,
              //       textAlign: TextAlign.center,
              //     ),
              //   ),
              // ),
              // Expanded(child: ScrollingText(text: link.name, reverse: false)),
              Padding(
                padding: EdgeInsets.all(styleController.cardMargin / 2),
                child: Text(
                  link.name,
                  style: styleController.textSmallStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ),
      );
    }).toList();
  }
}
