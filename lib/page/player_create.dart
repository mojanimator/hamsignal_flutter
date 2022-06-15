import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:dabel_sport/controller/AnimationController.dart';
import 'package:dabel_sport/controller/PlayerController.dart';
import 'package:dabel_sport/controller/SettingController.dart';
import 'package:dabel_sport/helper/helpers.dart';
import 'package:dabel_sport/helper/styles.dart';
import 'package:dabel_sport/widget/mini_card.dart';
import 'package:dabel_sport/widget/shakeanimation.dart';
import 'package:dabel_sport/widget/videoplayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class PlayerCreate extends StatelessWidget {
 late PlayerController controller ;
  Map<String, dynamic> data = {
    'name': ''.obs,
    'family': ''.obs,
    'sport': ''.obs,
    'sport_name': ''.obs,
    'province': ''.obs,
    'province_name': ''.obs,
    'county': ''.obs,
    'county_name': ''.obs,
    'y': ''.obs,
    'm': ''.obs,
    'd': ''.obs,
    'height': ''.obs,
    'weight': ''.obs,
    'phone': ''.obs,
    'phone_verify': ''.obs,
    'description': ''.obs,
    'is_man': true.obs,
    'gender': 'm'.obs,
    'renew-month': '1'.obs,
    'coupon': ''.obs,
    'video': Rx<Uint8List>(Uint8List.fromList([])),
    'img': ''.obs,
  };
  late TextStyle titleStyle;
  final SettingController settingController = Get.find<SettingController>();
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

  PlayerCreate() {
    colors = styleController.cardPlayerColors;
    titleStyle = styleController.textMediumStyle.copyWith(color: colors[900]);
    controller = Get.find<PlayerController>();
    plusImage = Icon(
      Icons.add_a_photo,
      color: colors[500],
      size: styleController.imageHeight / 2,
    );
    plusIcon = Icon(
      Icons.add_circle_outline_sharp,
      color: colors[500],
      size: styleController.imageHeight / 3,
    );
    initDiscounts = {
      for (var item in settingController.prices
          .where((e) => e['key'].contains('player_')))
        item['key']: item['value']
    };
    discounts = RxMap(initDiscounts);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Obx(
      () {
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
                          backgroundColor:
                              MaterialStateProperty.all(Colors.green),
                          shape:
                              MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(
                                  styleController.cardBorderRadius / 2),
                            ),
                          ))),
                      onPressed: () async {
                        loading.value = true;
                        // tcs['name'].text = 'aaa';
                        // tcs['family'].text = 'aaa';
                        // data['province'].value = '1';
                        // data['county'].value = '1';
                        // data['sport'].value = '1';
                        // tcs['height'].text = '10';
                        // tcs['weight'].text = '10';
                        // data['d'].value = '10';
                        // data['m'].value = '1';
                        // data['y'].value = '1371';
                        // data['is_man'].value = false;
                        // tcs['phone'].text = '09018945844';

                        tcs.forEach((key, value) {
                          data[key].value = value.text;
                        });
                        var res = await controller.create(
                            params: data.map(
                                (key, value) => MapEntry(key, value.value)),
                            onProgress: (percent) {
                              // print("percent ${percent.toStringAsFixed(0)}");
                              uploadPercent.value = percent;
                            });
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
                        loading.value = false;
                      },
                      child: Text(
                        "${'pay'.tr} ${'and'.tr} ${'register'.tr}",
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
                        height: Get.height / 3 +
                            styleController.cardBorderRadius * 2,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              colorFilter: ColorFilter.mode(
                                  colors[500]!.withOpacity(.1),
                                  BlendMode.multiply),
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
                                InkWell(
                                  onTap: () async {
                                    XFile? imageFile = await _picker.pickImage(
                                        source: ImageSource.gallery);
                                    if (imageFile != null) {
                                      CroppedFile? cp =
                                          await ImageCropper().cropImage(
                                        sourcePath: imageFile.path,

                                        aspectRatio: CropAspectRatio(
                                            ratioX: settingController
                                                .cropRatio['profile']
                                                .toDouble(),
                                            ratioY: 1),
                                        // aspectRatioPresets: [
                                        // settingController.getAspectRatio('profile'),

                                        // ],

                                        uiSettings: [
                                          AndroidUiSettings(
                                              toolbarTitle:
                                                  'select_crop_section'.tr,
                                              toolbarColor: colors[500],
                                              toolbarWidgetColor: Colors.white,
                                              hideBottomControls: false,
                                              statusBarColor: colors[500],
                                              // initAspectRatio: settingController
                                              //     .getAspectRatio('profile'),
                                              lockAspectRatio: true),
                                          IOSUiSettings(
                                            title: 'select_crop_section'.tr,
                                          ),
                                        ],
                                      );

                                      croppedImage?.value = cp;
                                      if (cp != null) {
                                        File f = File(cp.path);
                                        data['img'].value =
                                            "image/${cp.path.split('.').last};base64," +
                                                base64.encode(
                                                    await f.readAsBytes());
                                      }
                                    }
                                  },
                                  child: Hero(
                                    tag: 'player_create',
                                    child: ShakeWidget(
                                      child: Card(
                                        child: Container(
                                          height: styleController.imageHeight,
                                          width: styleController.imageHeight,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(
                                                styleController
                                                    .cardBorderRadius,
                                              ),
                                              topRight: Radius.circular(
                                                styleController
                                                    .cardBorderRadius,
                                              ),
                                              bottomRight: Radius.circular(
                                                  styleController
                                                          .cardBorderRadius /
                                                      4),
                                              bottomLeft: Radius.circular(
                                                  styleController
                                                          .cardBorderRadius /
                                                      4),
                                            ),
                                            image: croppedImage?.value != null
                                                ? DecorationImage(
                                                    colorFilter:
                                                        ColorFilter.mode(
                                                            styleController
                                                                .primaryColor
                                                                .withOpacity(
                                                                    .0),
                                                            BlendMode.darken),
                                                    image: FileImage(File(
                                                        croppedImage?.value
                                                            ?.path as String)),
                                                    fit: BoxFit.cover,
                                                    filterQuality:
                                                        FilterQuality.medium)
                                                : null,
                                          ),
                                          child: croppedImage?.value == null
                                              ? plusImage
                                              : Center(),
                                        ),
                                        elevation: 10,
                                        shadowColor:
                                            colors[900]!.withOpacity(.9),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              styleController.cardBorderRadius),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(
                                      styleController.cardMargin),
                                )
                              ],
                            ),
                            //player section
                            Container(
                                // padding: EdgeInsets.all(styleController.cardMargin),
                                constraints: BoxConstraints(maxHeight: 300),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(
                                          styleController.cardBorderRadius)),
                                  child: ChewiePlayer(
                                      mode: 'create',
                                      src: null,
                                      onLoaded: (path) async {
                                        data['video'].value =
                                            await File(path).readAsBytes();
                                      },
                                      placeHolder:
                                          "${data['name']} ${data['family']}",
                                      colors: colors),
                                )),

                            Container(
                              child: Padding(
                                  padding: EdgeInsets.all(
                                      styleController.cardMargin / 4),
                                  child: Column(
                                    children: [
                                      MiniCard(
                                        colors:
                                            styleController.cardPlayerColors,
                                        title:
                                            "${'name'.tr} ${'and'.tr} ${'family'.tr}",
                                        desc1: data['name'].value,
                                        desc2: data['family'].value,
                                        styleController: styleController,
                                        child: showEditDialog(params: {
                                          'name': data['name'].value,
                                          'family': data['family'].value
                                        }),
                                      ),
                                      MiniCard(
                                        colors:
                                            styleController.cardPlayerColors,
                                        title: "${'gender'.tr}",
                                        desc1: '',
                                        desc2: null,
                                        child: Center(
                                          child: ToggleButtons(
                                              constraints:
                                                  BoxConstraints.expand(
                                                      width: Get.width / 2 -
                                                          styleController
                                                                  .cardMargin *
                                                              3),
                                              children: [
                                                Container(
                                                    padding: EdgeInsets.all(
                                                        styleController
                                                            .cardMargin),
                                                    child: Text('man'.tr)),
                                                Container(
                                                    padding: EdgeInsets.all(
                                                        styleController
                                                            .cardMargin),
                                                    child: Text('woman'.tr))
                                              ],
                                              selectedColor: Colors.white,
                                              splashColor: Colors.white,
                                              disabledColor: Colors.white,
                                              fillColor: colors[500],
                                              color: colors[500],
                                              borderColor: colors[500],
                                              selectedBorderColor: Colors.white,
                                              borderWidth: 1,
                                              onPressed: (idx) {
                                                if (idx == 1)
                                                  data['gender'].value = 'w';
                                                else
                                                  data['gender'].value = 'm';
                                                data['is_man'].value =
                                                    idx == 1 ? false : true;
                                              },
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(styleController
                                                          .cardBorderRadius /
                                                      2)),
                                              isSelected: [
                                                data['gender'].value == 'm',
                                                data['gender'].value == 'w'
                                              ]),
                                        ),
                                        styleController: styleController,
                                      ),
                                      MiniCard(
                                        colors:
                                            styleController.cardPlayerColors,
                                        title: 'sport'.tr,
                                        desc1: settingController
                                            .sport(data['sport'].value),
                                        desc2: null,
                                        styleController: styleController,
                                        child: showEditDialog(dropdowns: {
                                          'sport': settingController.sports
                                        }),
                                      ),
                                      MiniCard(
                                        colors:
                                            styleController.cardPlayerColors,
                                        title:
                                            "${'province'.tr} ${'and'.tr} ${'county'.tr}",
                                        desc1: '',
                                        desc2: null,
                                        styleController: styleController,
                                        child: showEditDialog(dropdowns: {
                                          'province':
                                              settingController.provinces,
                                          'county': settingController.counties,
                                        }),
                                      ),
                                      MiniCard(
                                          colors:
                                              styleController.cardPlayerColors,
                                          title: 'born_at'.tr,
                                          desc1:
                                              "${data['y']}/${data['m']}/${data['d']}",
                                          desc2: null,
                                          styleController: styleController,
                                          child: showEditDialog(dropdowns: {
                                            'd': 1.to(31).map((e) =>
                                                {'id': "$e", 'name': "$e"}),
                                            'm': 1.to(12).map((e) =>
                                                {'id': "$e", 'name': "$e"}),
                                            'y': 1300.to(1450).map((e) =>
                                                {'id': "$e", 'name': "$e"}),
                                          })),
                                      MiniCard(
                                        colors:
                                            styleController.cardPlayerColors,
                                        title: "${'height'.tr} (${'cm'.tr})",
                                        desc1: "${data['height']}",
                                        desc2: null,
                                        styleController: styleController,
                                        child: showEditDialog(params: {
                                          'height': data['height'].value,
                                        }),
                                      ),
                                      MiniCard(
                                        colors:
                                            styleController.cardPlayerColors,
                                        title: "${'weight'.tr} (${'kg'.tr})",
                                        desc1: "${data['weight']}",
                                        desc2: null,
                                        styleController: styleController,
                                        child: showEditDialog(params: {
                                          'weight': data['weight'].value,
                                        }),
                                      ),
                                      MiniCard(
                                        colors:
                                            styleController.cardPlayerColors,
                                        title:
                                            "${'phone'.tr} ${'and'.tr} ${'phone_verify'.tr}",
                                        desc1: "${data['phone']}",
                                        desc2: "${data['phone_verify']}",
                                        styleController: styleController,
                                        child: showEditDialog(params: {
                                          'phone': data['phone'].value,
                                          'phone_verify':
                                              data['phone_verify'].value,
                                        }),
                                      ),
                                      MiniCard(
                                          colors:
                                              styleController.cardPlayerColors,
                                          title: 'description'.tr,
                                          desc1: "${data['description'] ?? ''}",
                                          desc2: null,
                                          styleController: styleController,
                                          child: showEditDialog(params: {
                                            'description':
                                                data['description'].value,
                                          })),
                                      MiniCard(
                                        title: "subscribe_type".tr,
                                        colors: colors,
                                        desc1: "",
                                        styleController: styleController,
                                        child: Column(
                                          children: [
                                            Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children:
                                                    settingController.prices
                                                        .where((el) => el['key']
                                                            .contains('player'))
                                                        .map((e) => InkWell(
                                                              onTap: () => data[
                                                                      'renew-month']
                                                                  .value = e[
                                                                      'key']
                                                                  .split(
                                                                      '_')[1],
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Radio<
                                                                          String>(
                                                                        fillColor:
                                                                            MaterialStateProperty.all(colors[500]),
                                                                        value: e['key']
                                                                            .split('_')[1],
                                                                        groupValue:
                                                                            data['renew-month'].value,
                                                                        onChanged:
                                                                            (value) {
                                                                          data['renew-month'].value =
                                                                              value;
                                                                        },
                                                                        activeColor:
                                                                            Colors.green,
                                                                      ),
                                                                      Text(e['name'],
                                                                          style:
                                                                              TextStyle(color: colors[500])),
                                                                    ],
                                                                  ),
                                                                  Text(
                                                                    "${e['value']}"
                                                                        .asPrice(),
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color: colors[
                                                                            500],
                                                                        decoration: int.parse(discounts.value[e['key']]) <
                                                                                int.parse(e['value'])
                                                                            ? TextDecoration.lineThrough
                                                                            : TextDecoration.none),
                                                                  ),
                                                                  Visibility(
                                                                    visible: int.parse(discounts.value[e[
                                                                            'key']]) <
                                                                        int.parse(
                                                                            e['value']),
                                                                    child: Text(
                                                                      "${discounts.value[e['key']]}"
                                                                          .asPrice(),
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              colors[500]),
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
                                                            horizontal:
                                                                styleController
                                                                    .cardMargin),
                                                        margin: EdgeInsets.symmetric(
                                                            vertical:
                                                                styleController
                                                                        .cardMargin /
                                                                    4),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          //background color of dropdown button
                                                          border: Border.all(
                                                              color: styleController
                                                                  .primaryColor,
                                                              width: 1),
                                                          //border of dropdown button
                                                          borderRadius:
                                                              BorderRadius
                                                                  .horizontal(
                                                            right: Radius.circular(
                                                                styleController
                                                                        .cardBorderRadius /
                                                                    2),
                                                            left:
                                                                Radius.circular(
                                                                    0),
                                                          ), //border raiuds of dropdown button
                                                        ),
                                                        child: TextField(
                                                          autofocus: true,
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            color: styleController
                                                                .primaryColor,
                                                          ),
                                                          onChanged: (str) {
                                                            data['coupon']
                                                                .value = str;
                                                            discounts.value =
                                                                initDiscounts;
                                                          },
                                                          textInputAction:
                                                              TextInputAction
                                                                  .done,
                                                          decoration:
                                                              InputDecoration(
                                                            border: InputBorder
                                                                .none,
                                                            hintText:
                                                                'coupon'.tr,
                                                          ),
                                                        ),
                                                      )),
                                                  Expanded(
                                                    flex: 2,
                                                    child: TextButton(
                                                        style: ButtonStyle(
                                                            padding: MaterialStateProperty
                                                                .all(EdgeInsets.all(
                                                                    styleController
                                                                            .cardMargin /
                                                                        1)),
                                                            overlayColor:
                                                                MaterialStateProperty
                                                                    .resolveWith(
                                                              (states) {
                                                                return states.contains(
                                                                        MaterialState
                                                                            .pressed)
                                                                    ? styleController
                                                                        .secondaryColor
                                                                    : null;
                                                              },
                                                            ),
                                                            backgroundColor:
                                                                MaterialStateProperty
                                                                    .all(colors[
                                                                        700]),
                                                            shape: MaterialStateProperty
                                                                .all(
                                                                    RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .horizontal(
                                                                right: Radius
                                                                    .circular(
                                                                        0),
                                                                left: Radius.circular(
                                                                    styleController
                                                                            .cardBorderRadius /
                                                                        2),
                                                              ),
                                                            ))),
                                                        onPressed: () async {
                                                          couponLoading.value =
                                                              true;
                                                          Map<String, dynamic>?
                                                              res =
                                                              await settingController
                                                                  .calculateCoupon(
                                                                      params: {
                                                                'type':
                                                                    'player',
                                                                'coupon': data[
                                                                        'coupon']
                                                                    .value,
                                                                'renew-month':
                                                                    data['renew-month']
                                                                        .value,
                                                              });
                                                          if (res != null) {
                                                            for (var item
                                                                in res.keys)
                                                              discounts.value =
                                                                  res.map((key,
                                                                          value) =>
                                                                      MapEntry(
                                                                          key,
                                                                          value
                                                                              .toString()));
                                                          } else {
                                                            discounts.value =
                                                                initDiscounts;
                                                          }
                                                          couponLoading.value =
                                                              false;
                                                        },
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              "${'append'.tr}",
                                                              style: styleController
                                                                  .textMediumLightStyle,
                                                            ),
                                                            couponLoading.value
                                                                ? CupertinoActivityIndicator(
                                                                    color:
                                                                        colors[
                                                                            50],
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
                                              height:
                                                  styleController.cardMargin,
                                            ),
                                          ],
                                        ),
                                      )
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
                      borderRadius: BorderRadius.circular(
                          styleController.cardBorderRadius),
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
      },
    );
  }

  Widget? showEditDialog(
      {Map<String, dynamic> params = const {},
      Map<String, dynamic> dropdowns = const {}}) {
    if (dropdowns.keys.length > 0) {
      return Column(
        children: dropdowns.keys.map(
          (key) {
            List<DropdownMenuItem> items = dropdowns[key].where((e) {
              if (key == 'county')
                return "${e['province_id']}" == data['province'].value;
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

                    if (key == 'province') {
                      data['county'].value = '';
                    }
                    data[key].value = idx;
                  },
                  selectedItemBuilder: (BuildContext context) => dropdowns[key]
                      .where((e) {
                        if (key == 'county')
                          return "${e['province_id']}" ==
                              data['province'].value;
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
                                    data[key].value = '';
                                    if (key == 'province')
                                      data['county'].value = '';
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
              if (params.keys.contains('phone_verify'))
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                          style: ButtonStyle(
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
                                  right: Radius.circular(
                                      styleController.cardBorderRadius / 2),
                                  left: Radius.circular(
                                      styleController.cardBorderRadius / 4),
                                ),
                              ))),
                          onPressed: () => controller.sendActivationCode(
                              phone: params['phone']),
                          child: Text(
                            'receive_code'.tr,
                            style: styleController.textMediumLightStyle,
                          )),
                    ),
                  ],
                ),
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
                    minLines: e == 'description' ? 3 : 1,
                    // expands: true,
                    maxLines: e == 'description' ? null : 1,
                    autofocus: true,
                    textAlign:
                        e == 'name' || e == 'family' || e == 'description'
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
