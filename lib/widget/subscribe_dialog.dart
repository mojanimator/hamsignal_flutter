import 'package:hamsignal/controller/SettingController.dart';
import 'package:hamsignal/controller/UserController.dart';
import 'package:hamsignal/helper/IAPPurchase.dart';
import 'package:hamsignal/helper/helpers.dart';
import 'package:hamsignal/helper/styles.dart';
import 'package:hamsignal/helper/variables.dart';
import 'package:hamsignal/widget/mini_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubscribeDialog extends StatelessWidget {
  RxBool couponLoading = RxBool(false);
  late RxMap<String, dynamic> discounts;
  late Map<String, dynamic> initDiscounts;
  final SettingController settingController = Get.find<SettingController>();
  final UserController userController = Get.find<UserController>();
  final Style style = Get.find<Style>();
  MaterialColor colors;
  RxString renewMonth = RxString('1');
  RxString coupon = RxString('');
  RxBool loading = RxBool(false);
  String type;
  Function(Map<String, dynamic> params) onPressed;
  final IAPPurchase iAPPurchase = Get.find<IAPPurchase>();

  String id;

  SubscribeDialog(
      {Key? key,
      required this.colors,
      required this.type,
      required this.id,
      required Function(Map<String, dynamic> params) this.onPressed})
      : super(key: key) {
    initDiscounts = {
      for (var item
          in iAPPurchase.products.where((e) => e.consumable == '${type}'))
        item.id: item.price
    };
    discounts = RxMap(initDiscounts);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Center(
          child: MiniCard(
            title: "subscribe_type".tr,
            colors: colors,
            desc1: "",
            style: style,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                      mainAxisSize: MainAxisSize.min,
                      children: iAPPurchase.products
                          .where((el) => el.consumable == type)
                          .map((e) => InkWell(
                                onTap: () => renewMonth.value = e.value,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Radio<String>(
                                          fillColor: MaterialStateProperty.all(
                                              colors[500]),
                                          value: e.value,
                                          groupValue: renewMonth.value,
                                          onChanged: (value) {
                                            renewMonth.value = "$value";
                                          },
                                          activeColor: Colors.green,
                                        ),
                                        Text(e.name,
                                            style:
                                                TextStyle(color: colors[500])),
                                      ],
                                    ),
                                    Text(
                                      "${e.price}".asPrice(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: colors[500],
                                          decoration:
                                              int.parse(discounts.value[e.id]) <
                                                      int.parse(e.price)
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none),
                                    ),
                                    Visibility(
                                      visible:
                                          int.parse(discounts.value[e.id]) <
                                              int.parse(e.price),
                                      child: Text(
                                        "${discounts.value[e.id]}".asPrice(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: colors[500]),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList()),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                            flex: 3,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: style.cardMargin),
                              margin: EdgeInsets.symmetric(
                                  vertical: style.cardMargin / 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                //background color of dropdown button
                                border: Border.all(
                                    color: style.primaryColor, width: 1),
                                //border of dropdown button
                                borderRadius: BorderRadius.horizontal(
                                  right: Radius.circular(
                                      style.cardBorderRadius / 2),
                                  left: Radius.circular(0),
                                ), //border raiuds of dropdown button
                              ),
                              child: TextField(
                                autofocus: true,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: style.primaryColor,
                                ),
                                onChanged: (str) {
                                  coupon.value = str;
                                  discounts.value = initDiscounts;
                                },
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'coupon'.tr,
                                ),
                              ),
                            )),
                        Expanded(
                          flex: 2,
                          child: TextButton(
                              style: ButtonStyle(
                                  padding: MaterialStateProperty.all(
                                      EdgeInsets.all(style.cardMargin / 1)),
                                  overlayColor:
                                      MaterialStateProperty.resolveWith(
                                    (states) {
                                      return states
                                              .contains(MaterialState.pressed)
                                          ? style.secondaryColor
                                          : null;
                                    },
                                  ),
                                  backgroundColor:
                                      MaterialStateProperty.all(colors[700]),
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.horizontal(
                                      right: Radius.circular(0),
                                      left: Radius.circular(
                                          style.cardBorderRadius / 2),
                                    ),
                                  ))),
                              onPressed: () async {
                                couponLoading.value = true;
                                Map<String, dynamic>? res = await userController
                                    .calculateCoupon(params: {
                                  'type': type,
                                  'coupon': coupon.value,
                                  'renew-month': renewMonth.value,
                                });

                                if (res != null) {
                                  for (var item in res.keys)
                                    discounts.value = res.map((key, value) =>
                                        MapEntry(key, value.toString()));
                                } else {
                                  discounts.value = initDiscounts;
                                }
                                couponLoading.value = false;
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${'append'.tr}",
                                    style: style.textMediumLightStyle,
                                  ),
                                  couponLoading.value
                                      ? CupertinoActivityIndicator(
                                          color: colors[50],
                                        )
                                      : SizedBox(
                                          width: 32,
                                        ),
                                ],
                              )),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(style.cardMargin / 2),
                    child: Visibility(
                        visible: loading.value,
                        child: LinearProgressIndicator(
                          color: colors[500],
                        )),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                            style: ButtonStyle(
                                padding: MaterialStateProperty.all(
                                    EdgeInsets.all(style.cardMargin)),
                                overlayColor: MaterialStateProperty.resolveWith(
                                  (states) {
                                    return states
                                            .contains(MaterialState.pressed)
                                        ? style.secondaryColor
                                        : null;
                                  },
                                ),
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.green),
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(style.cardBorderRadius / 2),
                                  ),
                                ))),
                            onPressed: () async {
                              loading.value = true;
                              Map<String, dynamic> params = {
                                'month': renewMonth.value,
                                'coupon': coupon.value,
                                'type': type,
                                'id': id,
                                'market': Variables.MARKET,
                                // 'price': iAPPurchase.allProducts
                                //     .firstWhereOrNull((el) {
                                //   return el.month == renewMonth.value &&
                                //       el.type == type && Variables.MARKET!='bank';
                                // })?.price,
                              };
                              var res = await iAPPurchase.purchase(
                                  params: params, mode: 'edit');
                              // if (res != null && res['url'] != null) {
                              //   Uri url = Uri.parse(res['url']);
                              //   //100% discount=>dont go to bank
                              //   if (res['url'].contains('panel'))
                              //     Get.back(result: 'done');
                              //   else if (await canLaunchUrl(url)) {
                              //     launchUrl(url);
                              //   }
                              // }

                              loading.value = false;
                            },
                            child: Text(
                              "${'pay'.tr}",
                              style: style.textMediumLightStyle
                                  .copyWith(fontWeight: FontWeight.bold),
                            )),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: style.cardMargin / 2,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                            style: ButtonStyle(
                                padding: MaterialStateProperty.all(
                                    EdgeInsets.all(style.cardMargin)),
                                overlayColor: MaterialStateProperty.resolveWith(
                                  (states) {
                                    return states
                                            .contains(MaterialState.pressed)
                                        ? style.secondaryColor
                                        : null;
                                  },
                                ),
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.red),
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(style.cardBorderRadius / 2),
                                  ),
                                ))),
                            onPressed: () async {
                              Get.back();
                            },
                            child: Text(
                              "${'cancel'.tr}",
                              style: style.textMediumLightStyle
                                  .copyWith(fontWeight: FontWeight.bold),
                            )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
