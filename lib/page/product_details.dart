import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dabel_sport/controller/ProductController.dart';
import 'package:dabel_sport/controller/SettingController.dart';
import 'package:dabel_sport/helper/helpers.dart';
import 'package:dabel_sport/helper/styles.dart';
import 'package:dabel_sport/helper/variables.dart';
import 'package:dabel_sport/model/Product.dart';
import 'package:dabel_sport/model/Shop.dart';
import 'package:dabel_sport/page/shop_details.dart';
import 'package:dabel_sport/widget/MyGallery.dart';
import 'package:dabel_sport/widget/mini_card.dart';
import 'package:dabel_sport/widget/shakeanimation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';

class ProductDetails extends StatelessWidget {
  late Rx<Product> data;

  ProductController controller = Get.find<ProductController>();
  MapController mapController = MapController();
  late MaterialColor colors;
  late TextStyle titleStyle;

  final SettingController settingController = Get.find<SettingController>();
  int index;
  final Style styleController = Get.find<Style>();

  RxDouble uploadPercent = RxDouble(0.0);
  RxBool loading = RxBool(false);

  ProductDetails({required data, MaterialColor? colors, int this.index = -1}) {
    this.colors = colors ?? styleController.cardCoachColors;
    titleStyle =
        styleController.textMediumStyle.copyWith(color: this.colors[900]);
    this.data = Rx<Product>(data);
    // print(this.data.value.salePercent);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      onWillPop: () {
        Get.back(result: data.value);
        return Future(() => false);
      },
      child: Scaffold(
        body: Obx(
          () => ShakeWidget(
            child: Stack(
              fit: StackFit.expand,
              children: [
                //profile section
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CachedNetworkImage(
                        height: Get.height / 3 +
                            styleController.cardBorderRadius * 2,
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                colorFilter: ColorFilter.mode(
                                    colors[500]!.withOpacity(.9),
                                    BlendMode.multiply),
                                image: imageProvider,
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.low),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0)),
                            ),
                          ),
                        ),
                        imageUrl:
                            "${controller.getProfileLink(data.value.docLinks)}",
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

                RefreshIndicator(
                  onRefresh: () => refresh(),
                  child: ListView(
                      physics: AlwaysScrollableScrollPhysics(),
                      children: [
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Container(
                                      height: styleController.imageHeight,
                                    ),
                                    if (!isEditable())
                                      Padding(
                                        padding: EdgeInsets.all(
                                            styleController.cardMargin),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal:
                                                  styleController.cardMargin /
                                                      2,
                                              vertical:
                                                  styleController.cardMargin /
                                                      4),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius
                                                  .circular(styleController
                                                          .cardBorderRadius /
                                                      2),
                                              color: styleController
                                                  .primaryMaterial[50]),
                                          child: Text(
                                            " ${data.value.name} ",
                                            style: styleController
                                                .textHeaderStyle
                                                .copyWith(color: colors[600]),
                                          ),
                                        ),
                                      ),
                                    if (isEditable())
                                      IntrinsicWidth(
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: styleController
                                                            .cardMargin /
                                                        2,
                                                    vertical: styleController
                                                        .cardMargin),
                                                child: InkWell(
                                                  splashColor: colors[50],
                                                  onTap: () => edit({
                                                    'id': data.value.id,
                                                    'active': data.value.active
                                                  }),
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(
                                                        horizontal:
                                                            styleController
                                                                    .cardMargin /
                                                                2,
                                                        vertical: styleController
                                                                .cardMargin /
                                                            2),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                styleController
                                                                        .cardBorderRadius /
                                                                    2),
                                                        color: data.value.active
                                                            ? colors[900]
                                                            : colors[50]),
                                                    child: Text(
                                                      " ${data.value.active ? 'active'.tr : 'inactive'.tr}",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: styleController
                                                          .textHeaderStyle
                                                          .copyWith(
                                                              color: data.value
                                                                      .active
                                                                  ? Colors.white
                                                                  : colors[
                                                                      600]),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: styleController
                                                            .cardMargin /
                                                        2,
                                                    vertical: styleController
                                                        .cardMargin),
                                                child: InkWell(
                                                  splashColor: colors[50],
                                                  onTap: () => Get.dialog(
                                                      Center(
                                                        child: Material(
                                                          color: Colors
                                                              .transparent,
                                                          child: Card(
                                                            child: Padding(
                                                              padding: EdgeInsets.all(
                                                                  styleController
                                                                      .cardMargin),
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Text(
                                                                    'delete_product?'
                                                                        .tr,
                                                                    style: styleController
                                                                        .textMediumStyle
                                                                        .copyWith(
                                                                            color:
                                                                                Colors.red),
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            TextButton(
                                                                          style: ButtonStyle(
                                                                              padding: MaterialStateProperty.all(EdgeInsets.all(styleController.cardMargin / 2)),
                                                                              overlayColor: MaterialStateProperty.resolveWith(
                                                                                (states) {
                                                                                  return states.contains(MaterialState.pressed) ? styleController.secondaryColor : null;
                                                                                },
                                                                              ),
                                                                              backgroundColor: MaterialStateProperty.all(Colors.red),
                                                                              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.all(
                                                                                  Radius.circular(styleController.cardBorderRadius / 2),
                                                                                ),
                                                                              ))),
                                                                          onPressed:
                                                                              () async {
                                                                            Get.back();
                                                                            remove();
                                                                          },
                                                                          child: Icon(
                                                                              Icons.check,
                                                                              color: Colors.white),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      barrierDismissible: true),
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(
                                                        horizontal:
                                                            styleController
                                                                    .cardMargin /
                                                                2,
                                                        vertical: styleController
                                                                .cardMargin /
                                                            2),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                styleController
                                                                        .cardBorderRadius /
                                                                    2),
                                                        color: Colors.red),
                                                    child: Text(
                                                      " ${'delete'.tr}",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: styleController
                                                          .textHeaderStyle
                                                          .copyWith(
                                                              color:
                                                                  Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                Container(
                                  child: Padding(
                                      padding: EdgeInsets.all(
                                          styleController.cardMargin / 4),
                                      child: Column(
                                        children: [
                                          MyGallery(
                                            mode:
                                                isEditable() ? 'edit' : 'view',
                                            items: controller.getImageLinks(
                                              data.value.docLinks,
                                            ),
                                            height: styleController
                                                .cardVitrinHeight,
                                            autoplay: !isEditable(),
                                            fullScreen: false,
                                            colors: colors,
                                            infoText:
                                                "${'product'.tr} ${data.value.name}",
                                            styleController: styleController,
                                            ratio: settingController
                                                .cropRatio['product']
                                                .toDouble(),
                                            limit: settingController
                                                .limits['product'],
                                            onChanged: (index, file) async {
                                              var img;
                                              if (file != null)
                                                img =
                                                    "image/${file.path.split('.').last};base64," +
                                                        base64.encode(await file
                                                            .readAsBytes());
                                              List<dynamic> docs = data
                                                  .value.docLinks
                                                  .where((doc) =>
                                                      doc['type_id'] ==
                                                      settingController
                                                          .getDocType(
                                                              'product'))
                                                  .toList();

                                              if (index + 1 <= docs.length)
                                                CachedNetworkImage.evictFromCache(
                                                    "${Variables.LINK_STORAGE}/${data.value.docLinks[index]['type_id']}/${data.value.docLinks[index]['id']}.jpg");

                                              edit({
                                                'img': img,
                                                'cmnd': file == null
                                                    ? 'delete-img'
                                                    : 'upload-img',
                                                'replace':
                                                    index + 1 <= docs.length,
                                                'type': settingController
                                                    .getDocType('product'),
                                                'id': index + 1 <= docs.length
                                                    ? docs[index]['id']
                                                    : null,
                                                'data_id': "${data.value.id}"
                                              });
                                            },
                                          ),
                                          Column(
                                            children: [
                                              if (isEditable())
                                                MiniCard(
                                                  colors: colors,
                                                  styleController:
                                                      styleController,
                                                  desc1: "${data.value.name}",
                                                  title:
                                                      "${'name'.tr} ${'product'.tr}",
                                                  onTap: () =>
                                                      showEditDialog(params: {
                                                    'name': data.value.name,
                                                  }),
                                                ),
                                              InkWell(
                                                splashColor: colors[500],
                                                onTap: () async {
                                                  Shop? shop = await controller
                                                      .findShop({
                                                    'id':
                                                        "${data.value.shop_id}"
                                                  });

                                                  if (shop != null)
                                                    Get.to(
                                                        ShopDetails(
                                                            data: shop,
                                                            colors: styleController
                                                                .cardShopColors),
                                                        transition:
                                                            Transition.topLevel,
                                                        duration: Duration(
                                                            milliseconds: 400));
                                                },
                                                child: MiniCard(
                                                  colors: colors,
                                                  styleController:
                                                      styleController,
                                                  title: 'shop'.tr,
                                                  desc1: settingController
                                                      .shop(data.value.shop_id),
                                                ),
                                              ),
                                              MiniCard(
                                                  colors: colors,
                                                  title: 'group_id'.tr,
                                                  desc1:
                                                      "${settingController.sport(data.value.group_id)}",
                                                  desc2: null,
                                                  onTap: () =>
                                                      showEditDialog(params: {
                                                        'group_id':
                                                            data.value.group_id
                                                      }, dropdowns: {
                                                        'group_id':
                                                            settingController
                                                                .sports,
                                                      }),
                                                  styleController:
                                                      styleController),
                                              MiniCard(
                                                  colors: colors,
                                                  title: 'count'.tr,
                                                  desc1: "${data.value.count}",
                                                  desc2: null,
                                                  onTap: () =>
                                                      showEditDialog(params: {
                                                        'count':
                                                            data.value.count,
                                                      }),
                                                  styleController:
                                                      styleController),
                                              MiniCard(
                                                  colors: colors,
                                                  title: 'price'.tr,
                                                  desc1: "${data.value.price}"
                                                      .asPrice(),
                                                  child: IntrinsicHeight(
                                                      child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        data.value.price
                                                            .asPrice(),
                                                        style: styleController
                                                            .textMediumStyle
                                                            .copyWith(
                                                                color:
                                                                    colors[500],
                                                                decoration: data
                                                                            .value.salePercent !=
                                                                        '0%'
                                                                    ? TextDecoration
                                                                        .lineThrough
                                                                    : TextDecoration
                                                                        .none),
                                                      ),
                                                      SizedBox(
                                                        width: styleController
                                                            .cardMargin,
                                                      ),
                                                      if (data.value
                                                              .salePercent !=
                                                          '0%')
                                                        VerticalDivider(),
                                                      if (data.value
                                                              .salePercent !=
                                                          '0%')
                                                        SizedBox(
                                                          width: styleController
                                                              .cardMargin,
                                                        ),
                                                      if (data.value
                                                              .salePercent !=
                                                          '0%')
                                                        Text(
                                                          data.value
                                                              .discount_price
                                                              .asPrice(),
                                                          style: styleController
                                                              .textMediumStyle
                                                              .copyWith(
                                                            color: colors[500],
                                                          ),
                                                        ),
                                                    ],
                                                  )),
                                                  desc2: data.value
                                                              .salePercent !=
                                                          '0%'
                                                      ? "${data.value.discount_price}"
                                                      : null,
                                                  onTap: () =>
                                                      showEditDialog(params: {
                                                        'price':
                                                            data.value.price,
                                                        'discount_price': data
                                                                    .value
                                                                    .discount_price !=
                                                                data.value.price
                                                            ? data.value
                                                                .discount_price
                                                            : '',
                                                      }),
                                                  styleController:
                                                      styleController),
                                              MiniCard(
                                                  colors: colors,
                                                  title: 'description'.tr,
                                                  desc1:
                                                      "${data.value.description}",
                                                  desc2: null,
                                                  onTap: () =>
                                                      showEditDialog(params: {
                                                        'description': data
                                                            .value.description,
                                                      }),
                                                  styleController:
                                                      styleController),
                                              MiniCard(
                                                  colors: colors,
                                                  title: 'tags'.tr,
                                                  desc1:
                                                      "${data.value.tags.replaceAll("\n", ' | ')}",
                                                  desc2: null,
                                                  onTap: () =>
                                                      showEditDialog(params: {
                                                        'tags': data.value.tags,
                                                      }),
                                                  styleController:
                                                      styleController),
                                            ],
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
                    child: Center(
                      child: CircularProgressIndicator(
                        value: uploadPercent.value % 100,
                        color: colors[800],
                        backgroundColor: Colors.white,
                      ),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  edit(Map<String, dynamic> params) async {
    loading.value = true;
    var res = await controller.edit(
        params: {'id': data.value.id, ...params},
        onProgress: (percent) {
          uploadPercent.value = percent;
        });

    if (res != null) {
      Get.back();
      settingController.helper.showToast(
          msg: res['msg'] ?? 'edited_successfully'.tr, status: 'success');
      refresh();
    }
    loading.value = false;
  }

  void remove() async {
    loading.value = true;
    var res = await controller.remove(
        params: {'id': data.value.id},
        onProgress: (percent) {
          uploadPercent.value = percent;
        });

    if (res != null) {
      Get.back();
      settingController.helper
          .showToast(msg: 'removed_successfully'.tr, status: 'success');
      refresh();
    }
    loading.value = false;
  }

  bool isEditable() {
    return controller.isEditable(data.value.shop_id);
  }

  refresh() async {
    Product? res = await controller.find({'id': data.value.id, 'panel': '1'});

    if (res != null) {
      this.data.value = res;

      if (index != -1) controller.data[index] = data.value;
    }
  }

  showEditDialog(
      {Map<String, dynamic> params = const {},
      Map<String, dynamic> dropdowns = const {}}) {
    if (!isEditable()) return null;

    Map<String, TextEditingController> tcs = {};
    for (var k in params.keys)
      tcs.putIfAbsent(k, () => TextEditingController(text: params[k]));

    dialog(List<Widget> children, Function callback) {
      Get.dialog(
        Obx(
          () => Center(
            child: Material(
              color: Colors.transparent,
              child: Card(
                margin: EdgeInsets.all(styleController.cardMargin),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(styleController.cardBorderRadius),
                ),
                child: Padding(
                  padding: EdgeInsets.all(styleController.cardMargin),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ...children,
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: styleController.cardMargin / 2),
                        child: Visibility(
                            visible: loading.value,
                            child: LinearProgressIndicator(
                                value: uploadPercent.value,
                                color: colors[500])),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: TextButton(
                                style: ButtonStyle(
                                    overlayColor:
                                        MaterialStateProperty.resolveWith(
                                      (states) {
                                        return states
                                                .contains(MaterialState.pressed)
                                            ? styleController.secondaryColor
                                            : null;
                                      },
                                    ),
                                    backgroundColor:
                                        MaterialStateProperty.all(colors[50]),
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                      borderRadius: BorderRadius.horizontal(
                                        right: Radius.circular(
                                            styleController.cardBorderRadius /
                                                2),
                                        left: Radius.circular(
                                            styleController.cardBorderRadius /
                                                4),
                                      ),
                                    ))),
                                onPressed: () => Get.back(),
                                child: Text(
                                  'cancel'.tr,
                                  style: styleController.textMediumStyle
                                      .copyWith(color: colors[500]),
                                )),
                          ),
                          VerticalDivider(
                            indent: styleController.cardMargin / 2,
                            endIndent: styleController.cardMargin / 2,
                          ),
                          Expanded(
                            child: TextButton(
                                style: ButtonStyle(
                                    overlayColor:
                                        MaterialStateProperty.resolveWith(
                                      (states) {
                                        return states
                                                .contains(MaterialState.pressed)
                                            ? styleController.secondaryColor
                                            : null;
                                      },
                                    ),
                                    backgroundColor:
                                        MaterialStateProperty.all(colors[500]),
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                      borderRadius: BorderRadius.horizontal(
                                        left: Radius.circular(
                                            styleController.cardBorderRadius /
                                                2),
                                        right: Radius.circular(
                                            styleController.cardBorderRadius /
                                                4),
                                      ),
                                    ))),
                                onPressed: () => callback(),
                                child: Text(
                                  'edit'.tr,
                                  style: styleController.textMediumLightStyle,
                                )),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        //     ,
        barrierDismissible: false,
      );
    }

    Map<String, dynamic> tmpParams =
        params.map((key, value) => MapEntry(key, RxString(value ?? '')));

    if (dropdowns.keys.length > 0) {
      Function submitData = () async {
        edit(tmpParams.map((key, value) => MapEntry(key, value.value)));
      };

      dialog(
          dropdowns.keys.map(
            (key) {
              return Obx(() {
                List<DropdownMenuItem> items = dropdowns[key].where((e) {
                  if (key == 'county_id')
                    return "${e['province_id']}" ==
                        tmpParams['province_id'].value;
                  return true;
                }).map<DropdownMenuItem>((e) {
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

                      borderRadius: BorderRadius.circular(
                          styleController.cardBorderRadius),
                      dropdownColor: Colors.white,
                      underline: Container(),
                      items: items,
                      isExpanded: true,
                      value: tmpParams[key].value == ''
                          ? null
                          : tmpParams[key].value,
                      icon: Center(),
                      // underline: Container(),
                      hint: Center(
                          child: Text(
                        "${key.contains('_id') ? key.split('_')[0].tr : key.tr}" +
                            '...',
                        style: TextStyle(color: colors[500]),
                      )),

                      onChanged: (idx) {
                        // data[key].value = dropdowns[key].where((e)=>e['id']);

                        tmpParams[key].value = idx;

                        if (key == 'province_id') {
                          tmpParams['county_id'].value = '';
                        }
                      },
                      selectedItemBuilder: (BuildContext context) =>
                          dropdowns[key]
                              .where((e) {
                                if (key == 'county_id')
                                  return "${e['province_id']}" ==
                                      tmpParams['province_id'].value;
                                return true;
                              })
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
                                            tmpParams[key].value = '';
                                            if (key == 'province_id')
                                              tmpParams['county_id'].value = '';
                                          },
                                          icon: Icon(Icons.close),
                                          color: Colors.white,
                                        ),
                                        Expanded(
                                          child: Center(
                                              child: Text(
                                            el['name'],
                                            style: styleController
                                                .textMediumLightStyle,
                                          )),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                    ),
                  ),
                );
              });
            },
          ).toList(),
          submitData);
    } else {
      // tcs = params.map(
      //         (key, value) => MapEntry(key, TextEditingController(text: value)));

      Function submitData = () async {
        edit(tcs.map((key, value) => MapEntry(key, value.text)));
      };
      return dialog(
          params.keys
              .map(
                (e) => Container(
                  padding: EdgeInsets.symmetric(
                      horizontal:
                          e != 'count' ? styleController.cardMargin : 0),
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
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (e == 'count')
                          Expanded(
                            flex: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: colors[500],
                                borderRadius: BorderRadius.circular(
                                    styleController.cardBorderRadius / 2),
                              ),
                              margin: EdgeInsets.only(
                                  left: styleController.cardMargin),
                              child: InkWell(
                                onTap: () {
                                  int? txt = int.tryParse(tcs['count']!.text);
                                  if (txt == null)
                                    tcs['count']!.text = '0';
                                  else
                                    tcs['count']!.text = "${txt + 1}";
                                },
                                borderRadius: BorderRadius.circular(
                                    styleController.cardBorderRadius / 2),
                                splashColor: colors[800],
                                child: Center(
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        Expanded(
                          flex: 3,
                          child: TextField(
                            minLines: e == 'description' || e == 'tags' ? 3 : 1,
                            // expands: true,
                            maxLines:
                                e == 'description' || e == 'tags' ? null : 1,
                            autofocus: true,
                            textAlign: e == 'name' ||
                                    e == 'family' ||
                                    e == 'description' ||
                                    e == 'tags'
                                ? TextAlign.right
                                : TextAlign.left,
                            style: TextStyle(
                              color: colors[500],
                            ),
                            controller: tcs[e],

                            textInputAction:
                                ['tags', 'description', 'address'].contains(e)
                                    ? TextInputAction.newline
                                    : TextInputAction.done,
                            keyboardType:
                                ['tags', 'description', 'address'].contains(e)
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
                        if (e == 'count')
                          Expanded(
                            flex: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: colors[500],
                                borderRadius: BorderRadius.circular(
                                    styleController.cardBorderRadius / 2),
                              ),
                              margin: EdgeInsets.only(
                                  right: styleController.cardMargin),
                              child: Ink(
                                child: InkWell(
                                  onTap: () {
                                    int? txt = int.tryParse(tcs['count']!.text);
                                    if (txt == null)
                                      tcs['count']!.text = '0';
                                    else
                                      tcs['count']!.text =
                                          "${txt - 1 < 0 ? 0 : txt - 1}";
                                  },
                                  borderRadius: BorderRadius.circular(
                                      styleController.cardBorderRadius / 2),
                                  splashColor: colors[800],
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
              )
              .toList(),
          submitData);
    }
  }
}
