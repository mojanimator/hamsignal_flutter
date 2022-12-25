import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dabel_sport/controller/APIProvider.dart';
import 'package:dabel_sport/controller/PlayerController.dart';
import 'package:dabel_sport/controller/SettingController.dart';
import 'package:dabel_sport/controller/UserController.dart';
import 'package:dabel_sport/helper/helpers.dart';
import 'package:dabel_sport/helper/styles.dart';
import 'package:dabel_sport/helper/variables.dart';
import 'package:dabel_sport/model/Player.dart';
import 'package:dabel_sport/widget/mini_card.dart';
import 'package:dabel_sport/widget/shakeanimation.dart';
import 'package:dabel_sport/widget/subscribe_dialog.dart';
import 'package:dabel_sport/widget/videoplayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:url_launcher/url_launcher.dart';

class PlayerDetails extends StatelessWidget {
  late Rx<Player> data;

  PlayerController controller = Get.find<PlayerController>();

  late MaterialColor colors;
  late TextStyle titleStyle;

  final SettingController settingController = Get.find<SettingController>();
  int index;
  final Style styleController = Get.find<Style>();
  late Rx<JalaliFormatter> bornAt;
  RxDouble uploadPercent = RxDouble(0.0);
  RxBool loading = RxBool(false);

  PlayerDetails({required data, MaterialColor? colors, int this.index = -1}) {
    this.colors = colors ?? styleController.cardPlayerColors;
    titleStyle =
        styleController.textMediumStyle.copyWith(color: this.colors[900]);
    this.data = Rx<Player>(data);
    bornAt = Rx<JalaliFormatter>(Jalali.fromDateTime(
            DateTime.fromMillisecondsSinceEpoch(data.born_at * 1000))
        .formatter);
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
                                    InkWell(
                                      onTap: () =>
                                          Navigator.of(context).push(
                                              PageRouteBuilder(
                                                  opaque: false,
                                                  barrierDismissible: true,
                                                  pageBuilder:
                                                      (BuildContext context, _,
                                                          __) {
                                                    return Hero(
                                                      tag:
                                                          "preview${data.value.id}",
                                                      child: Stack(
                                                        fit: StackFit.expand,
                                                        children: [
                                                          Container(
                                                            decoration: BoxDecoration(
                                                                gradient:
                                                                    styleController
                                                                        .splashBackground),
                                                            child:
                                                                InteractiveViewer(
                                                              child:
                                                                  CachedNetworkImage(
                                                                imageUrl:
                                                                    "${controller.getProfileLink(data.value.docLinks)}",
                                                                useOldImageOnUrlChange:
                                                                    true,
                                                              ),
                                                            ),
                                                          ),
                                                          Positioned(
                                                            left: 0,
                                                            right: 0,
                                                            bottom: 8,
                                                            child: Container(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      .7),
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(4),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  TextButton(
                                                                    onPressed:
                                                                        () async {
                                                                      Get.back();
                                                                    },
                                                                    style: ButtonStyle(
                                                                        shape: MaterialStateProperty.all(
                                                                          CircleBorder(
                                                                              side: BorderSide(color: colors[50]!, width: 1)),
                                                                        ),
                                                                        backgroundColor: MaterialStateProperty.resolveWith((states) => states.contains(MaterialState.pressed) ? styleController.secondaryColor : Colors.transparent)),
                                                                    child:
                                                                        Padding(
                                                                      padding: EdgeInsets.all(
                                                                          styleController.cardMargin /
                                                                              2),
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .clear,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  if (isEditable())
                                                                    TextButton(
                                                                      onPressed:
                                                                          () async {
                                                                        String? img = await settingController.pickAndCrop(
                                                                            ratio:
                                                                                settingController.cropRatio['profile'],
                                                                            colors: colors);
                                                                      await  CachedNetworkImage.evictFromCache(controller.getProfileLink(data
                                                                            .value
                                                                            .docLinks));
                                                                        if (img !=
                                                                            null)
                                                                          edit({
                                                                            'img':
                                                                                img,
                                                                            'cmnd':
                                                                                'upload-img',
                                                                            'replace':
                                                                                true,
                                                                            'id':
                                                                                settingController.getDocId(data.value.docLinks, 'profile'),
                                                                            'data_id':
                                                                                "${data.value.id}"
                                                                          });
                                                                      },
                                                                      style: ButtonStyle(
                                                                          shape: MaterialStateProperty.all(
                                                                            CircleBorder(side: BorderSide(color: colors[50]!, width: 1)),
                                                                          ),
                                                                          backgroundColor: MaterialStateProperty.resolveWith((states) => states.contains(MaterialState.pressed) ? styleController.secondaryColor : Colors.transparent)),
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            EdgeInsets.all(styleController.cardMargin /
                                                                                2),
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .add_photo_alternate_outlined,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  })),
                                      child: Hero(
                                        tag: "preview${data.value.id}",
                                        child: ShakeWidget(
                                          child: Card(
                                            child: CachedNetworkImage(
                                              height:
                                                  styleController.imageHeight,
                                              width:
                                                  styleController.imageHeight,
                                              imageUrl:
                                                  "${controller.getProfileLink(data.value.docLinks)}",
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.only(
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
                                                  image: DecorationImage(
                                                      colorFilter:
                                                          ColorFilter.mode(
                                                              styleController
                                                                  .primaryColor
                                                                  .withOpacity(
                                                                      .0),
                                                              BlendMode.darken),
                                                      image: imageProvider,
                                                      fit: BoxFit.cover,
                                                      filterQuality:
                                                          FilterQuality.medium),
                                                ),
                                              ),
                                              placeholder: (context, url) =>
                                                  CupertinoActivityIndicator(),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      ClipRRect(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(
                                                        styleController
                                                            .cardBorderRadius)),
                                                child: Image.network(
                                                    Variables.NOIMAGE_LINK),
                                              ),
                                            ),
                                            elevation: 10,
                                            shadowColor:
                                                colors[900]!.withOpacity(.9),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      styleController
                                                          .cardBorderRadius),
                                            ),
                                          ),
                                        ),
                                      ),
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
                                            " ${data.value.name} ${data.value.family}   ",
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
                                                        ? 0
                                                        : 1
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
                                                      " ${data.value.in_review ? 'review'.tr : data.value.active ? 'active'.tr : 'inactive'.tr}",
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
                                                  onTap: () {
                                                    Get.dialog(SubscribeDialog(
                                                      colors: colors,
                                                      type: 'player',
                                                      id: "${data.value.id}",
                                                      onPressed: (params) =>
                                                          () async {},
                                                    )).then((result) {
                                                      if (result != null &&
                                                          result['msg'] !=
                                                              null &&
                                                          result['status'] !=
                                                              null) {
                                                        settingController.helper
                                                            .showToast(
                                                                msg: result[
                                                                    'msg'],
                                                                status: result[
                                                                    'status']);
                                                      }
                                                      refresh();
                                                    });
                                                    ;
                                                  },
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
                                                        color:
                                                            expireDays() == '0'
                                                                ? Colors.red
                                                                : Colors.green),
                                                    child: Text(
                                                      "${'validity'.tr} ${expireDays()} ${'d'.tr}",
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
                                //player section
                                Container(
                                    // padding: EdgeInsets.all(styleController.cardMargin),
                                    constraints: BoxConstraints(maxHeight: 300),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(styleController
                                              .cardBorderRadius)),
                                      child: ChewiePlayer(
                                          mode: 'edit',
                                          onLoaded: (path) async {
                                            File f = File(path);
                                            if (!f.existsSync()) return;
                                            Uint8List value =
                                                await File(path).readAsBytes();
                                            if (!value.isEmpty) {
                                              edit({
                                                'video': MultipartFile(value,
                                                    filename: 'upload.mp4'),
                                                'data_id': "${data.value.id}",
                                                'cmnd': 'upload-vid',
                                                'replace': true,
                                                'id':
                                                    settingController.getDocId(
                                                        data.value.docLinks,
                                                        'video'),
                                              });
                                            }
                                          },
                                          onRefresh: () => refresh(),
                                          src: controller.getVideoLink(
                                              data.value.docLinks),
                                          placeHolder:
                                              "${data.value.name} ${data.value.family}",
                                          colors: colors),
                                    )),
                                Container(
                                  child: Padding(
                                      padding: EdgeInsets.all(
                                          styleController.cardMargin / 4),
                                      child: Column(
                                        children: [
                                          if (isEditable())
                                            MiniCard(
                                              colors: colors,
                                              title: "${'gender'.tr}",
                                              desc1: '',
                                              desc2: null,
                                              child: Center(
                                                child: ToggleButtons(
                                                    constraints:
                                                        BoxConstraints.expand(
                                                            width: Get.width /
                                                                    2 -
                                                                styleController
                                                                        .cardMargin *
                                                                    3),
                                                    children: [
                                                      Container(
                                                          padding: EdgeInsets.all(
                                                              styleController
                                                                  .cardMargin),
                                                          child:
                                                              Text('man'.tr)),
                                                      Container(
                                                          padding: EdgeInsets.all(
                                                              styleController
                                                                  .cardMargin),
                                                          child:
                                                              Text('woman'.tr))
                                                    ],
                                                    selectedColor: Colors.white,
                                                    splashColor: Colors.white,
                                                    disabledColor: Colors.white,
                                                    fillColor: colors[500],
                                                    color: colors[500],
                                                    borderColor: colors[500],
                                                    selectedBorderColor:
                                                        Colors.white,
                                                    borderWidth: 1,
                                                    onPressed: (idx) {
                                                      edit({
                                                        'is_man':
                                                            idx == 1 ? 0 : 1
                                                      });
                                                    },
                                                    borderRadius: BorderRadius
                                                        .all(Radius.circular(
                                                            styleController
                                                                    .cardBorderRadius /
                                                                2)),
                                                    isSelected: [
                                                      data.value.is_man as bool,
                                                      !(data.value.is_man
                                                          as bool)
                                                    ]),
                                              ),
                                              styleController: styleController,
                                            ),
                                          if (isEditable())
                                            MiniCard(
                                              colors: colors,
                                              styleController: styleController,
                                              desc1:
                                                  "${data.value.name} ${data.value.family}",
                                              title:
                                                  "${'name'.tr} ${'and'.tr} ${'family'.tr}",
                                              onTap: () =>
                                                  showEditDialog(params: {
                                                'name': data.value.name,
                                                'family': data.value.family,
                                              }),
                                            ),
                                          MiniCard(
                                            colors: colors,
                                            title: 'sport'.tr,
                                            desc1: settingController
                                                .sport(data.value.sport_id),
                                            desc2: null,
                                            styleController: styleController,
                                            onTap: () =>
                                                showEditDialog(params: {
                                              'sport_id': data.value.sport_id,
                                            }, dropdowns: {
                                              'sport_id':
                                                  settingController.sports
                                            }),
                                          ),
                                          MiniCard(
                                            colors: colors,
                                            title:
                                                "${'province'.tr} ${'and'.tr} ${'county'.tr}",
                                            desc1: settingController.province(
                                                data.value.province_id),
                                            desc2: settingController
                                                .county(data.value.county_id),
                                            styleController: styleController,
                                            onTap: () =>
                                                showEditDialog(params: {
                                              'province_id':
                                                  data.value.province_id,
                                              'county_id': data.value.county_id,
                                            }, dropdowns: {
                                              'province_id':
                                                  settingController.provinces,
                                              'county_id':
                                                  settingController.counties
                                            }),
                                          ),
                                          if (!isEditable())
                                            MiniCard(
                                                colors: colors,
                                                title: 'age'.tr,
                                                desc1: "${data.value.age}",
                                                desc2: null,
                                                onTap: () =>
                                                    showEditDialog(params: {
                                                      'age':
                                                          "${data.value.age}",
                                                    }),
                                                styleController:
                                                    styleController),
                                          if (isEditable())
                                            MiniCard(
                                                colors: colors,
                                                title: 'born_at'.tr,
                                                desc1:
                                                    "${bornAt.value.yyyy}/${bornAt.value.mm}/${bornAt.value.dd}",
                                                desc2: null,
                                                styleController:
                                                    styleController,
                                                onTap: () =>
                                                    showEditDialog(params: {
                                                      'd': bornAt.value.d,
                                                      'm': bornAt.value.m,
                                                      'y': bornAt.value.yyyy,
                                                    }, dropdowns: {
                                                      'd': 1.to(31).map((e) => {
                                                            'id': "$e",
                                                            'name': "$e"
                                                          }),
                                                      'm': 1.to(12).map((e) => {
                                                            'id': "$e",
                                                            'name': "$e"
                                                          }),
                                                      'y': 1300.to(1450).map(
                                                          (e) => {
                                                                'id': "$e",
                                                                'name': "$e"
                                                              }),
                                                    })),
                                          MiniCard(
                                              colors: colors,
                                              title: 'height'.tr,
                                              desc1: "${data.value.height}",
                                              desc2: null,
                                              onTap: () =>
                                                  showEditDialog(params: {
                                                    'height': data.value.height,
                                                  }),
                                              styleController: styleController),
                                          MiniCard(
                                              colors: colors,
                                              title: 'weight'.tr,
                                              desc1: "${data.value.weight}",
                                              desc2: null,
                                              onTap: () =>
                                                  showEditDialog(params: {
                                                    'weight': data.value.weight,
                                                  }),
                                              styleController: styleController),
                                          InkWell(
                                              onTap: isEditable()
                                                  ? () =>
                                                      showEditDialog(params: {
                                                        'phone':
                                                            data.value.phone,
                                                        'phone_verify': ''
                                                      })
                                                  : () async {
                                                      final Uri launchUri = Uri(
                                                        scheme: 'tel',
                                                        path:
                                                            "${data.value.phone}",
                                                      );
                                                      launchUrl(launchUri);
                                                    },
                                              child: MiniCard(
                                                  colors: colors,
                                                  title: 'phone'.tr,
                                                  desc1: "${data.value.phone}",
                                                  desc2: "📱",
                                                  styleController:
                                                      styleController)),
                                          MiniCard(
                                              colors: colors,
                                              title: 'description'.tr,
                                              desc1:
                                                  "${data.value.description ?? '_'}",
                                              desc2: null,
                                              onTap: () =>
                                                  showEditDialog(params: {
                                                    'description':
                                                        data.value.description,
                                                  }),
                                              styleController: styleController),
                                        ],
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]),
                ),

                Positioned.fill(
                  child: Visibility(
                      visible: loading.value,
                      child: Container(
                        color: Colors.black54,
                        child: Center(
                          child: Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    styleController.cardMargin)),
                            child: Padding(
                              padding:
                                  EdgeInsets.all(styleController.cardMargin),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: uploadPercent.value,
                                    color: colors[800],
                                    backgroundColor: Colors.white,
                                  ),
                                  // SizedBox(
                                  //   height: styleController.cardMargin,
                                  // ),
                                  // Text(
                                  //   'uploading'.tr + '...',
                                  //   style: styleController.textMediumStyle,
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future edit(Map<String, dynamic> params) async {
    loading.value = true;

    ReceivePort receivePort = ReceivePort();

    final isolate = await Isolate.spawn<Map<String, dynamic>>(editThread, {
      'port': receivePort.sendPort,
      "data": {'id': data.value.id, ...params},
      'ACCESS_TOKEN': Get.find<UserController>().ACCESS_TOKEN,
      'url': Variables.LINK_EDIT_PLAYERS,
      // "controller": controller,
      // 'loading': loading
    });
    receivePort.listen((dynamic thread) {
      // print("${thread['end']} ${thread['progress']} ${thread['msg']} ");

      if (thread['progress'] != null) uploadPercent.value = thread['progress'];
      if (thread['end']) {
        isolate.kill(priority: Isolate.immediate);
        if (thread != null) {
          if (!params.keys.contains('active') &&
              !params.keys.contains('is_man') &&
              !params.keys.contains('video')) Get.back();
          settingController.helper.showToast(
              msg: thread['msg'] ?? 'edited_successfully'.tr,
              status: thread['status'] ?? 'success');
          refresh();
        }
        loading.value = false;
      }
    });

    // final res = await receivePort.first;

    // var res = await controller.edit(
    //     params: {'id': data.value.id, ...params},
    //     onProgress: (percent) {
    //       uploadPercent.value = percent;
    //       // print(percent);
    //       // print(percent.runtimeType);
    //     });

    // if (res != null) {
    //   if (!params.keys.contains('is_man') && !params.keys.contains('video'))
    //     Get.back();
    //   settingController.helper.showToast(
    //       msg: res['msg'] ?? 'edited_successfully'.tr, status: 'success');
    //   refresh();
    // }
    // loading.value = false;
  }

  bool isEditable() {
    return settingController.isEditable(data.value.user_id);
  }

  String expireDays() {
    return settingController.expireDays(data.value.expires_at);
  }

  refresh() async {
    Player? res = await controller.find({'id': data.value.id, 'panel': '1'});

    if (res != null) {
      this.data.value = res;
      if (data.value.born_at != null)
        bornAt.value = Jalali.fromDateTime(
                DateTime.fromMillisecondsSinceEpoch(data.value.born_at! * 1000))
            .formatter;
      if (index != -1) {
        controller.data[index] = data.value;
      }
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
                      if (params.keys.contains('phone_verify'))
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                  style: ButtonStyle(
                                      overlayColor:
                                          MaterialStateProperty.resolveWith(
                                        (states) {
                                          return states.contains(
                                                  MaterialState.pressed)
                                              ? styleController.secondaryColor
                                              : null;
                                        },
                                      ),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              colors[700]),
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                        borderRadius: BorderRadius.horizontal(
                                          right: Radius.circular(
                                              styleController.cardBorderRadius /
                                                  2),
                                          left: Radius.circular(
                                              styleController.cardBorderRadius /
                                                  2),
                                        ),
                                      ))),
                                  onPressed: () =>
                                      controller.sendActivationCode(
                                          phone: tcs['phone']!.text),
                                  child: Text(
                                    'receive_code'.tr,
                                    style: styleController.textMediumLightStyle,
                                  )),
                            ),
                          ],
                        ),
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
        barrierDismissible: true,
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
                      color: colors[500],
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
}

FutureOr<dynamic> editThread(params) async {
  SendPort port = params['port'];

  double p = 0.0;
  double pLast = 0.0;
  ApiProvider apiProvider = ApiProvider();

  var parsedJson = await apiProvider.fetch(params['url'],
      param: params['data'],
      ACCESS_TOKEN: params['ACCESS_TOKEN'],
      method: 'post', onProgress: (percent) {
    p = (percent / 100).toPrecision(1);
    if ((p == 0.1 || p == 0.3 || p == 0.5 || p == 0.7 || p == 0.9 || p == 1) &&
        p > pLast) {
      pLast = p;
      // print(p);
      port.send({'progress': p, "end": false});
    }
  });
  // print(parsedJson);
  String? msg = '';
  var status = 'danger';
  if (parsedJson != null && parsedJson['errors'] != null) {
    status = 'danger';
    if (parsedJson['errors'] is List<dynamic>)
      msg = parsedJson['errors']?.join("\n").toString();
    else
      msg = parsedJson['errors'][parsedJson['errors'].keys.elementAt(0)]
          .join("\n");
  } else if (parsedJson != null && parsedJson['msg'] != null) {
    msg = parsedJson['msg'] ?? '';
    status = parsedJson['status'] ?? status;
  }
  port.send({'progress': p, "end": true, 'msg': msg, 'status': status});

  return parsedJson;
}
