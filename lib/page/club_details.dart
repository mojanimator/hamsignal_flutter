import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dabel_sport/controller/ClubController.dart';
import 'package:dabel_sport/controller/SettingController.dart';
import 'package:dabel_sport/helper/styles.dart';
import 'package:dabel_sport/helper/variables.dart';
import 'package:dabel_sport/model/Club.dart';
import 'package:dabel_sport/widget/MyGallery.dart';
import 'package:dabel_sport/widget/MyMap.dart';
import 'package:dabel_sport/widget/club_times.dart';
import 'package:dabel_sport/widget/mini_card.dart';
import 'package:dabel_sport/widget/shakeanimation.dart';
import 'package:dabel_sport/widget/subscribe_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ClubDetails extends StatelessWidget {
  late Rx<Club> data;

  ClubController controller = Get.find<ClubController>();
  MapController mapController = MapController();
  late MaterialColor colors;
  late TextStyle titleStyle;

  final SettingController settingController = Get.find<SettingController>();
  int index;
  final Style styleController = Get.find<Style>();

  RxDouble uploadPercent = RxDouble(0.0);
  RxBool loading = RxBool(false);

  ClubDetails({required data, MaterialColor? colors, int this.index = -1}) {
    this.colors = colors ?? styleController.cardCoachColors;
    titleStyle =
        styleController.textMediumStyle.copyWith(color: this.colors[900]);
    this.data = Rx<Club>(data);
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
                                                                fit: BoxFit
                                                                    .contain,
                                                                imageUrl:
                                                                    "${controller.getProfileLink(data.value.docLinks, editable: isEditable())}",
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
                                                                        () {
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
                                                                        color: colors[
                                                                            50],
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
                                                                        settingController.clearImageCache(
                                                                            url:
                                                                                "${controller.getProfileLink(data.value.docLinks, editable: isEditable())}");
                                                                        if (img !=
                                                                            null)
                                                                          edit({
                                                                            'img':
                                                                                img,
                                                                            'cmnd':
                                                                                'upload-img',
                                                                            'replace':
                                                                                true,
                                                                            'type':
                                                                                settingController.getDocType('license'),
                                                                            'id':
                                                                                settingController.getDocId(data.value.docLinks, isEditable() ? 'license' : 'club'),
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
                                                                              colors[50],
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
                                            child: Stack(
                                              children: [
                                                CachedNetworkImage(
                                                  height: styleController
                                                      .imageHeight,
                                                  width: styleController
                                                      .imageHeight,
                                                  imageUrl:
                                                      "${controller.getProfileLink(data.value.docLinks, editable: isEditable())}",
                                                  imageBuilder: (context,
                                                          imageProvider) =>
                                                      Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(
                                                          styleController
                                                              .cardBorderRadius,
                                                        ),
                                                        topRight:
                                                            Radius.circular(
                                                          styleController
                                                              .cardBorderRadius,
                                                        ),
                                                        bottomRight:
                                                            Radius.circular(
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
                                                                  BlendMode
                                                                      .darken),
                                                          image: imageProvider,
                                                          fit: BoxFit.cover,
                                                          filterQuality:
                                                              FilterQuality
                                                                  .medium),
                                                    ),
                                                  ),
                                                  placeholder: (context, url) =>
                                                      CupertinoActivityIndicator(),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          ClipRRect(
                                                    borderRadius: BorderRadius
                                                        .all(Radius.circular(
                                                            styleController
                                                                .cardBorderRadius)),
                                                    child: Image.network(
                                                        Variables.NOIMAGE_LINK),
                                                  ),
                                                ),
                                                if (isEditable())
                                                  Positioned.fill(
                                                    child: Icon(
                                                      Icons.zoom_out_map_sharp,
                                                      color: colors[50],
                                                    ),
                                                  ),
                                              ],
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
                                                      type: 'club',
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
                                                editable: isEditable()),
                                            height: styleController
                                                .cardVitrinHeight,
                                            autoplay: !isEditable(),
                                            fullScreen: false,
                                            colors: colors,
                                            infoText:
                                                "${'club'.tr} ${data.value.name}",
                                            styleController: styleController,
                                            ratio: settingController
                                                .cropRatio['club'],
                                            limit: settingController
                                                .limits['club'],
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
                                                          .getDocType('club'))
                                                  .toList();

                                              if (index + 1 <= docs.length)
                                                settingController.clearImageCache(
                                                    url:
                                                        "${Variables.LINK_STORAGE}/${data.value.docLinks[index]['type_id']}/${data.value.docLinks[index]['id']}.jpg");

                                              edit({
                                                'img': img,
                                                'cmnd': file == null
                                                    ? 'delete-img'
                                                    : 'upload-img',
                                                'replace':
                                                    index + 1 <= docs.length,
                                                'type': settingController
                                                    .getDocType('club'),
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
                                                      "${'name'.tr} ${'club'.tr}",
                                                  onTap: () =>
                                                      showEditDialog(params: {
                                                    'name': data.value.name,
                                                  }),
                                                ),
                                              MiniCard(
                                                colors: colors,
                                                title:
                                                    "${'province'.tr} ${'and'.tr} ${'county'.tr}",
                                                desc1:
                                                    settingController.province(
                                                        data.value.province_id),
                                                desc2: settingController.county(
                                                    data.value.county_id),
                                                styleController:
                                                    styleController,
                                                onTap: () =>
                                                    showEditDialog(params: {
                                                  'province_id':
                                                      data.value.province_id,
                                                  'county_id':
                                                      data.value.county_id,
                                                }, dropdowns: {
                                                  'province_id':
                                                      settingController
                                                          .provinces,
                                                  'county_id':
                                                      settingController.counties
                                                }),
                                              ),
                                              MiniCard(
                                                colors: colors,
                                                styleController:
                                                    styleController,
                                                desc1: "${data.value.name}",
                                                title: "${'location'.tr}",
                                                child: MyMap(
                                                    mapController:
                                                        mapController,
                                                    height: 48,
                                                    editable: isEditable(),
                                                    location:
                                                        data.value.location,
                                                    onChanged: (pos) {
                                                      edit({'location': pos});
                                                    }),
                                              ),
                                              MiniCard(
                                                  colors: colors,
                                                  title: 'address'.tr,
                                                  desc1:
                                                      "${data.value.address}",
                                                  desc2: null,
                                                  onTap: () =>
                                                      showEditDialog(params: {
                                                        'address':
                                                            data.value.address,
                                                      }),
                                                  styleController:
                                                      styleController),
                                              MiniCard(
                                                colors: colors,
                                                title: 'times'.tr,
                                                desc1: "${data.value.address}",
                                                desc2: null,
                                                styleController:
                                                    styleController,
                                                child: Column(
                                                  children: [
                                                    ClubTimes(
                                                        colors: colors,
                                                        editable: isEditable(),
                                                        times: data.value.times,
                                                        onChange: (times) {
                                                          data.value.times =
                                                              times;
                                                        }),
                                                    if (isEditable())
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: TextButton(
                                                              style:
                                                                  ButtonStyle(
                                                                      padding: MaterialStateProperty.all(EdgeInsets.all(
                                                                          styleController.cardMargin /
                                                                              2)),
                                                                      overlayColor:
                                                                          MaterialStateProperty
                                                                              .resolveWith(
                                                                        (states) {
                                                                          return states.contains(MaterialState.pressed)
                                                                              ? styleController.secondaryColor
                                                                              : null;
                                                                        },
                                                                      ),
                                                                      backgroundColor:
                                                                          MaterialStateProperty.all(colors[
                                                                              800]),
                                                                      shape: MaterialStateProperty
                                                                          .all(
                                                                              RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.all(
                                                                          Radius.circular(styleController.cardBorderRadius /
                                                                              2),
                                                                        ),
                                                                      ))),
                                                              onPressed:
                                                                  () async {
                                                                edit({
                                                                  'times': json
                                                                      .encode(data
                                                                          .value
                                                                          .times)
                                                                });
                                                              },
                                                              child: Icon(
                                                                  Icons.check,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              InkWell(
                                                  onTap: isEditable()
                                                      ? () => showEditDialog(
                                                              params: {
                                                                'phone': data
                                                                    .value
                                                                    .phone,
                                                                'phone_verify':
                                                                    ''
                                                              })
                                                      : () async {
                                                          final Uri launchUri =
                                                              Uri(
                                                            scheme: 'tel',
                                                            path:
                                                                "${data.value.phone}",
                                                          );
                                                          launchUrl(launchUri);
                                                        },
                                                  child: MiniCard(
                                                      colors: colors,
                                                      title: 'phone'.tr,
                                                      desc1:
                                                          "${data.value.phone}",
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
                                                        'description': data
                                                                .value
                                                                .description ??
                                                            '',
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
                    child: Container(
                      color: Colors.black54,
                      child: Center(
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  styleController.cardMargin)),
                          child: Padding(
                            padding: EdgeInsets.all(styleController.cardMargin),
                            child: CircularProgressIndicator(
                              value: uploadPercent.value / 100,
                              color: colors[800],
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
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
      if (!params.keys.contains('active') && !params.keys.contains('times'))
        Get.back();
      settingController.helper.showToast(
          msg: res['msg'] ?? 'edited_successfully'.tr, status: 'success');
      refresh();
    }
    loading.value = false;
  }

  bool isEditable() {
    return settingController.isEditable(data.value.user_id);
  }

  String expireDays() {
    return settingController.expireDays(data.value.expires_at);
  }

  refresh() async {
    Club? res = await controller.find({'id': data.value.id, 'panel': '1'});

    if (res != null) {
      settingController.clearImageCache(
          url:
          "${controller.getProfileLink(data.value.docLinks, editable: isEditable())}");
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
                    minLines: e == 'description' || e == 'address' ? 3 : 1,
                    // expands: true,
                    maxLines: e == 'description' || e == 'address' ? null : 1,
                    autofocus: true,
                    textAlign: e == 'name' ||
                            e == 'family' ||
                            e == 'description' ||
                            e == 'address'
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
