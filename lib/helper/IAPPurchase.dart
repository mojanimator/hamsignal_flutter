import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:hamsignal/helper/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_poolakey/flutter_poolakey.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controller/APIProvider.dart';
import '../controller/SettingController.dart';
import '../controller/UserController.dart';
import '../model/Product.dart';
import '../widget/my_text_field.dart';
import 'helpers.dart';
import 'variables.dart';

class IAPPurchase {
  static String MARKET = 'bazaar';
  bool bazaarConnected = false;
  bool myketConnected = false;
  TextEditingController textCouponCtrl = TextEditingController();

  late ApiProvider apiProvider;
  late Helper helper;
  late UserController userController;
  late Style style;
  List<ProductItem> products = [];
  List plans = [];
  List<PurchaseInfo> allPurchases = <PurchaseInfo>[];

  /*** myket
      // List<Purchase> allPurchases = <Purchase>[];
   **/

  late SettingController settingController;

  IAPPurchase(
      {required Map<String, dynamic> keys,
      required List products,
      required List plans}) {
    apiProvider = Get.find<ApiProvider>();
    helper = Get.find<Helper>();
    userController = Get.find<UserController>();
    settingController = Get.find<SettingController>();
    style = Get.find<Style>();
    this.plans = plans;
    this.products = products.map<ProductItem>((e) {
      return ProductItem(
          id: e['key'],
          value: e['key'].split('-').length > 1 ? e['key'].split('-')[1] : '',
          name: e['name'],
          consumable: e['consumable'] == true,
          // price: "100");
          price: "${e['price']}");
    }).toList();
    init();
  }

  static dispose() async {
    /** myket
        await MyketIAP.dispose();
     **/
  }

  Future<void> init() async {
    await checkMarketsInstalled();
    await checkBeforePurchases();
  }

  checkMarketsInstalled() async {
    //check bazaar

    try {
      bazaarConnected = await FlutterPoolakey.connect(
          settingController.keys['BAZAAR_RSA'],
          onDisconnected: () => print("Poolakey disconnected!"));
      // print( "***bazaar connected $bazaarConnected");
    } catch (e) {
      print("***bazaar catch $e");
      // print(e.runtimeType == PlatformException);
      //bazaar not installed
    }

    /**** myket
        //check myket
        try {
        IabResult? result = await MyketIAP.init(
        rsaKey: settingController.keys['MYKET_RSA'],
        enableDebugLogging: true);
        myketConnected = result?.isSuccess() ?? false;
        } catch (e) {
        print("****myket init exception $e");
        }
     **/
  }

  Future<void> purchase(
      {Map<String, dynamic>? params, String mode = 'create'}) async {
    params = {
      ...(params ?? {}),
      'name': userController.user?.fullName,
      'package': settingController.appInfo.packageName,
      'phone': userController.user?.phone,
      'app_version': settingController.appInfo.buildNumber
    };

    var res = await makePayment(params: params);
    // print(res);
    if (res['status'] != 'success') {
      Get.back();
      helper.showToast(
          status: 'danger',
          msg: res['res'] != null ? res['res'] : 'check_network'.tr);
    } else if (res['market'] == null || res['market'] == 'bank') {
      Get.back();
      //idpay
      Uri url = Uri.tryParse(res['url']) ?? Uri.http('');
      helper.showToast(
          msg: res['message'] ?? 'check_network'.tr, status: res['status']);
      if (await canLaunchUrl(url)) {
        // helper.showToast(msg: 'pay_in_browser'.tr, status: 'success');
        launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } else if (res['market'] == 'bazaar') {
      var res2 = await purchaseBazaar(params: res);
      Get.back();
      // print("purchase result");
      // print(res2);

      if (res2 != null && res2['status'] != 'success')
        helper.showToast(msg: res2['msg'], status: 'danger');
      if (res2 != null && res2['status'] == 'success') {
        userController.getUser(refresh: true);
        helper.showToast(msg: res2['msg'], status: 'success');
      }
      // else if (res['url'] != null)
      // settingController.resolveDeepLink(Uri.parse(res['url']));
      // else
    }

    /*** myket
        else if (res['market'] == 'myket') {
        var res2 = await purchaseMyket(params: res);
        Get.back();
        // print("purchase result");
        // print(res2);

        if (res2 != null && res2['status'] != 'success')
        helper.showToast(msg: res2['msg'], status: 'danger');
        if (res2 != null && res2['status'] == 'success') {
        helper.showToast(msg: res2['msg'], status: 'success');
        userController.user = null;
        userController.getUser();
        }
        // else if (res['url'] != null)
        // settingController.resolveDeepLink(Uri.parse(res['url']));
        // else
        }
     **/
  }

  Future<dynamic> purchaseBazaar(
      {required Map<String, dynamic> params,
      PurchaseInfo? purchaseInfo}) async {
    try {
      // print('**** start purchase bazaar ');
      // print(params);
      if (!bazaarConnected) return null;

      if (purchaseInfo == null) {
        // if null=> consume before purchases

        // print(params);
        // print(params['consumable']);
        // print(params['consumable'].runtimeType);
        if (params['consumable'])
          purchaseInfo = await FlutterPoolakey.purchase(params['sku'],
              payload: jsonEncode({
                'market': Variables.MARKET,
                'user_id': params['user_id'],
                'amount': params['amount'],
              }),
              dynamicPriceToken: params['dynamicPriceToken']);
        else
          purchaseInfo = await FlutterPoolakey.subscribe(params['sku'],
              payload: jsonEncode({
                'market': Variables.MARKET,
                'user_id': params['user_id'],
                'amount': params['amount'],
              }),
              dynamicPriceToken: params['dynamicPriceToken']);

        // print("--bazaar purchase result:");
        // print(purchaseInfo.originalJson + "\n");
      }

      var consume = false;
      if (params['consumable'])
        consume = await FlutterPoolakey.consume(purchaseInfo.purchaseToken);

      params['info'] = purchaseInfo.originalJson;
      params['pay_id'] = purchaseInfo.purchaseToken;
      params['token'] = purchaseInfo?.purchaseToken;
      params['market'] = Variables.MARKET;
      params['order_id'] = purchaseInfo?.orderId;
      params['app_version'] = "${settingController.appInfo.buildNumber}";
      var result2 = {};
      if (consume == true ||
          (!params['consumable'] && userController.user?.expiresAt == null)) {
        params['consumable'] = params['consumable'] ? 1 : 0;
        // print("***_addBazaarPurchaseToServer");
        // print(params);
        result2 = await _addPurchaseToServer(params: params);
        // print(params);

        if (result2['status'] == 'success')
          return {
            'status': 'success',
            'msg': result2['message'] ?? "${'purchase_success'.tr}"
          };
      }

      return {
        'status': 'danger',
        'msg': result2['msg'] ?? result2['message'] ?? "${'purchase_failed'.tr}"
      };
    } on PlatformException catch (e) {
      // print('!!!!! bazaar platform exception:');
      // if (e.code == 'purchase_failed')
      // print(e.message);
      // print(e.details);
      if (e.code == 'purchase_cancelled')
        return {'status': 'danger', 'msg': "${'purchase_cancelled'.tr}"};
      return {'status': 'danger', 'msg': "${'purchase_failed'.tr}"};
    } catch (e) {
      // print('!!!!! bazaar exception:');
      // print(e);

      return {'status': 'danger', 'msg': "${'purchase_failed'.tr}"};
      return null;
    }
  }

  /**** myket
      Future<dynamic> purchaseMyket(
      {required Map<String, dynamic> params, Purchase? purchaseInfo}) async {
      try {
      // print('**** start purchase myket ');
      // print(params);
      if (!myketConnected) return null;
      IabResult? purchaseResult;
      if (purchaseInfo == null) {
      // if null=> consume before purchases
      Map result = await MyketIAP.launchPurchaseFlow(
      sku: params['sku'],
      payload: jsonEncode({
      'market': Variable.MARKET,
      'user_id': params['user_id'],
      'amount': params['amount'],
      }));
      purchaseResult = result[MyketIAP.RESULT];
      purchaseInfo = result[MyketIAP.PURCHASE];
      // print("*****myket purchaseResult******");
      // print(purchaseResult);
      // print("*****myket purchaseInfo******");
      // print(purchaseInfo);
      // print(params['consumable'].runtimeType);
      // print("--bazaar purchase result:");
      // print(purchaseInfo.originalJson + "\n");
      }

      Map consumeResult;
      // print("*****myket before******");
      // print(purchaseResult?.mResponse);

      if (purchaseInfo != null && purchaseInfo.mToken != '') {
      // print("*****myket consume******");

      consumeResult = await MyketIAP.consume(purchase: purchaseInfo);
      purchaseResult = consumeResult[MyketIAP.RESULT];
      // print("*****myket purchaseResult consume******");
      // print(purchaseResult);
      purchaseInfo = consumeResult[MyketIAP.PURCHASE];
      // print("*****myket purchaseInfo consume******");
      // print(purchaseInfo);
      }

      var result2 = {};
      if (purchaseResult != null && purchaseResult.mResponse == 0) {
      params['consumable'] = params['consumable'] ? 1 : 0;
      params['info'] = purchaseInfo?.mOriginalJson;
      params['pay_id'] = purchaseInfo?.mToken;
      // print("*****myket _addMyketPurchaseToServer");
      // print("$params");
      result2 = await _addPurchaseToServer(params: params);
      // print(result2);
      if (result2['status'] == 'success')
      return {'status': 'success', 'msg': "${'purchase_success'.tr}"};
      }
      return {
      'status': 'danger',
      'msg': result2['msg'] ?? "${'purchase_failed'.tr}"
      };
      } on PlatformException catch (e) {
      // print('!!!!! bazaar platform exception:');
      // if (e.code == 'purchase_failed')
      // print(e.message);
      // print(e.details);
      if (e.code == 'purchase_cancelled')
      return {'status': 'danger', 'msg': "${'purchase_cancelled'.tr}"};
      return {'status': 'danger', 'msg': "${'purchase_failed'.tr}"};
      } catch (e) {
      // print('!!!!! bazaar exception:');
      // print(e);

      return {'status': 'danger', 'msg': "${'purchase_failed'.tr}"};
      return null;
      }
      }
   **/

  ///
  Future<void> checkBeforePurchases() async {
    // await Future.delayed(Duration(seconds: 2));

    if (userController.ACCESS_TOKEN == '' ||
        userController.user == null ||
        userController.user?.id == null) return;

    //check cafebazaar
    if (bazaarConnected) {
      try {
        allPurchases.addAll(await FlutterPoolakey.getAllPurchasedProducts());
        // print("****consume before purchases ${allPurchases.length}");
        for (PurchaseInfo purchase in allPurchases) {
          Map<String, dynamic> info = json.decode(purchase.payload);
          // print(purchase.originalJson);
          // print(info);
          var res2 = await purchaseBazaar(params: {
            'consumable': true,
            'user_id': userController.user?.id,
            'title': products
                    .firstWhereOrNull((e) => e.id == purchase.productId)
                    ?.name ??
                '',
            'phone': userController.user?.phone,
            'telegram_id': null,
            'app_id': settingController.appInfo.packageName,
            'sku': purchase.productId,
            'token': purchase.purchaseToken,
            'info': purchase.originalJson,
            'market': info['market'],
            'amount': info['amount'],
          }, purchaseInfo: purchase);

          if (res2 != null && res2['status'] == 'success') {
            await userController.getUser(refresh: true);
            helper.showToast(msg: 'purchase_success'.tr, status: 'success');
          }
        }
        allPurchases.clear();

        allPurchases.addAll(await FlutterPoolakey.getAllSubscribedProducts());
        // print("****consume before subscribes ${allPurchases.length}");
        for (PurchaseInfo purchase in allPurchases) {
          if (userController.user?.expiresAt != null &&
              userController.user?.expiresAt != 0) break; //user have active sub
          Map<String, dynamic> info = json.decode(purchase.payload);
          var res = await purchaseBazaar(params: {
            'consumable': false,
            'user_id': userController.user?.id,
            'phone': userController.user?.phone,
            'telegram_id': null,
            'app_id': settingController.appInfo.packageName,
            'type': purchase.productId,
            'pay_id': purchase.purchaseToken,
            'info': purchase.originalJson,
            'market': info['market'],
            'amount': info['amount'],
          }, purchaseInfo: purchase);
          if (res != null && res['status'] == 'success') {
            userController.getUser(refresh: true);
            helper.showToast(msg: res['msg'], status: 'success');
          }
          await Future.delayed(
              Duration(
                seconds: 2,
              ), () async {
            await userController.getUser(refresh: true);
          });
        }
      } catch (e) {
        print("****before purchases catch $e");
      }
    }

    /*****myket***
        //check myket
        if (myketConnected) {
        try {
        Map result = await MyketIAP.queryInventory(querySkuDetails: false);
        IabResult purchaseResult = result[MyketIAP.RESULT];
        Inventory inventory = result[MyketIAP.INVENTORY];
        // print("****myket before purchases purchaseResult ");
        // print(purchaseResult);
        // print("****myket before purchases inventory ");
        // print(inventory);
        for (Purchase purchase in inventory.mPurchaseMap.values) {
        print(purchase);
        if (userController.user?.unlockSub != null &&
        userController.user?.unlockSub != 0) break; //user have active sub
        Map<String, dynamic> info = purchase?.mDeveloperPayload != null
        ? json.decode(purchase.mDeveloperPayload!)
        : {};
        purchaseMyket(params: {
        'consumable': false,
        'user_id': userController.user?.id,
        'phone': userController.user?.phone,
        'telegram_id': userController.user?.telegram_id,
        'app_id': Variable.APP_ID,
        'type': purchase.mSku,
        'pay_id': purchase.mToken,
        'info': purchase.mOriginalJson,
        'market': info['market'],
        'amount': info['amount'],
        }, purchaseInfo: purchase);
        await Future.delayed(
        Duration(
        seconds: 2,
        ), () async {
        userController.user = null;
        await userController.getUser();
        });
        }
        } catch (e) {
        print("****myket before purchases catch $e");
        }
        }
     */

    ///
  }

  Future<dynamic> _addPurchaseToServer({Map<String, dynamic>? params}) async {
    final parsedJson = await apiProvider.fetch(
      Variables.LINK_CONFIRM_PAYMENT,
      ACCESS_TOKEN: userController.ACCESS_TOKEN,
      param: params,
      method: 'post',
    );

    if (parsedJson == null) {
      return null;
    } else {
      dynamic res = parsedJson;

      return res;
    }
  }

//  renew subscribes
  Future<dynamic> makePayment({required Map<String, dynamic> params}) async {
    // print(bazaarConnected || myketConnected);

    if (bazaarConnected || myketConnected)
      params = {...params, 'market': Variables.MARKET};
    final parsedJson = await apiProvider.fetch(Variables.LINK_MAKE_PAYMENT,
        param: {...params},
        ACCESS_TOKEN: userController.ACCESS_TOKEN,
        method: 'post');
    if (parsedJson != null && parsedJson['dynamicPriceToken'] != null)
      parsedJson['status'] = 'success';
    return parsedJson ?? {};
  }

  showPayDialog(
      {required ProductItem product,
      required dynamic Function() onPayClicked}) {
    if (settingController.payment != null)
      Variables.MARKET = settingController.payment!;
    if (Variables.MARKET == 'bazaar' && !bazaarConnected)
      Variables.MARKET = 'bank';
    if (Variables.MARKET == 'myket' && !myketConnected)
      Variables.MARKET = 'bank';

    Rx<bool> loading = false.obs;

    Get.dialog(
      Material(
        color: Colors.transparent,
        child: StatefulBuilder(
          builder:
              (BuildContext context, void Function(void Function()) setState) {
            String message = "📌اطلاعات پرداخت\n" +
                "👤 ${product.name}\n" +
                "📦 " +
                "${product.price}".asPrice() +
                " تومان "
                    "\n"
                    "      صفحه پرداخت در ${Variables.MARKET == 'bazaar' ? 'کافه بازار' : Variables.MARKET == 'myket' ? 'مایکت' : 'مرورگر'} باز خواهد شد.\n";
            return Center(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(style.isBigSize ? 16 : 8),
                    color: Colors.white),
                padding: EdgeInsets.all(style.isBigSize ? 32 : 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(
                      () => Visibility(
                          visible: loading.value,
                          child: Center(
                              child: LinearProgressIndicator(
                            backgroundColor: style.primaryColor,
                          ))),
                    ),
                    Text(
                      message,
                      style: style.textMediumStyle,
                      textDirection: Variables.LANG == 'fa'
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: style.buttonStyle(
                              padding: EdgeInsets.all(4),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0))),
                            ),
                            onPressed: () async {
                              loading.value = true;
                              await onPayClicked();
                              loading.value = false;
                            },
                            icon: Icon(
                              Icons.check,
                              color: Colors.white,
                              textDirection: TextDirection.rtl,
                            ),
                            label: FittedBox(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'pay'.tr,
                                  style: style.textMediumLightStyle,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: style.isBigSize ? 16 : 8,
                        ),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: style.buttonStyle(
                                padding: EdgeInsets.all(4),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(10.0))),
                                backgroundColor: style.primaryMaterial[200]),
                            onPressed: () async {
                              Get.back();
                            },
                            icon: Icon(
                              Icons.clear,
                              color: Colors.white,
                              textDirection: TextDirection.rtl,
                            ),
                            label: FittedBox(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'cancel'.tr,
                                  style: style.textMediumLightStyle,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget showPlanDialog({required item}) {
    Rx<bool> loading = false.obs;
    String oldPrice = "${item['price']}";
    String price = "${item['price']}";
    return Material(
      color: Colors.transparent,
      child: StatefulBuilder(
        builder:
            (BuildContext context, void Function(void Function()) setState) {
          Rx<String> message = RxString("📌اطلاعات پرداخت\n" +
              "👤 ${item['name']}\n" +
              "📦 " +
              "${price}".asPrice() +
              " تومان "
                  "از کیف پول شما کسر خواهد شد");
          return Center(
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(style.cardMargin),
                  color: Colors.white),
              padding: EdgeInsets.all(style.cardMargin),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(
                    () => Visibility(
                        visible: loading.value,
                        child: Center(
                            child: LinearProgressIndicator(
                          backgroundColor: style.primaryColor,
                        ))),
                  ),
                  Obx(
                    () => Text(
                      message.value,
                      style: style.textMediumStyle,
                      textDirection: Variables.LANG == 'fa'
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                    ),
                  ),
                  SizedBox(
                    height: style.cardMargin * 2,
                  ),
                  Row(
                    children: [
                      Expanded(
                          flex: 3,
                          child: MyTextField(
                            controller: textCouponCtrl,
                            hintText: 'coupon'.tr,
                          )),
                      Expanded(
                        flex: 1,
                        child: Obx(
                          () => TextButton(
                              onPressed: () async {
                                loading.value = true;
                                Map res = (await userController.calculateCoupon(
                                        params: {
                                          'coupon': textCouponCtrl.text
                                        })) ??
                                    {};

                                if (res[item['key']] != null)
                                  price = "${res[item['key']]}";
                                else
                                  price = oldPrice;
                                message.value = "📌اطلاعات پرداخت\n" +
                                    "👤 ${item['name']}\n" +
                                    "📦 " +
                                    "${price}".asPrice() +
                                    " تومان "
                                        "از کیف پول شما کسر خواهد شد";

                                loading.value = false;
                              },
                              style: style.buttonStyle(),
                              child: loading.value
                                  ? CupertinoActivityIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      'append'.tr,
                                      style: style.textMediumLightStyle,
                                    )),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: style.cardMargin * 2,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: style.buttonStyle(
                            padding: EdgeInsets.all(4),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0))),
                          ),
                          onPressed: () async {
                            loading.value = true;
                            var res = await userController.buy({
                              'plan': item['key'],
                              'type': 'plan',
                              'coupon': textCouponCtrl.text
                            });

                            if (res != null &&
                                res['type'] != null &&
                                res['type'] == 'upgraded') {
                              Get.back();

                              // userController.user?.wallet=res['wallet'];
                              await userController.getUser(refresh: true);
                              helper.showToast(
                                  msg: res['message'] ?? 'done_successfully'.tr,
                                  status: 'success');
                            } else if (res == null || res['message'] != null) {
                              helper.showToast(
                                  msg: res?['message'] ?? 'buy_problem'.tr,
                                  status: 'danger');
                            }

                            loading.value = false;
                          },
                          icon: Icon(
                            Icons.check,
                            color: Colors.white,
                            textDirection: TextDirection.rtl,
                          ),
                          label: FittedBox(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'pay'.tr,
                                style: style.textMediumLightStyle,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: style.cardMargin,
                      ),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: style.buttonStyle(
                              padding: EdgeInsets.all(4),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0))),
                              backgroundColor: style.primaryMaterial[200]),
                          onPressed: () async {
                            Get.back();
                          },
                          icon: Icon(
                            Icons.clear,
                            color: Colors.white,
                            textDirection: TextDirection.rtl,
                          ),
                          label: FittedBox(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'cancel'.tr,
                                style: style.textMediumLightStyle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
