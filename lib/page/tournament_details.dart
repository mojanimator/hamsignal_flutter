import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dabel_sport/controller/SettingController.dart';
import 'package:dabel_sport/controller/TournamentController.dart';
import 'package:dabel_sport/helper/styles.dart';
import 'package:dabel_sport/helper/variables.dart';
import 'package:dabel_sport/model/Tournament.dart';
import 'package:dabel_sport/widget/mini_card.dart';
import 'package:dabel_sport/widget/shakeanimation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TournamentDetails extends StatelessWidget {
  late Rx<Tournament> data;

  TournamentController controller = Get.find<TournamentController>();

  late MaterialColor colors;
  late TextStyle titleStyle;

  final SettingController settingController = Get.find<SettingController>();
  int index;
  final Style styleController = Get.find<Style>();

  RxDouble uploadPercent = RxDouble(0.0);
  RxBool loading = RxBool(false);

  TournamentDetails(
      {required data, MaterialColor? colors, int this.index = -1}) {
    this.colors = colors ?? styleController.cardTournamentColors;
    titleStyle =
        styleController.textMediumStyle.copyWith(color: this.colors[900]);
    this.data = Rx<Tournament>(data);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
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
                        imageUrl: "${controller.getProfileLink(data.value.id)}",
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
                                      onTap:
                                          () =>
                                              Navigator.of(context).push(
                                                  PageRouteBuilder(
                                                      opaque: false,
                                                      barrierDismissible: true,
                                                      pageBuilder:
                                                          (BuildContext context,
                                                              _, __) {
                                                        return Hero(
                                                          tag:
                                                              "preview${data.value.id}",
                                                          child: Stack(
                                                            fit:
                                                                StackFit.expand,
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
                                                                        "${controller.getProfileLink(data.value.id)}",
                                                                    useOldImageOnUrlChange:
                                                                        true,
                                                                  ),
                                                                ),
                                                              ),
                                                              Positioned(
                                                                left: 0,
                                                                right: 0,
                                                                bottom: 8,
                                                                child:
                                                                    Container(
                                                                  color: Colors
                                                                      .black
                                                                      .withOpacity(
                                                                          .7),
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              4),
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
                                                                              CircleBorder(side: BorderSide(color: colors[50]!, width: 1)),
                                                                            ),
                                                                            backgroundColor: MaterialStateProperty.resolveWith((states) => states.contains(MaterialState.pressed) ? styleController.secondaryColor : Colors.transparent)),
                                                                        child:
                                                                            Padding(
                                                                          padding:
                                                                              EdgeInsets.all(styleController.cardMargin / 2),
                                                                          child:
                                                                              Icon(
                                                                            Icons.clear,
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
                                                  "${controller.getProfileLink(data.value.id)}",
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
                                    Padding(
                                      padding: EdgeInsets.all(
                                          styleController.cardMargin),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal:
                                                styleController.cardMargin / 2,
                                            vertical:
                                                styleController.cardMargin / 4),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                styleController
                                                        .cardBorderRadius /
                                                    2),
                                            color: styleController
                                                .primaryMaterial[50]),
                                        child: Text(
                                          " ${data.value.name}",
                                          style: styleController.textHeaderStyle
                                              .copyWith(color: colors[600]),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // Container(
                                //   child: Padding(
                                //       padding: EdgeInsets.all(
                                //           styleController.cardMargin / 4),
                                //       child: Column(
                                //         children: [
                                //           MiniCard(
                                //             colors: colors,
                                //             title: 'sport'.tr,
                                //             desc1: settingController
                                //                 .sport(data.value.sport_id),
                                //             desc2: null,
                                //             styleController: styleController,
                                //           ),
                                //         ],
                                //       )),
                                // ),
                                Container(
                                  child: Padding(
                                      padding: EdgeInsets.all(
                                          styleController.cardMargin / 4),
                                      child: Column(
                                          children: data.value.tables
                                              .map<Widget>(
                                                (t) => MiniCard(
                                                  colors: colors,
                                                  title: t.title,
                                                  desc1: t.title,
                                                  desc2: null,
                                                  styleController:
                                                      styleController,
                                                  child: table(t.content),
                                                ),
                                              )
                                              .toList())),
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

  refresh() async {
    Tournament? res =
        await controller.find({'id': data.value.id, 'with_tables': '1'});

    if (res != null) {
      this.data.value = res;
    }
  }

  Widget table(String data) {
    if (data == null) return Center();
    Map<String, dynamic> table = json.decode(data)?['table'];

    BoxDecoration cellStyle = BoxDecoration(
        borderRadius:
            BorderRadius.circular(styleController.cardBorderRadius / 4),
        border: Border.all(color: colors[100]!));

    List<dynamic> headers = table['header'] ?? [];

    List<dynamic> rows = table['body'] ?? [];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          defaultColumnWidth: IntrinsicColumnWidth( ),
          children: [

        if (headers.length > 0)
          TableRow(
              children: headers
                  .map((e) => Container(
                        padding:
                            EdgeInsets.all(styleController.cardMargin / 4),
                        decoration: cellStyle.copyWith(
                          color: colors[500],
                        ),
                        child: Center(
                          child: Text(
                            e != null ? e?.replaceAll('&nbsp;', ' ') : '',
                            style: styleController.textMediumStyle
                                .copyWith(color: colors[50]),
                          ),
                        ),
                      ))
                  .toList()),
        for (var j = 0; j < rows.length; j++)
          TableRow(
              decoration: cellStyle,
              children: rows[j]
                  .map<Widget>((item) => Center(
                        child: item['type'] == 'img' && item['value'] != null
                            ? Padding(
                                padding: EdgeInsets.all(
                                    styleController.cardMargin / 4),
                                child: Image.memory(
                                  base64Decode(
                                      item['value'].split('base64,').last),
                                  fit: BoxFit.contain,
                                  // height: 32,
                                  width: 32,
                                ),
                              )
                            : Container(
                          padding: EdgeInsets.symmetric(
                            horizontal:  styleController.cardMargin / 2),
                              // decoration: BoxDecoration(border: Border.symmetric(vertical:BorderSide(color: colors[500]!)  )),
                              child: Center(

                                child: Text(
                                  (item['value'] ?? " ")
                                      .replaceAll('&nbsp;', ' '),
                                  style: styleController.textMediumStyle
                                      .copyWith(color: colors[800]),
                                ),
                              ),
                            ),
                      ))
                  .toList())
      ]),
    );
  }
}
