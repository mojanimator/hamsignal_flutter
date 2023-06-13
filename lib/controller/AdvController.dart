import 'dart:convert';
import 'dart:io';

import 'package:adivery/adivery.dart';
import 'package:hamsignal/controller/APIProvider.dart';
import 'package:hamsignal/controller/SettingController.dart';
import 'package:hamsignal/controller/UserController.dart';
import 'package:hamsignal/helper/helpers.dart';
import 'package:hamsignal/helper/variables.dart';
import 'package:hamsignal/model/adv.dart';
import 'package:hamsignal/widget/MyNetWorkImage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pushpole/pushpole.dart';
import 'package:tapsell_plus/tapsell_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:adivery/adivery_ads.dart' as Adivery;

class AdvController extends GetxController with StateMixin<Adv> {
  List<AdvItem> _data = [];
  bool loading = false;

  int maxFailedLoadAttempts = 3;

  int get currentLength => _data.length;

  List<AdvItem> get data => _data;

  set data(List<AdvItem> value) {
    _data = value;
  }

  late final apiProvider;
  late final SettingController settingController;
  late final UserController userController;
  late final Helper helper;

  static final AdRequest targetInfo = AdRequest(
    keywords: <String>[
      'ثنا',
      'عدل',
      'ابلاغ قضایی',
      'قضایی',
      'خدمات قضایی',
      'پلیس',
      'دادرسی',
      'شکواییه',
      'شکایت',
      'دادگاه',
      'وکیل',
      'وکالت',
      'قانون',
      'عدالت',
      'عدالت همراه',
    ],
    // contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  );

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;

  RewardedInterstitialAd? _rewardedInterstitialAd;
  int _numRewardedInterstitialLoadAttempts = 0;

  AdiveryNativeAdWidget? nativeAdWidgetAdivery;
  TapsellNativeAdWidget? nativeAdWidgetTapsell;
  AdmobAdWidget? nativeAdWidgetAdmob;
  int _numNativeLoadAttempts = 0;

  late Adivery.NativeAd nativeAdAdivery;
  NativeAd? nativeAdAdmob;

  AdvController() {
    apiProvider = Get.find<ApiProvider>();
    settingController = Get.find<SettingController>();
    userController = Get.find<UserController>();
    helper = Get.find<Helper>();
    initAdvertisers();
  }

  Widget nativeAdv() {
    return FutureBuilder(
      future: createNativeAdv(),
      builder: (BuildContext context, AsyncSnapshot<Widget?> snapshot) {
        if (!snapshot.hasError && snapshot.hasData) return snapshot.data!;

        return Center();
      },
    );
  }

  Future<Widget?> createNativeAdv() async {
    String type = settingController.adv.type['native'];
    // try {
    await Helper.getAndroidInfo();

    print("****type********$type");

    if (Helper.androidInfo == null || Helper.androidInfo!.version.sdkInt < 20)
      return Center();
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

              nativeAdWidgetTapsell = TapsellNativeAdWidget(
                  responseId: nativeAd.responseId ?? '',
                  title: nativeAd.title ?? '',
                  description: nativeAd.description ?? '',
                  callToAction: nativeAd.callToActionText ?? '',
                  iconUrl: nativeAd.iconUrl ?? '',
                  portraitImageUrl: nativeAd.portraitImageUrl ?? '',
                  landScapeImageUrl: nativeAd.landscapeImageUrl ?? '',
                  onClick: () => Get.back());

              return nativeAdWidgetTapsell;
              // return nativeAdTapsell;
            },
            onError: (map) {
              print('******tapsell Ad error - Error: $map');
              return Center();
            },
          );
      }
      await Future.delayed(Duration(seconds: 5));
      nativeAdWidgetTapsell = nativeAdWidgetTapsell;

      return nativeAdWidgetTapsell;
    } else if (type == 'adivery') {
      if (nativeAdWidgetAdivery == null) {
        nativeAdAdivery = Adivery.NativeAd(
            settingController.adv.keys[type]['native'], onAdLoaded: () {
          nativeAdWidgetAdivery =
              AdiveryNativeAdWidget(nativeAd: nativeAdAdivery);
        }, onError: (error) {
          print("****Adivery native ad error $error");
        });
        nativeAdAdivery.loadAd();
      }
      return nativeAdWidgetAdivery;
      //
    } else if (type == 'admob') {
      nativeAdAdmob ??= NativeAd(
        // adUnitId: 'ca-app-pub-3940256099942544/2247696110',
        adUnitId: settingController.adv.keys[type]['native'],
        request: targetInfo,
        factoryId: 'adFactoryExample',
        listener: NativeAdListener(
          onAdLoaded: (Ad ad) {
            print('******  admob Loaded - $ad');
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            print('******* $ad failedToLoad: $error');
            ad.dispose();
            // settingController.adv.type['native'] = null;
            return Center();
          },
          onAdOpened: (Ad ad) => print('$NativeAd onAdOpened.'),
          onAdClosed: (Ad ad) => print('$NativeAd onAdClosed.'),
        ),
      );
      print('*******nativeAdWidgetAdmob $nativeAdWidgetAdmob');
      // print('*******attemptAdmob $_numNativeLoadAttempts < $maxFailedLoadAttempts');
      if (nativeAdWidgetAdmob == null &&
          _numNativeLoadAttempts < maxFailedLoadAttempts) {
        print('*******attemptAdmob load');
        await nativeAdAdmob?.load();
        return AdmobAdWidget(
          nativeAd: nativeAdAdmob!,
        );
      }
      _numNativeLoadAttempts++;
      await Future.delayed(Duration(seconds: 5));
      return nativeAdWidgetAdmob;
    } else
      return Center();
    // } on MissingPluginException catch (error) {
    //   print('******  Error native ad - $error');
    //   return MyAdv();
    //   // Helper.settings['native_adv_provider'] = 'tapsell';
    // } catch (error) {
    //   print('******  catch native ad - $error');
    //   // Helper.settings['native_adv_provider'] = 'tapsell';
    //   return MyAdv();
    // }
  }

  createInterstitial() {
    InterstitialAd.load(
        adUnitId: Platform.isAndroid
            ? settingController.adv.keys['admob']['interstitial']
            : 'ca-app-pub-3940256099942544/4411468910',
        request: targetInfo,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              createInterstitial();
            }
          },
        ));
  }

  void showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        createInterstitial();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        createInterstitial();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  void createRewarded() {
    RewardedAd.load(
        adUnitId: Platform.isAndroid
            ? settingController.adv.keys['admob']['rewarded']
            : 'ca-app-pub-3940256099942544/1712485313',
        request: targetInfo,
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            print('$ad loaded.');
            _rewardedAd = ad;
            _numRewardedLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedAd failed to load: $error');
            _rewardedAd = null;
            _numRewardedLoadAttempts += 1;
            if (_numRewardedLoadAttempts < maxFailedLoadAttempts) {
              createRewarded();
            }
          },
        ));
  }

  void showRewarded() {
    if (_rewardedAd == null) {
      print('Warning: attempt to show rewarded before loaded.');
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        createRewarded();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        createRewarded();
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      print('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
    });
    _rewardedAd = null;
  }

  void _createRewardedInterstitialAd() {
    RewardedInterstitialAd.load(
        adUnitId: Platform.isAndroid
            ? 'ca-app-pub-3940256099942544/5354046379'
            : 'ca-app-pub-3940256099942544/6978759866',
        request: targetInfo,
        rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
          onAdLoaded: (RewardedInterstitialAd ad) {
            print('$ad loaded.');
            _rewardedInterstitialAd = ad;
            _numRewardedInterstitialLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedInterstitialAd failed to load: $error');
            _rewardedInterstitialAd = null;
            _numRewardedInterstitialLoadAttempts += 1;
            if (_numRewardedInterstitialLoadAttempts < maxFailedLoadAttempts) {
              _createRewardedInterstitialAd();
            }
          },
        ));
  }

  void showRewardedInterstitial() {
    if (_rewardedInterstitialAd == null) {
      print('Warning: attempt to show rewarded interstitial before loaded.');
      return;
    }
    _rewardedInterstitialAd!.fullScreenContentCallback =
        FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedInterstitialAd ad) =>
          print('$ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedInterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createRewardedInterstitialAd();
      },
      onAdFailedToShowFullScreenContent:
          (RewardedInterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createRewardedInterstitialAd();
      },
    );

    _rewardedInterstitialAd!.setImmersiveMode(true);
    _rewardedInterstitialAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      print('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
    });
    _rewardedInterstitialAd = null;
  }

  Future<Adv?> getData({Map<String, dynamic>? param}) async {
    loading = true;
    // settingController.adv.nativeWidget = await createNativeAdv();

    change(settingController.adv, status: RxStatus.success());
    loading = false;
    update();
  }

  void launchUrl(AdvItem advItem) async {
    if (await canLaunchUrlString(advItem.clickLink)) {
      advClicked(advItem.id);
      launchUrlString(advItem.clickLink, mode: LaunchMode.externalApplication);
    }
  }

  void advClicked(String id) async {
    var parsedJson = await apiProvider.fetch(
      Variables.LINK_ADV_CLICK,
      param: {'id': id},
      ACCESS_TOKEN: userController.ACCESS_TOKEN,
      method: 'post',
    );
    // print(parsedJson);
  }

  initAdvertisers() async {
    initAdmob();
    initAdivery();
    initTapsell();
  }

  initAdmob() async {
    MobileAds.instance.initialize();
  }

  initAdivery() async {
    AdiveryPlugin.initialize(settingController.adv.keys['adivery']['key']);
  }

  initTapsell() async {
    await TapsellPlus.instance
        .initialize(settingController.adv.keys['tapsell']['key']);
  }

  @override
  onInit() {
    // getData();

    super.onInit();
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _rewardedInterstitialAd?.dispose();
    super.dispose();
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

  TapsellNativeAdWidget(
      {required this.responseId,
      required this.title,
      required this.description,
      required this.callToAction,
      required this.iconUrl,
      required this.portraitImageUrl,
      required this.landScapeImageUrl,
      required this.onClick}) {}

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
    //   return MyAdv();
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
