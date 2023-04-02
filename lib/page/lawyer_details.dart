import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dabel_adl/controller/LawyerController.dart';
import 'package:dabel_adl/controller/SettingController.dart';
import 'package:dabel_adl/helper/styles.dart';
import 'package:dabel_adl/helper/variables.dart';
import 'package:dabel_adl/model/Lawyer.dart';
import 'package:dabel_adl/widget/MyGallery.dart';
import 'package:dabel_adl/widget/MyMap.dart';
import 'package:dabel_adl/widget/mini_card.dart';
import 'package:dabel_adl/widget/report_dialog.dart';
import 'package:dabel_adl/widget/shakeanimation.dart';
import 'package:dabel_adl/widget/subscribe_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class LawyerDetails extends StatelessWidget {
  late Rx<Lawyer> data;

  LawyerController controller = Get.find<LawyerController>();
  MapController mapController = MapController();
  late MaterialColor colors;
  late TextStyle titleStyle;

  final SettingController settingController = Get.find<SettingController>();
  int index;
  final Style styleController = Get.find<Style>();

  RxDouble uploadPercent = RxDouble(0.0);
  RxBool loading = RxBool(false);

  Rx<Map<String, String>> cacheHeaders = Rx<Map<String, String>>({});

  LawyerDetails({required data, MaterialColor? colors, int this.index = -1}) {
    this.colors = colors ?? styleController.cardLinkColors;
    titleStyle =
        styleController.textMediumStyle.copyWith(color: this.colors[900]);
    this.data = Rx<Lawyer>(data);

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      refresh();
    });
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
                        httpHeaders: cacheHeaders.value,
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
                        imageUrl: "${data.value.avatar}",
                        errorWidget: (context, url, error) => Container(
                          child: Image.asset('assets/images/icon-dark.png',
                              fit: BoxFit.cover),
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
                                                                httpHeaders:
                                                                    cacheHeaders
                                                                        .value,
                                                                fit: BoxFit
                                                                    .contain,
                                                                imageUrl: data
                                                                    .value
                                                                    .avatar,
                                                                useOldImageOnUrlChange:
                                                                    true,
                                                                errorWidget: (context,
                                                                        url,
                                                                        error) =>
                                                                    Container(
                                                                  child: Image.asset(
                                                                      'assets/images/icon-dark.png',
                                                                      fit: BoxFit
                                                                          .contain),
                                                                ),
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

                                                                        if (img !=
                                                                            null) {
                                                                          Get.back();
                                                                          await edit({
                                                                            'img':
                                                                                img,
                                                                            'cmnd':
                                                                                'upload-img',
                                                                            'replace':
                                                                                true,
                                                                            'type':
                                                                                settingController.getDocType('license'),
                                                                            'id':
                                                                                data.value.id,
                                                                            'data_id':
                                                                                "${data.value.id}"
                                                                          });
                                                                          cacheHeaders.value =
                                                                              {
                                                                            'Cache-Control':
                                                                                'max-age=0, no-cache, no-store'
                                                                          };
                                                                          settingController.clearImageCache(
                                                                              url: "${data.value.avatar}");
                                                                        }
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
                                                  httpHeaders:
                                                      cacheHeaders.value,
                                                  height: styleController
                                                      .imageHeight,
                                                  width: styleController
                                                      .imageHeight,
                                                  imageUrl: data.value.avatar,
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
                                                          Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(
                                                          styleController
                                                              .cardBorderRadius,
                                                        ),
                                                      ),
                                                    ),
                                                    child: Image.asset(
                                                        'assets/images/icon-dark.png',
                                                        fit: BoxFit.cover),
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
                                    IntrinsicWidth(
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: colors[500],
                                            child: IconButton(
                                              onPressed: () async {
                                                Uri phone = Uri(
                                                    scheme: 'tel',
                                                    path:
                                                        data.value.mobile != ''
                                                            ? data.value.mobile
                                                            : data.value.tel);
                                                if (await canLaunchUrl(phone))
                                                  launchUrl(phone);
                                              },
                                              icon: Icon(
                                                Icons.phone,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: styleController.cardMargin,
                                          ),
                                          CircleAvatar(
                                            backgroundColor: colors[500],
                                            child: IconButton(
                                              onPressed: () async {
                                                edit(
                                                    {'mark': !data.value.mark});
                                              },
                                              icon: Icon(
                                                data.value.mark
                                                    ? Icons.bookmark
                                                    : Icons.bookmark_border,
                                                color: Colors.white,
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
                                          Column(
                                            children: [
                                              MiniCard(
                                                colors: colors,
                                                styleController:
                                                    styleController,
                                                desc1:
                                                    "${data.value.lawyerNumber}",
                                                title: "${'cert_number'.tr}",
                                                onTap: () => isEditable()
                                                    ? showEditDialog(params: {
                                                        'lawyer_number':
                                                            data.value.fullName,
                                                      })
                                                    : null,
                                              ),
                                              MiniCard(
                                                colors: colors,
                                                styleController:
                                                    styleController,
                                                desc1: "",
                                                title: "${'activity'.tr}",
                                                onTap: () => isEditable()
                                                    ? showEditDialog(params: {
                                                        'category': data
                                                            .value.categories
                                                            .join(','),
                                                      })
                                                    : null,
                                                child: Wrap(
                                                    alignment:
                                                        WrapAlignment.center,
                                                    children:
                                                        data.value
                                                            .lawyerCategories
                                                            .asMap()
                                                            .map((i, e) {
                                                              return MapEntry(
                                                                  i,
                                                                  IntrinsicWidth(
                                                                    child:
                                                                        IntrinsicHeight(
                                                                      child: Row(
                                                                          children: [
                                                                            Text(
                                                                              "${e}",
                                                                              style: titleStyle.copyWith(fontWeight: FontWeight.bold, color: colors[500]),
                                                                            ),
                                                                            data.value.lawyerCategories.length == i + 1
                                                                                ? Center()
                                                                                : VerticalDivider()
                                                                          ]),
                                                                    ),
                                                                  ));
                                                            })
                                                            .values
                                                            .toList()),
                                              ),
                                              MiniCard(
                                                colors: colors,
                                                styleController:
                                                    styleController,
                                                desc1: "${data.value.fullName}",
                                                title:
                                                    "${'name'.tr} ${'family'.tr}",
                                                onTap: () => isEditable()
                                                    ? showEditDialog(params: {
                                                        'name':
                                                            data.value.fullName,
                                                      })
                                                    : null,
                                              ),
                                              MiniCard(
                                                colors: colors,
                                                title:
                                                    "${'province'.tr} ${'and'.tr} ${'county'.tr}",
                                                desc1: data.value.location,
                                                styleController:
                                                    styleController,
                                                onTap: () => isEditable()
                                                    ? showEditDialog(params: {
                                                        'province_id':
                                                            data.value.cityId,
                                                        'county_id':
                                                            data.value.cityId,
                                                      }, dropdowns: {
                                                        'province_id':
                                                            settingController
                                                                .provinces,
                                                        'county_id':
                                                            settingController
                                                                .counties
                                                      })
                                                    : null,
                                              ),
                                              InkWell(
                                                  onTap: isEditable()
                                                      ? () => showEditDialog(
                                                              params: {
                                                                'phone': data
                                                                    .value
                                                                    .fullName,
                                                                'phone_verify':
                                                                    ''
                                                              })
                                                      : () async {
                                                          final Uri launchUri =
                                                              Uri(
                                                            scheme: 'tel',
                                                            path:
                                                                "${data.value.mobile}",
                                                          );
                                                          launchUrl(launchUri);
                                                        },
                                                  child: MiniCard(
                                                      colors: colors,
                                                      title: 'phone'.tr,
                                                      desc1: data.value
                                                                  .mobile !=
                                                              ''
                                                          ? "${data.value.mobile}"
                                                          : "${data.value.tel}",
                                                      desc2: "📱",
                                                      styleController:
                                                          styleController)),
                                              if (data.value.email != '')
                                                InkWell(
                                                    onTap: isEditable()
                                                        ? () => showEditDialog(
                                                                params: {
                                                                  'email': data
                                                                      .value
                                                                      .email,
                                                                })
                                                        : () async {
                                                            final Uri email =
                                                                Uri(
                                                              scheme: 'mailto',
                                                              path:
                                                                  "${data.value.email}",
                                                            );
                                                            if (await launchUrl(
                                                                email))
                                                              launchUrl(email);
                                                          },
                                                    child: MiniCard(
                                                        colors: colors,
                                                        title: 'email'.tr,
                                                        desc1:
                                                            "${data.value.email}",
                                                        desc2: "📧",
                                                        styleController:
                                                            styleController)),
                                              MiniCard(
                                                  colors: colors,
                                                  title: 'address'.tr,
                                                  desc1:
                                                      "${data.value.address}",
                                                  // desc2: "📌",
                                                  styleController:
                                                      styleController),
                                              MiniCard(
                                                  colors: colors,
                                                  title: 'bio'.tr,
                                                  desc1: "${data.value.cv}",
                                                  // desc2: "✏️",
                                                  child: Padding(
                                                    padding:   EdgeInsets.all(styleController.cardMargin),
                                                    child: Text("${data.value.cv}"),
                                                  ),
                                                  styleController:
                                                      styleController),
                                              ReportDialog(
                                                colors: colors,
                                                text:
                                                    "${Variables.LINK_GET_LAWYERS}/${data.value.id}",
                                              )
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
                              value: null /*uploadPercent.value / 100*/,
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
    if (params['mark'] != null)
      final res = await controller.mark(data.value.id);
    refresh();
    loading.value = false;
  }

  bool isEditable() {
    return false;
  }

  String expireDays() {
    return settingController.expireDays(0);
  }

  refresh() async {
    Lawyer? res = await controller.find({'id': data.value.id, 'panel': '1'});

    if (res != null) {
      this.data.value = res;
      // cacheHeaders.value = {'Cache-Control': 'max-age=0, no-cache, no-store'};
      // profileUrl.value = controller.getProfileLink(this.data.value.docLinks,
      //     editable: isEditable());
      // settingController.clearImageCache(
      //     url:
      //         "${controller.getProfileLink(this.data.value.docLinks, editable: isEditable())}");

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
