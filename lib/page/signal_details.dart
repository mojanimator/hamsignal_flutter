import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:hamsignal/controller/SettingController.dart';
import 'package:hamsignal/helper/styles.dart' as Styles;
import 'package:hamsignal/helper/variables.dart';
import 'package:hamsignal/widget/MyGallery.dart';
import 'package:hamsignal/widget/shakeanimation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../controller/SignalController.dart';
import '../model/Signal.dart';

class SignalDetails extends StatelessWidget {
  late Rx<Signal> data;

  SignalController controller = Get.find<SignalController>();

  late MaterialColor colors;
  late TextStyle titleStyle;
  RxDouble uploadPercent = RxDouble(0.0);
  final SettingController settingController = Get.find<SettingController>();
  int index;
  final Styles.Style style = Get.find<Styles.Style>();

  RxBool loading = RxBool(false);

  late BoxDecoration borderDecoration;

  SignalDetails({required Signal data, int this.index = -1}) {
    titleStyle = style.textMediumStyle.copyWith(color: colors[900]);

    this.data = Rx<Signal>(data);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      refresh();
    });

    borderDecoration = BoxDecoration(
        border: Border.all(
          color: colors[500]!,
        ),
        borderRadius:
            BorderRadius.all(Radius.circular(style.cardBorderRadius / 2)));
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
                      Stack(
                        children: [
                          CachedNetworkImage(
                            fit: BoxFit.cover,
                            height: Get.height / 3 + style.cardBorderRadius * 2,
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    colorFilter: ColorFilter.mode(
                                        colors[200]!.withOpacity(.3),
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
                            imageUrl: data.value.link,
                          ),
                          Positioned.fill(
                            child: Center(
                              child: Container(
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            colors[500]?.withOpacity(.2)
                                                as Color,
                                            colors[500]?.withOpacity(.5)
                                                as Color,
                                            colors[500]?.withOpacity(.5)
                                                as Color,
                                            colors[500]?.withOpacity(.2)
                                                as Color,
                                          ]),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(
                                              style.cardBorderRadius / 2))),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: style.cardMargin,
                                      vertical: style.cardMargin),
                                  child: Text(
                                    data.value.name,
                                    textAlign: TextAlign.center,
                                    style: style.textMediumLightStyle,
                                  )),
                            ),
                          ),
                        ],
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
                          height: style.topOffset,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(
                                      style.cardBorderRadius * 2),
                                  topLeft: Radius.circular(
                                      style.cardBorderRadius * 2))),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  IntrinsicWidth(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    style.cardMargin / 2,
                                                vertical: style.cardMargin),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                child: Padding(
                                    padding:
                                        EdgeInsets.all(style.cardMargin / 4),
                                    child: Column(
                                      children: [
                                        Column(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: style.cardMargin,
                                                vertical: style.cardMargin / 2,
                                              ),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        data.value.created_at,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: style
                                                            .textMediumStyle
                                                            .copyWith(
                                                                color: colors[
                                                                    500]),
                                                      ),
                                                    ],
                                                  ),
                                                  Divider(),
                                                  if (data.value.name != '')
                                                    Container(
                                                        margin: EdgeInsets.all(
                                                            style.cardMargin /
                                                                4),
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: style
                                                                        .cardMargin /
                                                                    2),
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: Text(
                                                          data.value.name,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: style
                                                              .textSmallLightStyle
                                                              .copyWith(
                                                                  color: colors[
                                                                      700]),
                                                        )),
                                                ],
                                              ),
                                            ),
                                            if (data.value.name != '')
                                              Card(
                                                elevation: 5,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                            top: Radius
                                                                .circular(style
                                                                    .cardBorderRadius))),
                                                child: Center(
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: style
                                                                .cardMargin,
                                                            vertical: style
                                                                    .cardMargin *
                                                                2),
                                                    child: Column(
                                                      children: [

                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              )
                                          ],
                                        ),
                                        //tags
                                        if (false)
                                          Card(
                                            color: colors[50],
                                            elevation: 5,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.vertical(
                                                    bottom: Radius.circular(style
                                                        .cardBorderRadius))),
                                            child: Center(
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: style.cardMargin,
                                                  vertical:
                                                      style.cardMargin / 4,
                                                ),
                                                child: SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Wrap(
                                                    runSpacing: 0,
                                                    spacing:
                                                        style.cardMargin / 4,
                                                    children: [
                                                      for (var tag in [])
                                                        TextButton(
                                                          style:
                                                              style.buttonStyle(
                                                                  backgroundColor:
                                                                      colors[
                                                                          50]!),
                                                          onPressed: () {},
                                                          child: Text(
                                                            tag,
                                                            style: style
                                                                .textMediumStyle
                                                                .copyWith(
                                                                    color: colors[
                                                                        500]),
                                                          ),
                                                        )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                      ],
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ]),
                ),

                Visibility(
                    visible: loading.value,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: uploadPercent.value != 0
                            ? uploadPercent.value / 100
                            : null,
                        color: Colors.white,
                        backgroundColor: colors[700],
                      ),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  refresh() async {
    loading.value = true;
    Signal? tmp = await controller.find({'id': data.value.id});
    if (tmp != null) {
      this.data.value = tmp;
    }
    loading.value = false;
  }

  Widget paragraph(Map<String, dynamic> data) {
    return Container(
      padding: EdgeInsets.all(style.cardMargin),
      alignment: Alignment.centerRight,
      child: Text(
        data['text'] != null ? data['text'].replaceAll('&nbsp;', ' ') : '',
        style: style.textMediumStyle,
      ),
    );
  }

  Widget header(Map<String, dynamic> data) {
    return Container(
      padding: EdgeInsets.all(style.cardMargin),
      child: Text(
        data['text'] != null ? data['text'].replaceAll('&nbsp;', ' ') : '',
        style: style.textMediumStyle.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget list(Map<String, dynamic> data) {
    return Padding(
      padding: EdgeInsets.all(style.cardMargin),
      child: Column(
        children: [
          for (var item in data['items'] ?? [])
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.arrow_forward_ios_outlined),
                SizedBox(
                  width: style.cardMargin,
                ),
                Text(
                  item.replaceAll('&nbsp;', ' '),
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: colors[600]),
                ),
              ],
            )
        ],
      ),
    );
  }

  Widget quote(Map<String, dynamic> data) {
    return Padding(
      padding: EdgeInsets.all(style.cardMargin),
      child: Column(
        children: [
          if (data['caption'] != null)
            Container(
                child: Text(
              data['caption'].replaceAll('&nbsp;', ' '),
              style: TextStyle(color: colors[500]),
            )),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: style.cardMargin),
              child: Divider()),
          if (data['text'] != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.format_quote),
                Text(
                  data['text'].replaceAll('&nbsp;', ' '),
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: colors[800]),
                ),
                Icon(Icons.format_quote),
              ],
            )
        ],
      ),
    );
  }

  Widget table(Map<String, dynamic> data) {
    BoxDecoration cellStyle = BoxDecoration(
        borderRadius: BorderRadius.circular(style.cardBorderRadius / 4),
        border: Border.all(color: colors[100]!));
    List<dynamic> rows = data['Signal'];
    var heading = null;
    if (data['withHeadings'] != null) heading = rows.removeAt(0);
    return Container(
      margin: EdgeInsets.all(style.cardMargin / 2),
      child: Column(
        children: [
          if (data['withHeadings'] == true)
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (var item in heading)
                    Expanded(
                        child: Container(
                            padding: EdgeInsets.all(style.cardMargin / 4),
                            decoration: cellStyle.copyWith(
                              color: colors[50],
                            ),
                            child: Center(
                                child: Text(
                              item.replaceAll('&nbsp;', ' '),
                              style: style.textMediumStyle
                                  .copyWith(color: colors[500]),
                            ))))
                ],
              ),
            ),
          for (var row in rows)
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (var item in row)
                    Expanded(
                        child: Container(
                            padding: EdgeInsets.all(style.cardMargin / 4),
                            decoration: cellStyle,
                            child: Center(
                                child: Text(
                              item.replaceAll('&nbsp;', ' '),
                              style: style.textMediumStyle
                                  .copyWith(color: colors[500]),
                            ))))
                ],
              ),
            )
        ],
      ),
    );
  }
}
