import 'package:dabel_sport/controller/SettingController.dart';
import 'package:dabel_sport/helper/helpers.dart';
import 'package:dabel_sport/helper/styles.dart';
import 'package:dabel_sport/widget/mini_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscribeDialog extends StatelessWidget {
  RxBool couponLoading = RxBool(false);
  late RxMap<String, dynamic> discounts;
  late Map<String, dynamic> initDiscounts;
  final SettingController settingController = Get.find<SettingController>();
  final Style styleController = Get.find<Style>();
  MaterialColor colors;
  RxString renewMonth = RxString('1');
  RxString coupon = RxString('');
  RxBool loading = RxBool(false);
  String type;
  Function(Map<String, dynamic> params) onPressed;

  String id;

  SubscribeDialog(
      {Key? key,
      required this.colors,
      required this.type,
      required this.id,
      required Function(Map<String, dynamic> params) this.onPressed})
      : super(key: key) {
    initDiscounts = {
      for (var item in settingController.prices
          .where((e) => e['key'].contains('${type}')))
        item['key']: item['value']
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
            styleController: styleController,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                      mainAxisSize: MainAxisSize.min,
                      children: settingController.prices
                          .where((el) => el['key'].contains('$type'))
                          .map((e) => InkWell(
                                onTap: () =>
                                    renewMonth.value = e['key'].split('_')[1],
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Radio<String>(
                                          fillColor: MaterialStateProperty.all(
                                              colors[500]),
                                          value: e['key'].split('_')[1],
                                          groupValue: renewMonth.value,
                                          onChanged: (value) {
                                            renewMonth.value = "$value";
                                          },
                                          activeColor: Colors.green,
                                        ),
                                        Text(e['name'],
                                            style: TextStyle(color: colors[500])),
                                      ],
                                    ),
                                    Text(
                                      "${e['value']}".asPrice(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: colors[500],
                                          decoration:
                                              int.parse(discounts.value[e['key']]) <
                                                      int.parse(e['value'])
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none),
                                    ),
                                    Visibility(
                                      visible:
                                          int.parse(discounts.value[e['key']]) <
                                              int.parse(e['value']),
                                      child: Text(
                                        "${discounts.value[e['key']]}".asPrice(),
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
                                  horizontal: styleController.cardMargin),
                              margin: EdgeInsets.symmetric(
                                  vertical: styleController.cardMargin / 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                //background color of dropdown button
                                border: Border.all(
                                    color: styleController.primaryColor, width: 1),
                                //border of dropdown button
                                borderRadius: BorderRadius.horizontal(
                                  right: Radius.circular(
                                      styleController.cardBorderRadius / 2),
                                  left: Radius.circular(0),
                                ), //border raiuds of dropdown button
                              ),
                              child: TextField(
                                autofocus: true,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: styleController.primaryColor,
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
                                  padding: MaterialStateProperty.all(EdgeInsets.all(
                                      styleController.cardMargin / 1)),
                                  overlayColor: MaterialStateProperty.resolveWith(
                                    (states) {
                                      return states.contains(MaterialState.pressed)
                                          ? styleController.secondaryColor
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
                                          styleController.cardBorderRadius / 2),
                                    ),
                                  ))),
                              onPressed: () async {
                                couponLoading.value = true;
                                Map<String, dynamic>? res = await settingController
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
                                    style: styleController.textMediumLightStyle,
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
                  SizedBox(
                    height: styleController.cardMargin,
                  ),
                  Visibility(
                      visible: loading.value, child: CircularProgressIndicator()),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                            style: ButtonStyle(
                                padding: MaterialStateProperty.all(
                                    EdgeInsets.all(styleController.cardMargin)),
                                overlayColor: MaterialStateProperty.resolveWith(
                                  (states) {
                                    return states.contains(MaterialState.pressed)
                                        ? styleController.secondaryColor
                                        : null;
                                  },
                                ),
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.green),
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(
                                        styleController.cardBorderRadius / 2),
                                  ),
                                ))),
                            onPressed: () async {
                              loading.value = true;
                              Map<String, dynamic> params = {
                                'month': renewMonth.value,
                                'coupon': coupon.value,
                                'type': type,
                                'id': id,
                              };
                              var res = await settingController.makePayment(
                                  params: params);
                              if (res != null && res['url'] != null) {
                                Uri url = Uri.parse(res['url']);
                                //100% discount=>dont go to bank
                                if (res['url'].contains('panel'))
                                  Get.back(result: 'done');
                                else if (await canLaunchUrl(url)) {
                                  launchUrl(url);
                                }
                              }

                              loading.value = false;
                            },
                            child: Text(
                              "${'pay'.tr}",
                              style: styleController.textMediumLightStyle
                                  .copyWith(fontWeight: FontWeight.bold),
                            )),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: styleController.cardMargin / 2,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                            style: ButtonStyle(
                                padding: MaterialStateProperty.all(
                                    EdgeInsets.all(styleController.cardMargin)),
                                overlayColor: MaterialStateProperty.resolveWith(
                                  (states) {
                                    return states.contains(MaterialState.pressed)
                                        ? styleController.secondaryColor
                                        : null;
                                  },
                                ),
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.red),
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(
                                        styleController.cardBorderRadius / 2),
                                  ),
                                ))),
                            onPressed: () async {
                              Get.back();
                            },
                            child: Text(
                              "${'cancel'.tr}",
                              style: styleController.textMediumLightStyle
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
