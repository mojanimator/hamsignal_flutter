import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dabel_sport/controller/BlogController.dart';
import 'package:dabel_sport/controller/SettingController.dart';
import 'package:dabel_sport/helper/styles.dart';
import 'package:dabel_sport/helper/variables.dart';
import 'package:dabel_sport/model/Blog.dart';
import 'package:dabel_sport/widget/MyGallery.dart';
import 'package:dabel_sport/widget/shakeanimation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BlogDetails extends StatelessWidget {
  late Rx<Blog> data;

  BlogController controller = Get.find<BlogController>();

  late MaterialColor colors;
  late TextStyle titleStyle;
  RxDouble uploadPercent = RxDouble(0.0);
  final SettingController settingController = Get.find<SettingController>();
  int index;
  final Style styleController = Get.find<Style>();

  RxBool loading = RxBool(false);

  late BoxDecoration borderDecoration;

  BlogDetails({required Blog data, int this.index = -1}) {
    colors = styleController.cardBlogColors;
    titleStyle = styleController.textMediumStyle.copyWith(color: colors[900]);

    this.data = Rx<Blog>(data);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      refresh();
    });

    borderDecoration = BoxDecoration(
        border: Border.all(
          color: colors[500]!,
        ),
        borderRadius: BorderRadius.all(
            Radius.circular(styleController.cardBorderRadius / 2)));
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
                            fit: BoxFit.contain,
                            height: Get.height / 3 +
                                styleController.cardBorderRadius * 2,
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    colorFilter: ColorFilter.mode(
                                        colors[500]!.withOpacity(.2),
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
                                "${controller.getThumbLink(data.value.docLinks)}",
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
                                              styleController.cardBorderRadius /
                                                  2))),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: styleController.cardMargin,
                                      vertical: styleController.cardMargin),
                                  child: Text(
                                    data.value.title,
                                    textAlign: TextAlign.center,
                                    style: styleController.textMediumLightStyle,
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
                                              limit: 0,
                                              items: controller.getImageLinks(
                                                  data.value.docLinks),
                                              height: styleController
                                                  .cardVitrinHeight,
                                              autoplay:
                                                  data.value.docLinks.length >
                                                      1,
                                              fullScreen: false,
                                              colors: colors,
                                              infoText:
                                                  "${data.value.title} \n ${Variables.DOMAIN}/blog/${data.value.id}/${data.value.title.replaceAll(' ', '_').replaceAll('/', '')}",
                                              styleController: styleController),
                                          Column(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: styleController
                                                      .cardMargin,
                                                  vertical: styleController
                                                          .cardMargin /
                                                      2,
                                                ),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Text(
                                                          data.value
                                                              .published_at,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: styleController
                                                              .textTinyLightStyle
                                                              .copyWith(
                                                                  color: colors[
                                                                      200]),
                                                        ),
                                                      ],
                                                    ),
                                                    Divider(),
                                                    if (data.value.summary !=
                                                        '')
                                                      Container(
                                                          margin: EdgeInsets.all(
                                                              styleController
                                                                      .cardMargin /
                                                                  4),
                                                          padding: EdgeInsets.symmetric(
                                                              vertical:
                                                                  styleController
                                                                      .cardMargin),
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Text(
                                                            data.value.summary,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: styleController
                                                                .textSmallLightStyle
                                                                .copyWith(
                                                                    color: colors[
                                                                        500]),
                                                          )),
                                                  ],
                                                ),
                                              ),
                                              if (data.value.content != '')
                                                Card(
                                                  elevation: 5,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                              top: Radius.circular(
                                                                  styleController
                                                                      .cardBorderRadius))),
                                                  child: Center(
                                                    child: Padding(
                                                      padding: EdgeInsets.symmetric(
                                                          horizontal:
                                                              styleController
                                                                  .cardMargin,
                                                          vertical: styleController
                                                                  .cardMargin *
                                                              2),
                                                      child: Column(
                                                        children: [
                                                          for (var section in json
                                                              .decode(data.value
                                                                  .content))
                                                            if (section['type'] ==
                                                                'paragraph')
                                                              paragraph(section[
                                                                  'data'])
                                                            else if (section['type'] ==
                                                                    'image' &&
                                                                section['data']
                                                                            ?['file']
                                                                        ?[
                                                                        'url'] !=
                                                                    null)
                                                              image(section[
                                                                  'data'])
                                                            else if (section['type'] ==
                                                                'list')
                                                              list(section[
                                                                  'data'])
                                                            else if (section[
                                                                    'type'] ==
                                                                'table')
                                                              table(section['data'])
                                                            else if (section['type'] == 'header')
                                                              header(section['data'])
                                                            else if (section['type'] == 'quote')
                                                              quote(section['data'])
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                )
                                            ],
                                          ),
                                          if (data.value.tags != '')
                                            Card(
                                              color: colors[50],
                                              elevation: 5,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.vertical(
                                                      bottom: Radius.circular(
                                                          styleController
                                                              .cardBorderRadius))),
                                              child: Center(
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: styleController
                                                        .cardMargin,
                                                    vertical: styleController
                                                            .cardMargin /
                                                        4,
                                                  ),
                                                  child: SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: Wrap(
                                                      runSpacing: 0,
                                                      spacing: styleController
                                                              .cardMargin /
                                                          4,
                                                      children: [
                                                        for (var tag in data
                                                            .value.tags
                                                            .split(' '))
                                                          TextButton(
                                                            style: styleController
                                                                .buttonStyle(
                                                                    colors[
                                                                        50]!),
                                                            onPressed: () {},
                                                            child: Text(
                                                              tag,
                                                              style: styleController
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
                        ),
                      ]),
                ),

                Visibility(
                    visible: loading.value,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: uploadPercent.value != 0
                            ? uploadPercent.value  / 100
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
    Blog? tmp = await controller.find({'id': data.value.id});
    if (tmp != null) {
      this.data.value = tmp;
    }
    loading.value = false;
  }

  Widget image(Map<String, dynamic> data) {
    return Container(
      padding: EdgeInsets.all(
        styleController.cardMargin,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(
            Radius.circular(styleController.cardBorderRadius / 2)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: Get.width),
          child: CachedNetworkImage(
              fit: BoxFit.contain,
              imageUrl: Variables.DOMAIN + data['file']['url']),
        ),
      ),
    );
  }

  Widget paragraph(Map<String, dynamic> data) {
    return Container(
      padding: EdgeInsets.all(styleController.cardMargin),
      alignment: Alignment.centerRight,
      child: Text(
        data['text'] != null ? data['text'].replaceAll('&nbsp;', ' ') : '',
        style: styleController.textMediumStyle,
      ),
    );
  }

  Widget header(Map<String, dynamic> data) {
    return Container(
      padding: EdgeInsets.all(styleController.cardMargin),
      child: Text(
        data['text'] != null ? data['text'].replaceAll('&nbsp;', ' ') : '',
        style: styleController.textMediumStyle
            .copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget list(Map<String, dynamic> data) {
    return Padding(
      padding: EdgeInsets.all(styleController.cardMargin),
      child: Column(
        children: [
          for (var item in data['items'] ?? [])
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.arrow_forward_ios_outlined),
                SizedBox(
                  width: styleController.cardMargin,
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
      padding: EdgeInsets.all(styleController.cardMargin),
      child: Column(
        children: [
          if (data['caption'] != null)
            Container(
                child: Text(
              data['caption'].replaceAll('&nbsp;', ' '),
              style: TextStyle(color: colors[500]),
            )),
          Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: styleController.cardMargin),
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
        borderRadius:
            BorderRadius.circular(styleController.cardBorderRadius / 4),
        border: Border.all(color: colors[100]!));
    List<dynamic> rows = data['content'];
    var heading = null;
    if (data['withHeadings'] != null) heading = rows.removeAt(0);
    return Container(
      margin: EdgeInsets.all(styleController.cardMargin / 2),
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
                            padding:
                                EdgeInsets.all(styleController.cardMargin / 4),
                            decoration: cellStyle.copyWith(
                              color: colors[50],
                            ),
                            child: Center(
                                child: Text(
                              item.replaceAll('&nbsp;', ' '),
                              style: styleController.textMediumStyle
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
                            padding:
                                EdgeInsets.all(styleController.cardMargin / 4),
                            decoration: cellStyle,
                            child: Center(
                                child: Text(
                              item.replaceAll('&nbsp;', ' '),
                              style: styleController.textMediumStyle
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
