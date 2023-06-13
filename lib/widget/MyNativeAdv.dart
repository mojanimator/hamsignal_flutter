import 'package:adivery/adivery_ads.dart' as Adivery;
import 'package:hamsignal/controller/AdvController.dart';
import 'package:hamsignal/helper/helpers.dart';
import 'package:hamsignal/widget/MyNetWorkImage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tapsell_plus/tapsell_plus.dart';

import '../controller/SettingController.dart';
import '../helper/styles.dart';

class MyNativeAdv extends StatefulWidget {
  AdvController controller;
  Widget failedWidget;

  MyNativeAdv({required this.controller, required Widget this.failedWidget}) {}

  @override
  _MyNativeAdvState createState() => _MyNativeAdvState();
}

class _MyNativeAdvState extends State<MyNativeAdv> {
  AdiveryNativeAdWidget? nativeAdWidgetAdivery;
  TapsellNativeAdWidget? nativeAdWidgetTapsell;
  AdmobAdWidget? nativeAdWidgetAdmob;

  late Adivery.NativeAd nativeAdAdivery;
  NativeAd? nativeAdAdmob;

  late final SettingController settingController;

  late final Style style;

  @override
  void initState() {
    // TODO: implement initState
    settingController = Get.find<SettingController>();
    style = Get.find<Style>();

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // nativeAdAdivery?.destroy();
    if (settingController.adv.type['native'] == 'admob')
      nativeAdAdmob?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: prepareAd(),
      builder: (BuildContext context, AsyncSnapshot<Widget?> snapshot) {
        if (!snapshot.hasError && snapshot.hasData)
          return Container(
              height: style.cardVitrinHeight + style.cardBorderRadius,
              child: snapshot.data!);
        return Container(child: widget.failedWidget);
      },
    );
  }

  Future<Widget?> prepareAd() async {
    // try {
    await Helper.getAndroidInfo();
    var type = settingController.adv.type['native'];
    // print("****tapsell********$nativeAdWidgetTapsell");
    if (Helper.androidInfo == null || Helper.androidInfo!.version.sdkInt < 20)
      return null;
    if (type == 'tapsell') {
      if (nativeAdWidgetTapsell == null) {
        var responseId = await TapsellPlus.instance
            .requestNativeAd(/*'5cfaa9deaede570001d5553a'*/
                settingController.adv.keys[type]['native']);
        if (responseId != null && responseId.runtimeType != String)
          responseId = responseId['response_id'];
        if (responseId != null)
          await TapsellPlus.instance.showNativeAd(
            responseId,
            onOpened: (nativeAd) {
              // print( "******tapsell loaded   ${nativeAd.iconUrl}" );
              setState(() {
                nativeAdWidgetTapsell = TapsellNativeAdWidget(
                    responseId: nativeAd.responseId ?? '',
                    title: nativeAd.title ?? '',
                    description: nativeAd.description ?? '',
                    callToAction: nativeAd.callToActionText ?? '',
                    iconUrl: nativeAd.iconUrl ?? '',
                    portraitImageUrl: nativeAd.portraitImageUrl ?? '',
                    landScapeImageUrl: nativeAd.landscapeImageUrl ?? '',
                    onClick: () => Navigator.of(context).pop());
              });

              return nativeAdWidgetTapsell;
              // return nativeAdTapsell;
            },
            onError: (map) {
              print('******tapsell Ad error - Error: $map');
            },
          );
      }
      Future.delayed(Duration(seconds: 5));
      setState(() {
        nativeAdWidgetTapsell = nativeAdWidgetTapsell;
      });
      return nativeAdWidgetTapsell;
    } else if (type == 'adivery') {
      //
      if (nativeAdWidgetAdivery == null) {
        nativeAdAdivery = Adivery.NativeAd(
            settingController.adv.keys[type]['native'], onAdLoaded: () {
          setState(() {
            nativeAdWidgetAdivery =
                AdiveryNativeAdWidget(nativeAd: nativeAdAdivery);
          });
        }, onError: (error) {
          print("****Adivery native ad error $error");
          nativeAdWidgetAdivery = null;
        });
        nativeAdAdivery.loadAd();
      }
      return nativeAdWidgetAdivery;
      //
    } else if (type == 'admob') {
      // print("*********$nativeAdAdmob ");
      nativeAdAdmob ??= NativeAd(
        // adUnitId: 'ca-app-pub-3940256099942544/2247696110',
        adUnitId: settingController.adv.keys[type]['native'],
        request: AdvController.targetInfo,
        factoryId: 'adFactoryExample',
        listener: NativeAdListener(
          onAdLoaded: (Ad ad) {
            setState(() {
              nativeAdWidgetAdmob = AdmobAdWidget(nativeAd: nativeAdAdmob!);
            });
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            // print('$ad ***failedToLoad: $error');
            // settingController.adv.type['native'] = null;
            nativeAdWidgetAdmob = null;
            ad.dispose();
          },
          onAdOpened: (Ad ad) => print('$NativeAd onAdOpened.'),
          onAdClosed: (Ad ad) => print('$NativeAd onAdClosed.'),
        ),
      );
      await nativeAdAdmob?.load();
      await Future.delayed(Duration(seconds: 3), () {});
      return nativeAdWidgetAdmob;
    } else
      return null;
    // } on MissingPluginException catch (error) {
    //   print('******  Error native ad - $error');
    //   return Center();
    //   // Helper.settings['native_adv_provider'] = 'tapsell';
    // } catch (error) {
    //   print('******  catch native ad - $error');
    //   // Helper.settings['native_adv_provider'] = 'tapsell';
    //   return Center();
    // }
  }
}

class TapsellNativeAdWidget extends StatelessWidget {
  final String responseId;
  final String title;
  final String description;
  final String callToAction;
  final String iconUrl;
  final String portraitImageUrl;
  final String landScapeImageUrl;
  final Function onClick;
  late final Style style;

  TapsellNativeAdWidget(
      {required this.responseId,
      required this.title,
      required this.description,
      required this.callToAction,
      required this.iconUrl,
      required this.portraitImageUrl,
      required this.landScapeImageUrl,
      required this.onClick}) {
    style = Get.find<Style>();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        TapsellPlus.instance.nativeBannerAdClicked(responseId);
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        //
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: MyNetWorkImage(
          url: landScapeImageUrl.replaceFirst('https:', 'http:'),
          fit: BoxFit.fill,
          loadingWidgetBuilder: (percent) => Center(
            child: CupertinoActivityIndicator(),
          ),
          errorWidgetBuilder:
              (BuildContext context, object, dynamic stacktrace) => Center(
            child: Center(),
          ),
        ),
      ),
    );
  }
}

class AdiveryNativeAdWidget extends StatelessWidget {
  final Adivery.NativeAd nativeAd;

  AdiveryNativeAdWidget({
    required this.nativeAd,
  });

  @override
  Widget build(BuildContext context) {
    // if (nativeAd != null && nativeAd.isLoaded) {
    return InkWell(
      splashColor: Colors.white70,
      onTap: () async {
        nativeAd.recordClick();
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: nativeAd.image,
      ),
    );
    // } else {
    //   return Center();
    // }
  }
}

class AdmobAdWidget extends StatelessWidget {
  final AdWithView nativeAd;

  AdmobAdWidget({
    required this.nativeAd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // clipBehavior: Clip.antiAlias,
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: AdWidget(
        ad: nativeAd,
      ),
    );
  }
}
