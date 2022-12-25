import 'dart:convert';

import 'package:dabel_sport/controller/APIProvider.dart';
import 'package:dabel_sport/controller/SettingController.dart';
import 'package:dabel_sport/controller/UserController.dart';
import 'package:dabel_sport/helper/helpers.dart';
import 'package:dabel_sport/helper/variables.dart';
import 'package:flutter/services.dart';
import 'package:flutter_poolakey/flutter_poolakey.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class IAPPurchase {
  bool bazaarConnected = false;
  Map<String, dynamic> keys;
  late final ApiProvider apiProvider;
  late final Helper helper;
  late final UserController userController;
  List<PurchaseInfo> allPurchases = <PurchaseInfo>[];
  List<ProductItem> allProducts = <ProductItem>[];

  late SettingController settingController;

  IAPPurchase({required this.keys, required List products}) {
    init(products);
  }

  Future<void> init(List products) async {
    apiProvider = Get.find<ApiProvider>();
    helper = Get.find<Helper>();
    userController = Get.find<UserController>();
    settingController = Get.find<SettingController>();
    for (var el in products) {
      if (el != null && el['key'] != null && el['key'].endsWith('_price')) {
        allProducts.add(ProductItem(el['key'], el['name'],
            el['key'].split('_')[1], el['key'].split('_')[0], el['value']));
      }
    }

    if (Variables.MARKET == 'bazaar') {
      bazaarConnected = await FlutterPoolakey.connect(this.keys['bazaar'],
          onDisconnected: () => print("Poolakey disconnected!"));

      //get prices from bazaar panel
      return;
      List<SkuDetails> skuDetails = await FlutterPoolakey.getInAppSkuDetails(
          allProducts.map((e) => e.id).toList());
      for (SkuDetails detail in skuDetails) {
        String tmp = detail.price
            .replaceAll(' ', '')
            .replaceAll(',', '')
            .replaceAll('ریال', '')
            .toEng();
        //rial to toman
        tmp = tmp.substring(0, tmp.length - 1);
        // print(tmp);
        for (int i = 0; i < allProducts.length; i++)
          if (allProducts[i].id == detail.sku) allProducts[i].price = tmp;
      }
    }
  }

  Future<void> purchase(
      {Map<String, dynamic>? params, String mode = 'create'}) async {
    if (mode == 'edit') {
      params = await makePayment(params: params);
    }

    if (params == null) return;
    if (params['url'] != null) {
      //nextpay
      Uri url = Uri.parse(params['url']);
      //100% discount=>dont go to bank
      if (params['url'].contains('panel')) {
        Get.back(result: {'status': 'success', 'msg': 'done_successfully'.tr});
        settingController.resolveDeepLink(Uri.parse(params['url']));
      } else if (await canLaunchUrl(url)) {
        helper.showToast(msg: 'pay_in_browser'.tr, status: 'success');
        launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } else if (params['dynamicPriceToken'] != null) {
      var res = await purchaseBazaar(params: params);
      // print("purchase result");
      // print(res);
      if (res != null && res['status'] != 'success')
        helper.showToast(msg: res['msg'], status: 'danger');
      else if (res['url'] != null)
        settingController.resolveDeepLink(Uri.parse(res['url']));
      else
        Get.back(result: res);
    }
  }

  Future<dynamic> purchaseBazaar({required Map<String, dynamic> params}) async {
    try {
      if (!bazaarConnected)
        bazaarConnected = await FlutterPoolakey.connect(params['rsa'],
            onDisconnected: () => print("Poolakey disconnected!"));
      if (!bazaarConnected) return null;

      PurchaseInfo purchaseInfo = await FlutterPoolakey.purchase(params['sku'],
          payload: jsonEncode({'order_id': params['order_id']}),
          dynamicPriceToken: params['dynamicPriceToken']);
      // print("--bazaar purchase result:");
      // print(purchaseInfo.originalJson + "\n");

      var result = await FlutterPoolakey.consume(purchaseInfo.purchaseToken);
      params['token_id'] = purchaseInfo.purchaseToken;
      params['market'] = Variables.MARKET;
      var result2;
      if (result == true) {
        result2 = await _addBazaarPurchaseToServer(params: params);
        // print("_addBazaarPurchaseToServer");
        // print(result2);
        if (result2 != null &&
            result2['url'] != null &&
            result2['url'].contains('panel'))
          return {
            'url': result2['url'],
            'status': 'success',
            'msg': "${'done_successfully'.tr}"
          };
      }
      return {'status': 'danger', 'msg': "${'purchase_failed'.tr}"};
    } on PlatformException catch (e) {
      // print('!!!!! bazaar platform exception:');
      // print(e);
      if (e.code == 'PURCHASE_CANCELLED')
        return {'status': 'danger', 'msg': "${'purchase_cancelled'.tr}"};
      return {'status': 'danger', 'msg': "${'purchase_failed'.tr}"};
    } catch (e) {
      // print('!!!!! bazaar exception:');
      // print(e);

      return {'status': 'danger', 'msg': "${'purchase_failed'.tr}"};
      return null;
    }
  }

  // Future<void> _consumeBeforePurchases() async {
  //   allPurchases.addAll(await FlutterPoolakey.getAllPurchasedProducts());
  //   FlutterPoolakey.getInAppSkuDetails(skuIds)
  //   // var subscribes = await FlutterPoolakey.getAllSubscribedProducts();
  //
  //   // allPurchases.addAll(subscribes);
  //   for (PurchaseInfo purchase in allPurchases) {
  //     print(purchase.originalJson);
  //     // consumeBazaar(purchase);
  //   }
  //
  //
  //   for (var skuDetails in skuDetailsList) {
  //     if (skuDetails.sku == "trial_subscription") {
  //       var trialData = await FlutterPoolakey.checkTrialSubscription();
  //       var trial = TrialSubscription.fromSkuDetails(skuDetails);
  //       trial.isAvailable = trialData["isAvailable"];
  //       trial.trialPeriodDays = trialData["trialPeriodDays"];
  //       _productsMap[skuDetails.sku]?.skuDetails = skuDetails;
  //     } else {
  //       _productsMap[skuDetails.sku]?.skuDetails = skuDetails;
  //     }
  //
  //     // inject purchaseInfo
  //     PurchaseInfo? purchaseInfo;
  //     for (var p in allPurchases) {
  //       if (p.productId == skuDetails.sku) purchaseInfo = p;
  //     }
  //     _productsMap[skuDetails.sku]?.purchaseInfo = purchaseInfo;
  //
  //     print(_productsMap.toString());
  //   }
  // }

  Future<dynamic> _addBazaarPurchaseToServer(
      {Map<String, dynamic>? params}) async {
    final parsedJson = await apiProvider.fetch(
      Variables.LINK_CONFIRM_PAYMENT,
      ACCESS_TOKEN: userController.ACCESS_TOKEN,
      param: params,
    );

    if (parsedJson == null) {
      return null;
    } else {
      dynamic res = parsedJson;

      return res;
    }
  }

//  renew subscribes
  Future<dynamic> makePayment({required Map<String, dynamic>? params}) async {
    // print(params);
    var parsedJson = await apiProvider.fetch(
      Variables.LINK_MAKE_PAYMENT,
      param: params,
      ACCESS_TOKEN: userController.ACCESS_TOKEN,
      method: 'post',
    );

    if (parsedJson != null && parsedJson['errors'] != null) {
      helper.showToast(
          msg: parsedJson['errors']?[parsedJson['errors'].keys.elementAt(0)]
              ?[0],
          status: 'danger');
      return null;
    }

    return parsedJson;
  }
}

class ProductItem {
  String id;
  String month;
  String name;
  String type;
  String price;

  // final String icon;
  // final bool consumable;
  // SkuDetails? skuDetails;
  // PurchaseInfo? purchaseInfo;

  ProductItem(this.id, this.name, this.month, this.type, this.price);
}

class TrialSubscription extends SkuDetails {
  bool isAvailable = false;
  int trialPeriodDays = 0;

  TrialSubscription(
      String sku, String type, String price, String title, String description)
      : super(sku, type, price, title, description);

  static TrialSubscription fromSkuDetails(SkuDetails skuDetails) {
    return TrialSubscription(skuDetails.sku, skuDetails.type, skuDetails.price,
        skuDetails.title, skuDetails.description);
  }
}
