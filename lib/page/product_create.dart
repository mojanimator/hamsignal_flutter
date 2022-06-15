import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:dabel_sport/controller/AnimationController.dart';
import 'package:dabel_sport/controller/ProductController.dart';
import 'package:dabel_sport/controller/SettingController.dart';
import 'package:dabel_sport/helper/styles.dart';
import 'package:dabel_sport/widget/MyGallery.dart';
import 'package:dabel_sport/widget/mini_card.dart';
import 'package:dabel_sport/widget/shakeanimation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductCreate extends StatelessWidget {
  ProductController controller = Get.find<ProductController>();
  final SettingController settingController = Get.find<SettingController>();

  Map<String, dynamic> data = {
    'name': ''.obs,
    'description': ''.obs,
    'coupon': ''.obs,
    'count': ''.obs,
    'group_id': ''.obs,
    'shop': ''.obs,
    'shop_id': ''.obs,
    'price': ''.obs,
    'discount_price': ''.obs,
    'tags': ''.obs,
  };
  late TextStyle titleStyle;
  final MyAnimationController animationController =
      Get.find<MyAnimationController>();
  final Style styleController = Get.find<Style>();
  late MaterialColor colors;
  final ImagePicker _picker = ImagePicker();
  Rx<CroppedFile?>? croppedImage = Rx<CroppedFile?>(null);

  late Widget plusIcon;
  late Widget plusImage;

  late RxMap<String, dynamic> discounts;
  late Map<String, dynamic> initDiscounts;

  RxDouble uploadPercent = RxDouble(0.0);
  RxBool loading = RxBool(false);
  RxBool couponLoading = RxBool(false);
  Map<String, dynamic> tcs = Map<String, dynamic>();

  ProductCreate() {
    colors = styleController.cardProductColors;
    titleStyle = styleController.textMediumStyle.copyWith(color: colors[900]);
    plusImage = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_a_photo,
          color: colors[500],
          size: styleController.imageHeight / 2,
        ),
        Text(
          "${'image'.tr} ${'license'.tr}",
          style: styleController.textMediumStyle.copyWith(color: colors[500]),
        )
      ],
    );
    plusIcon = Icon(
      Icons.add_circle_outline_sharp,
      color: colors[500],
      size: styleController.imageHeight / 3,
    );
    initDiscounts = {
      for (var item in settingController.prices
          .where((e) => e['key'].contains('product')))
        item['key']: item['value']
    };
    discounts = RxMap(initDiscounts);
    data.addAll({
      'images[]': Rx<List<String>>(
          [for (int i = 0; i < settingController.limits['product']; i++) ''])
    });
    data.addAll({
      'license': ''.obs,
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Scaffold(
      bottomSheet: SizeTransition(
        sizeFactor: animationController.bottomNavigationBarController,
        child: Row(
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
                      backgroundColor: MaterialStateProperty.all(Colors.green),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(
                              styleController.cardBorderRadius / 2),
                        ),
                      ))),
                  onPressed: () async {
                    loading.value = true;
                    // tcs['name'].text = 'aaa';
                    // // tcs['family'].text = 'aaa';
                    // data['province'].value = '1';
                    // data['county'].value = '1';
                    //
                    // tcs['address'].text = 'dsdasdad fw dsa dsad';
                    // // tcs['coupon'].text = 'bbbb';
                    // tcs['phone'].text = '09018945844';

                    tcs.forEach((key, value) {
                      data[key].value = value.text;
                    });

                    var res = await controller.create(
                        params: data
                            .map((key, value) => MapEntry(key, value.value)),
                        onProgress: (percent) {
                          // print("percent ${percent.toStringAsFixed(0)}");
                          uploadPercent.value = percent;
                        });
                    loading.value = false;
                    if (res != null && res['url'] != null) {
                      Uri url = Uri.parse(res['url']);
                      //100% discount=>dont go to bank
                      if (res['url'].contains('panel'))
                        Get.back(result: 'done');
                      else if (await canLaunchUrl(url)) {
                        Get.back(result: 'done');
                        launchUrl(url);
                      }
                    }
                  },
                  child: Text(
                    "${'reg'.tr} ${'product'.tr}",
                    style: styleController.textMediumLightStyle
                        .copyWith(fontWeight: FontWeight.bold),
                  )),
            ),
          ],
        ),
      ),
      body: ShakeWidget(
        child: Stack(
          fit: StackFit.expand,
          children: [
            //profile section
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height:
                        Get.height / 3 + styleController.cardBorderRadius * 2,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          colorFilter: ColorFilter.mode(
                              colors[500]!.withOpacity(.1), BlendMode.multiply),
                          image: imageProvider(croppedImage?.value),
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.low),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),

            NotificationListener(
              onNotification: animationController.handleScrollNotification,
              child: ListView(children: [
                Container(
                  height: styleController.topOffset,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(
                              styleController.cardBorderRadius * 2),
                          topLeft: Radius.circular(
                              styleController.cardBorderRadius * 2))),
                  child: Transform.translate(
                    offset: Offset(0, -styleController.imageHeight / 2),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Padding(
                              padding:
                                  EdgeInsets.all(styleController.cardMargin),
                            )
                          ],
                        ),
                        Container(
                          child: Padding(
                              padding: EdgeInsets.all(
                                  styleController.cardMargin / 4),
                              child: Column(
                                children: [
                                  Hero(
                                    tag: 'gallery',
                                    child: MyGallery(
                                        title: "${'images'.tr} ${'product'.tr}",
                                        mode: 'create',
                                        limit:
                                            settingController.limits['product'],
                                        items: [],
                                        height:
                                            styleController.cardVitrinHeight,
                                        ratio: settingController
                                            .cropRatio['product']!
                                            .toDouble(),
                                        autoplay: false,
                                        fullScreen: false,
                                        colors: colors,
                                        styleController: styleController,
                                        infoText: '',
                                        onChanged: (index, File? file) async {
                                          if (file != null)
                                            data['images[]'].value[index] =
                                                "image/${file.path.split('.').last};base64," +
                                                    base64.encode(await file
                                                        .readAsBytes());
                                          else
                                            data['images[]'].value[index] = '';
                                        }),
                                  ),
                                  Obx(
                                    () => Column(
                                      children: [
                                        MiniCard(
                                          colors:
                                              styleController.cardProductColors,
                                          title: "${'name'.tr} ${'product'.tr}",
                                          desc1: data['name'].value,
                                          desc2: null,
                                          styleController: styleController,
                                          child: showEditDialog(params: {
                                            'name': data['name'].value,
                                          }),
                                        ),
                                        MiniCard(
                                          colors:
                                              styleController.cardProductColors,
                                          title: "${'group_id'.tr}",
                                          desc1: '',
                                          desc2: null,
                                          styleController: styleController,
                                          child: showEditDialog(dropdowns: {
                                            'group_id':
                                                settingController.sports,
                                          }),
                                        ),
                                        MiniCard(
                                          colors:
                                              styleController.cardProductColors,
                                          title: "${'shop'.tr}",
                                          desc1: '',
                                          desc2: null,
                                          styleController: styleController,
                                          child: showEditDialog(dropdowns: {
                                            'shop': controller.getUserShops(),
                                          }),
                                        ),
                                        MiniCard(
                                          colors:
                                              styleController.cardProductColors,
                                          title: "${'count'.tr}",
                                          desc1: '',
                                          desc2: null,
                                          styleController: styleController,
                                          child: IntrinsicHeight(
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: Container(
                                                    margin: EdgeInsets.all(
                                                        styleController
                                                                .cardMargin /
                                                            4),
                                                    child: Ink(
                                                      decoration: BoxDecoration(
                                                        color: colors[500],
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                styleController
                                                                        .cardBorderRadius /
                                                                    2),
                                                      ),
                                                      child: InkWell(
                                                        onTap: () {
                                                          int? txt =
                                                              int.tryParse(
                                                                  tcs['count']
                                                                      .text);
                                                          if (txt == null)
                                                            tcs['count'].text =
                                                                '0';
                                                          else
                                                            tcs['count'].text =
                                                                "${txt + 1}";
                                                        },
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                styleController
                                                                        .cardBorderRadius /
                                                                    2),
                                                        splashColor:
                                                            colors[800],
                                                        child: Center(
                                                          child: Icon(
                                                            Icons.add,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child:
                                                      showEditDialog(params: {
                                                    'count':
                                                        data['count'].value,
                                                  }),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Container(
                                                    margin: EdgeInsets.all(
                                                        styleController
                                                                .cardMargin /
                                                            4),
                                                    child: Ink(
                                                      decoration: BoxDecoration(
                                                        color: colors[500],
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                styleController
                                                                        .cardBorderRadius /
                                                                    2),
                                                      ),
                                                      child: InkWell(
                                                        onTap: () {
                                                          int? txt =
                                                              int.tryParse(
                                                                  tcs['count']
                                                                      .text);
                                                          if (txt == null)
                                                            tcs['count'].text =
                                                                '0';
                                                          else
                                                            tcs['count'].text =
                                                                "${txt - 1 < 0 ? 0 : txt - 1}";
                                                        },
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                styleController
                                                                        .cardBorderRadius /
                                                                    2),
                                                        splashColor:
                                                            colors[800],
                                                        child: Center(
                                                          child: Icon(
                                                            Icons.remove,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        MiniCard(
                                          colors:
                                              styleController.cardProductColors,
                                          title:
                                              "${'price'.tr} ( ${'currency'.tr} )",
                                          desc1: '',
                                          desc2: null,
                                          styleController: styleController,
                                          child: showEditDialog(params: {
                                            'price': data['price'].value,
                                          }),
                                        ),
                                        MiniCard(
                                          colors:
                                              styleController.cardProductColors,
                                          title:
                                              "${'discount_price'.tr} ${'optional'.tr}",
                                          desc1: '',
                                          desc2: null,
                                          styleController: styleController,
                                          child: showEditDialog(params: {
                                            'discount_price':
                                                data['discount_price'].value,
                                          }),
                                        ),
                                        MiniCard(
                                            colors: styleController
                                                .cardProductColors,
                                            title: 'description'.tr,
                                            desc1:
                                                "${data['description'] ?? ''}",
                                            desc2: null,
                                            styleController: styleController,
                                            child: showEditDialog(params: {
                                              'description':
                                                  data['description'].value,
                                            })),
                                        MiniCard(
                                            colors: styleController
                                                .cardProductColors,
                                            title:
                                                "${'tags'.tr} ${'every_in_one_row'.tr}",
                                            desc1: "${data['tags'] ?? ''}",
                                            desc2: null,
                                            styleController: styleController,
                                            child: showEditDialog(params: {
                                              'tags': data['tags'].value,
                                            })),
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
            Visibility(
              visible: loading.value,
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(styleController.cardBorderRadius),
                ),
                backgroundColor: colors[50],
                elevation: 5,
                insetPadding: EdgeInsets.all(styleController.cardMargin),
                child: Padding(
                  padding: EdgeInsets.all(styleController.cardMargin),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: colors[500],
                      ),
                      Text(
                        "${uploadPercent.value.toStringAsFixed(0)} %",
                        style: styleController.textBigStyle,
                      ),
                      LinearProgressIndicator(
                        value: uploadPercent.value / 100,
                        color: colors[500],
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget showEditDialog(
      {Map<String, dynamic> params = const {},
      Map<String, dynamic> dropdowns = const {}}) {
    if (dropdowns.keys.length > 0) {
      return Column(
        children: dropdowns.keys.map(
          (key) {
            List<DropdownMenuItem> items =
                dropdowns[key].map<DropdownMenuItem>((e) {
              return DropdownMenuItem(
                child: Container(
                  child: Center(child: Text(e['name'])),
                ),
                value: e['id'],
              );
            }).toList();
            return Padding(
              padding: EdgeInsets.all(styleController.cardMargin / 2),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  //background color of dropdown button
                  border: Border.all(color: colors[500]!, width: 1),
                  //border of dropdown button
                  borderRadius: BorderRadius.circular(
                      styleController.cardBorderRadius /
                          2), //border raiuds of dropdown button
                ),
                child: DropdownButton<dynamic>(
                  elevation: 10,

                  borderRadius:
                      BorderRadius.circular(styleController.cardBorderRadius),
                  dropdownColor: Colors.white,
                  underline: Container(),
                  items: items,
                  isExpanded: true,
                  value: data[key].value != '' ? data[key].value : null,
                  icon: Center(),
                  // underline: Container(),
                  hint: Center(
                      child: Text(
                    key.tr + '...',
                    style: TextStyle(color: colors[500]),
                  )),

                  onChanged: (idx) {
                    // data[key].value = dropdowns[key].where((e)=>e['id']);

                    data[key].value = idx;
                  },
                  selectedItemBuilder: (BuildContext context) => dropdowns[key]
                      .map<Widget>((el) => Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  styleController.cardBorderRadius / 2),
                              color: colors[500],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    data[key].value = '';
                                  },
                                  icon: Icon(Icons.close),
                                  color: Colors.white,
                                ),
                                Expanded(
                                  child: Center(
                                      child: Text(
                                    el['name'],
                                    style: styleController.textMediumLightStyle,
                                  )),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            );
          },
        ).toList(),
      );
    } else {
      dialog(List<Widget> children, Function callback) {
        // Get.dialog(
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...children,
            ],
          ),
        )
            //     ,
            // barrierDismissible: true,
            // )
            ;
      }

      for (var k in params.keys)
        tcs.putIfAbsent(k, () => TextEditingController(text: params[k]));
      // tcs = params.map(
      //         (key, value) => MapEntry(key, TextEditingController(text: value)));

      Function submitData = () async {
        tcs.forEach((key, value) {
          data[key].value = value.text;
        });
        Get.back();
      };
      return dialog(
          params.keys
              .map(
                (e) => Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: styleController.cardMargin),
                  margin: EdgeInsets.symmetric(
                      vertical: styleController.cardMargin / 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    //background color of dropdown button
                    border: Border.all(color: colors[500]!, width: 1),
                    //border of dropdown button
                    borderRadius: BorderRadius.circular(
                        styleController.cardBorderRadius /
                            2), //border raiuds of dropdown button
                  ),
                  child: TextField(
                    minLines:
                        ['tags', 'description', 'address'].contains(e) ? 3 : 1,
                    // expands: true,
                    maxLines: ['tags', 'description', 'address'].contains(e)
                        ? null
                        : 1,
                    autofocus: true,

                    textAlign: e == 'name' ||
                            e == 'family' ||
                            e == 'description' ||
                            e == 'tags' ||
                            e == 'address'
                        ? TextAlign.right
                        : TextAlign.left,
                    style: TextStyle(
                      color: styleController.primaryColor,
                    ),
                    controller: tcs[e],
                    textInputAction:
                        ['tags', 'description', 'address'].contains(e)
                            ? TextInputAction.newline
                            : TextInputAction.done,
                    keyboardType: ['tags', 'description', 'address'].contains(e)
                        ? TextInputType.multiline
                        : ['name', 'family'].contains(e)
                            ? TextInputType.text
                            : TextInputType.number,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: e.tr,
                    ),
                  ),
                ),
              )
              .toList(),
          submitData);
    }
  }

  ImageProvider imageProvider(CroppedFile? croppedImage) {
    if (croppedImage != null)
      return FileImage(File(croppedImage.path));
    else
      return AssetImage('assets/images/icon-dark.jpg');
  }
}
