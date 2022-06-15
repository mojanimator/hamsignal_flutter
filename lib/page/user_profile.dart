import 'dart:ui';

import 'package:dabel_sport/controller/SettingController.dart';
import 'package:dabel_sport/controller/UserController.dart';
import 'package:dabel_sport/helper/helpers.dart';
import 'package:dabel_sport/helper/styles.dart';
import 'package:dabel_sport/model/user.dart';
import 'package:dabel_sport/page/blogs.dart';
import 'package:dabel_sport/page/clubs.dart';
import 'package:dabel_sport/page/coaches.dart';
import 'package:dabel_sport/page/players.dart';
import 'package:dabel_sport/page/products.dart';
import 'package:dabel_sport/page/shops.dart';
import 'package:dabel_sport/widget/mini_card.dart';
import 'package:dabel_sport/widget/shakeanimation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class UserProfilePage extends StatelessWidget {
  late final UserController userController;
  late final SettingController settingController;

  late final Style styleController;

  late User user;
  late MaterialColor colors;

  late Map<String, dynamic> userInfo;
  late Map<String, dynamic> userRef;
  late TextStyle title1Style;
  late TextStyle title2Style;
  late Helper helper;
  RxBool loading = false.obs;

  UserProfilePage({Key? key}) {
    userController = Get.find<UserController>();
    settingController = Get.find<SettingController>();
    helper = Get.find<Helper>();
    styleController = Get.find<Style>();
    colors = styleController.primaryMaterial;
    user = userController.user ?? User.nullUser();
    userInfo = userController.userInfo;
    userRef = userController.userRef;
    title1Style = styleController.textBigStyle;
    title2Style = styleController.textMediumStyle;

    // WidgetsBinding.instance.addPostFrameCallback((_) => Future.delayed(
    //     Duration(seconds: 1),
    //     () => Get.to(
    //         ProductsPage(initFilter: {
    //           'user': user.id,
    //           'panel': '1',
    //         }),
    //         transition: Transition.topLevel,
    //         duration: Duration(milliseconds: 400))));


    //         // showEditDialog({'username': user.username}));

  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        userController.user = null;
        userController.getUser();
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: styleController.splashBackground,
        ),
        child: Scaffold(
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
                            gradient: styleController.splashBackground),
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image:
                                    AssetImage('assets/images/icon-light.png'),
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.low),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Center(),
                          ),
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

                ListView(shrinkWrap: true, children: [
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
                    margin: EdgeInsets.zero,
                    child: Transform.translate(
                      offset: Offset(0, -styleController.imageHeight / 2),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ShakeWidget(
                                child: Card(
                                  child: Icon(
                                    Icons.person_sharp,
                                    color: styleController.primaryColor,
                                    size: styleController.imageHeight - 16,
                                  ),
                                  elevation: 10,
                                  shadowColor: colors[900]!.withOpacity(.9),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(
                                            styleController.cardBorderRadius),
                                        bottom: Radius.circular(
                                            styleController.cardBorderRadius /
                                                4)),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    EdgeInsets.all(styleController.cardMargin),
                                child: IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      Container(
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
                                          " ${userRef['bestan']?['sum']} ${'currency'.tr}   ",
                                          style: styleController.textHeaderStyle
                                              .copyWith(color: colors[600]),
                                        ),
                                      ),
                                      VerticalDivider(),
                                      Container(
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
                                          " ${user.score}  ${'score'.tr}  ",
                                          style: styleController.textHeaderStyle
                                              .copyWith(color: colors[600]),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                          Container(
                            padding:
                                EdgeInsets.all(styleController.cardMargin / 4),
                            child: Column(
                              children: [
                                // user player,coach,club.shop,blog
                                MiniCard(
                                  title: 'registered_info'.tr,
                                  styleController: styleController,
                                  desc1: '',
                                  child: Container(
                                    child: Padding(
                                        padding: EdgeInsets.all(
                                            styleController.cardMargin / 4),
                                        child: Column(
                                          children: [
                                            IntrinsicHeight(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  if (userInfo.keys
                                                      .contains('blog'))
                                                    ShakeWidget(
                                                      child: TextButton(
                                                        child: Column(
                                                          children: [
                                                            Padding(
                                                              padding: EdgeInsets.all(
                                                                  styleController
                                                                          .cardMargin /
                                                                      4),
                                                              child: Text(
                                                                "${userInfo['blog']}",
                                                                style:
                                                                    title1Style,
                                                              ),
                                                            ),
                                                            Text(
                                                              'blog'.tr,
                                                              style:
                                                                  title2Style,
                                                            ),
                                                          ],
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                        ),
                                                        onPressed: () {
                                                          Get.to(
                                                              BlogsPage(
                                                                  initFilter: {
                                                                    'user':
                                                                        user.id,
                                                                    'panel':
                                                                        '1',
                                                                  }),
                                                              transition:
                                                                  Transition
                                                                      .topLevel,
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      400));
                                                        },
                                                      ),
                                                    ),
                                                  if (userInfo.keys
                                                      .contains('blog'))
                                                    Padding(
                                                        padding: EdgeInsets.symmetric(
                                                            vertical:
                                                                styleController
                                                                        .cardMargin /
                                                                    2),
                                                        child:
                                                            VerticalDivider()),
                                                  Container(
                                                    child: ShakeWidget(
                                                      child: TextButton(
                                                        child: Column(
                                                          children: [
                                                            Padding(
                                                              padding: EdgeInsets.all(
                                                                  styleController
                                                                          .cardMargin /
                                                                      4),
                                                              child: Text(
                                                                "${userInfo['player']}",
                                                                style:
                                                                    title1Style,
                                                              ),
                                                            ),
                                                            Text(
                                                              'player'.tr,
                                                              style:
                                                                  title2Style,
                                                            ),
                                                          ],
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                        ),
                                                        onPressed: () {
                                                          Get.to(
                                                              PlayersPage(
                                                                  initFilter: {
                                                                    'user':
                                                                        user.id,
                                                                    'panel':
                                                                        '1',
                                                                  }),
                                                              transition:
                                                                  Transition
                                                                      .topLevel,
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      400));
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding: EdgeInsets.symmetric(
                                                          vertical: styleController
                                                                  .cardMargin /
                                                              2),
                                                      child: VerticalDivider()),
                                                  ShakeWidget(
                                                    child: TextButton(
                                                      child: Column(
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets.all(
                                                                styleController
                                                                        .cardMargin /
                                                                    4),
                                                            child: Text(
                                                              "${userInfo['coach']}",
                                                              style:
                                                                  title1Style,
                                                            ),
                                                          ),
                                                          Text(
                                                            'coach'.tr,
                                                            style: title2Style,
                                                          ),
                                                        ],
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                      ),
                                                      onPressed: () {
                                                        Get.to(
                                                            CoachesPage(
                                                                initFilter: {
                                                                  'user':
                                                                      user.id,
                                                                  'panel': '1',
                                                                }),
                                                            transition:
                                                                Transition
                                                                    .topLevel,
                                                            duration: Duration(
                                                                milliseconds:
                                                                    400));
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IntrinsicHeight(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  ShakeWidget(
                                                    child: TextButton(
                                                      child: Column(
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets.all(
                                                                styleController
                                                                        .cardMargin /
                                                                    4),
                                                            child: Text(
                                                              "${userInfo['club']}",
                                                              style:
                                                                  title1Style,
                                                            ),
                                                          ),
                                                          Text(
                                                            "   ${'club'.tr}   ",
                                                            style: title2Style,
                                                          ),
                                                        ],
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                      ),
                                                      onPressed: () {
                                                        Get.to(
                                                            ClubsPage(
                                                                initFilter: {
                                                                  'user':
                                                                      user.id,
                                                                  'panel': '1',
                                                                }),
                                                            transition:
                                                                Transition
                                                                    .topLevel,
                                                            duration: Duration(
                                                                milliseconds:
                                                                    400));
                                                      },
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding: EdgeInsets.symmetric(
                                                          vertical: styleController
                                                                  .cardMargin /
                                                              2),
                                                      child: VerticalDivider()),
                                                  ShakeWidget(
                                                    child: TextButton(
                                                      child: Column(
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets.all(
                                                                styleController
                                                                        .cardMargin /
                                                                    4),
                                                            child: Text(
                                                              "${userInfo['shop']}",
                                                              style:
                                                                  title1Style,
                                                            ),
                                                          ),
                                                          Text(
                                                            'shop'.tr,
                                                            style: title2Style,
                                                          ),
                                                        ],
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                      ),
                                                      onPressed: () {
                                                        Get.to(
                                                            ShopsPage(
                                                                initFilter: {
                                                                  'user':
                                                                      user.id,
                                                                  'panel': '1',
                                                                }),
                                                            transition:
                                                                Transition
                                                                    .topLevel,
                                                            duration: Duration(
                                                                milliseconds:
                                                                    400));
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        )),
                                  ),
                                ),
                                MiniCard(
                                  styleController: styleController,
                                  desc1: '',
                                  title: "${'username'.tr}",
                                  onTap: () => showEditDialog(
                                      {'username': user.username}),
                                  child: Center(
                                      child: Text(
                                    "${user.username}",
                                    style: styleController.textMediumStyle,
                                  )),
                                ),
                                MiniCard(
                                  styleController: styleController,
                                  desc1: '',
                                  title:
                                      "${'name'.tr} ${'and'.tr} ${'family'.tr}",
                                  onTap: () => showEditDialog({
                                    'name': user.name,
                                    'family': user.family,
                                  }),
                                  child: Center(
                                      child: Text(
                                    "${user.name} ${user.family}",
                                    style: styleController.textMediumStyle,
                                  )),
                                ),
                                MiniCard(
                                  styleController: styleController,
                                  desc1: '',
                                  title: "${'phone'.tr}",
                                  onTap: () => showEditDialog({
                                    'phone': user.phone,
                                    'phone_verify': ''
                                  }),
                                  child: Center(
                                      child: Text(
                                    "${user.phone}",
                                    style: styleController.textMediumStyle,
                                  )),
                                ),
                                MiniCard(
                                    styleController: styleController,
                                    desc1: '',
                                    title: "${'money_info'.tr}",
                                    onTap: () =>
                                        showEditDialog({'sheba': user.sheba}),
                                    child: Column(
                                      children: [
                                        Center(
                                            child: Column(
                                          children: [
                                            Text(
                                              "${'sheba'.tr}",
                                              style: styleController
                                                  .textMediumStyle,
                                            ),
                                            Text(
                                              "${user.sheba}",
                                              style: styleController
                                                  .textMediumStyle,
                                            ),
                                          ],
                                        )),
                                        Divider(),
                                        InkWell(
                                          onTap: () => showEditDialog(
                                              {'cart': user.cart}),
                                          child: Center(
                                              child: Column(
                                            children: [
                                              Text(
                                                "${'cart'.tr}",
                                                style: styleController
                                                    .textMediumStyle,
                                              ),
                                              Text(
                                                "${user.cart}",
                                                style: styleController
                                                    .textMediumStyle,
                                              ),
                                            ],
                                          )),
                                        ),
                                      ],
                                    )),
                                MiniCard(
                                    styleController: styleController,
                                    desc1: '',
                                    title: "${'referral'.tr}",
                                    child: Column(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            Clipboard.setData(ClipboardData(
                                                text: "${user.ref_code}"));
                                            helper.showToast(
                                                msg: 'copied_successfully'.tr,
                                                status: 'success');
                                          },
                                          child: Center(
                                              child: Column(
                                            children: [
                                              Text(
                                                "${'ref_code'.tr}",
                                                style: styleController
                                                    .textMediumStyle,
                                              ),
                                              Text(
                                                "${user.ref_code}",
                                                style: styleController
                                                    .textMediumStyle,
                                              ),
                                            ],
                                          )),
                                        ),
                                        Divider(),
                                        InkWell(
                                          onTap: null,
                                          child: IntrinsicHeight(
                                              child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.all(
                                                    styleController.cardMargin /
                                                        4),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      "${'level'.tr} 1",
                                                      style: styleController
                                                          .textMediumStyle,
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.all(
                                                          styleController
                                                                  .cardMargin /
                                                              2),
                                                      child: Text(
                                                        "${userRef['levels']['1']['unpaid']['count']}",
                                                        style: styleController
                                                            .textMediumStyle,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              VerticalDivider(),
                                              Padding(
                                                padding: EdgeInsets.all(
                                                    styleController.cardMargin /
                                                        4),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      "${'level'.tr} 2",
                                                      style: styleController
                                                          .textMediumStyle,
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.all(
                                                          styleController
                                                                  .cardMargin /
                                                              2),
                                                      child: Text(
                                                        "${userRef['levels']['2']['unpaid']['count']}",
                                                        style: styleController
                                                            .textMediumStyle,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              VerticalDivider(),
                                              Padding(
                                                padding: EdgeInsets.all(
                                                    styleController.cardMargin /
                                                        4),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      "${'level'.tr} 3",
                                                      style: styleController
                                                          .textMediumStyle,
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.all(
                                                          styleController
                                                                  .cardMargin /
                                                              2),
                                                      child: Text(
                                                        "${userRef['levels']['3']['unpaid']['count']}",
                                                        style: styleController
                                                            .textMediumStyle,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              VerticalDivider(),
                                              Padding(
                                                padding: EdgeInsets.all(
                                                    styleController.cardMargin /
                                                        4),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      "${'level'.tr} 4",
                                                      style: styleController
                                                          .textMediumStyle,
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.all(
                                                          styleController
                                                                  .cardMargin /
                                                              2),
                                                      child: Text(
                                                        "${userRef['levels']['4']['unpaid']['count']}",
                                                        style: styleController
                                                            .textMediumStyle,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              VerticalDivider(),
                                              Padding(
                                                padding: EdgeInsets.all(
                                                    styleController.cardMargin /
                                                        4),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      "${'level'.tr} 5",
                                                      style: styleController
                                                          .textMediumStyle,
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.all(
                                                          styleController
                                                                  .cardMargin /
                                                              2),
                                                      child: Text(
                                                        "${userRef['levels']['5']['unpaid']['count']}",
                                                        style: styleController
                                                            .textMediumStyle,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )),
                                        ),
                                      ],
                                    )),
                                Container(
                                  margin: EdgeInsets.all(
                                      styleController.cardMargin),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: TextButton.icon(
                                            style: ButtonStyle(
                                                overlayColor:
                                                    MaterialStateProperty
                                                        .resolveWith(
                                                  (states) {
                                                    return states.contains(
                                                            MaterialState
                                                                .pressed)
                                                        ? Colors.redAccent
                                                        : null;
                                                  },
                                                ),
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.red),
                                                shape:
                                                    MaterialStateProperty.all(
                                                        RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.horizontal(
                                                    right: Radius.circular(
                                                        styleController
                                                                .cardBorderRadius /
                                                            2),
                                                    left: Radius.circular(
                                                        styleController
                                                                .cardBorderRadius /
                                                            4),
                                                  ),
                                                ))),
                                            onPressed: () => Get.dialog(
                                                  Center(
                                                    child: Material(
                                                      color: Colors.transparent,
                                                      child: Card(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  styleController
                                                                      .cardBorderRadius),
                                                        ),
                                                        shadowColor:
                                                            styleController
                                                                .primaryColor
                                                                .withOpacity(
                                                                    .3),
                                                        color: Colors.white,
                                                        // colors[100]?.withOpacity(.8),
                                                        margin: EdgeInsets.all(
                                                            styleController
                                                                .cardMargin),
                                                        child: Padding(
                                                          padding: EdgeInsets.all(
                                                              styleController
                                                                  .cardMargin),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .stretch,
                                                            children: [
                                                              Container(
                                                                padding: EdgeInsets.all(
                                                                    styleController
                                                                            .cardMargin /
                                                                        2),
                                                                child: Text(
                                                                  'sure_to_exit?'
                                                                      .tr,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .right,
                                                                  style: styleController
                                                                      .textBigStyle,
                                                                ),
                                                              ),
                                                              Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Expanded(
                                                                    child: TextButton(
                                                                        style: ButtonStyle(
                                                                            overlayColor: MaterialStateProperty.resolveWith(
                                                                              (states) {
                                                                                return states.contains(MaterialState.pressed) ? styleController.secondaryColor : null;
                                                                              },
                                                                            ),
                                                                            backgroundColor: MaterialStateProperty.all(colors[50]),
                                                                            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.horizontal(
                                                                                right: Radius.circular(styleController.cardBorderRadius / 2),
                                                                                left: Radius.circular(styleController.cardBorderRadius / 4),
                                                                              ),
                                                                            ))),
                                                                        onPressed: () => Get.back(),
                                                                        child: Text(
                                                                          'cancel'
                                                                              .tr,
                                                                          style:
                                                                              styleController.textMediumStyle,
                                                                        )),
                                                                  ),
                                                                  VerticalDivider(
                                                                    indent:
                                                                        styleController.cardMargin /
                                                                            2,
                                                                    endIndent:
                                                                        styleController.cardMargin /
                                                                            2,
                                                                  ),
                                                                  Expanded(
                                                                    child: TextButton(
                                                                        style: ButtonStyle(
                                                                            overlayColor: MaterialStateProperty.resolveWith(
                                                                              (states) {
                                                                                return states.contains(MaterialState.pressed) ? Colors.redAccent : null;
                                                                              },
                                                                            ),
                                                                            backgroundColor: MaterialStateProperty.all(Colors.red),
                                                                            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.horizontal(
                                                                                left: Radius.circular(styleController.cardBorderRadius / 2),
                                                                                right: Radius.circular(styleController.cardBorderRadius / 4),
                                                                              ),
                                                                            ))),
                                                                        onPressed: () {
                                                                          Get.back();
                                                                          userController
                                                                              .logout();
                                                                        },
                                                                        child: Text(
                                                                          'verify'
                                                                              .tr,
                                                                          style:
                                                                              styleController.textMediumLightStyle,
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
                                                  barrierDismissible: true,
                                                ),
                                            icon: Icon(
                                              Icons.exit_to_app,
                                              color: Colors.white,
                                            ),
                                            label: Text(
                                              'exit'.tr,
                                              style: styleController
                                                  .textMediumLightStyle,
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showEditDialog(Map<String, dynamic> params) {
    dialog(List<Widget> children, Function callback) {
      Get.dialog(
        Center(
          child: Material(
            color: Colors.transparent,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(styleController.cardBorderRadius),
              ),
              shadowColor: styleController.primaryColor.withOpacity(.3),
              color: Colors.white,
              // colors[100]?.withOpacity(.8),
              margin: EdgeInsets.all(styleController.cardMargin),
              child: Padding(
                padding: EdgeInsets.all(styleController.cardMargin),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: EdgeInsets.all(styleController.cardMargin / 2),
                      child: Text(
                        'edit'.tr,
                        textAlign: TextAlign.right,
                        style: styleController.textBigStyle,
                      ),
                    ),
                    ...children,
                    Obx(() => Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: styleController.cardMargin / 2),
                          child: Visibility(
                              visible: loading.value,
                              child: LinearProgressIndicator(
                                  color: styleController.primaryColor)),
                        )),
                    if (params.keys.contains('phone_verify'))
                      Row(
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
                                        MaterialStateProperty.all(colors[600]),
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
                                onPressed: () => settingController
                                    .sendActivationCode(phone: params['phone']),
                                child: Text(
                                  'receive_code'.tr,
                                  style: styleController.textMediumLightStyle,
                                )),
                          ),
                        ],
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
                                          styleController.cardBorderRadius / 2),
                                      left: Radius.circular(
                                          styleController.cardBorderRadius / 4),
                                    ),
                                  ))),
                              onPressed: () => Get.back(),
                              child: Text(
                                'cancel'.tr,
                                style: styleController.textMediumStyle,
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
                                  backgroundColor: MaterialStateProperty.all(
                                      styleController.primaryColor),
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.horizontal(
                                      left: Radius.circular(
                                          styleController.cardBorderRadius / 2),
                                      right: Radius.circular(
                                          styleController.cardBorderRadius / 4),
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
        barrierDismissible: true,
      );
    }

    Map<String, dynamic> tcs = Map<String, dynamic>();
    tcs = params
        .map((key, value) => MapEntry(key, TextEditingController(text: value)));

    Function submitData = () async {
      loading.value = true;
      bool res = false;
      if (params.keys.where((e) => tcs[e].text != params[e]).isNotEmpty)
        res = await userController.edit(
            params: tcs.map((key, value) => MapEntry(key, value.text)));
      else
        res = true;
      loading.value = false;
      if (res == true) {
        Get.back();
        userController.user = null;
        userController.getUser();
      }
    };
    dialog(
        params.keys
            .map(
              (e) => Container(
                padding: EdgeInsets.symmetric(
                    horizontal: styleController.cardMargin),
                margin: EdgeInsets.symmetric(
                    vertical: styleController.cardMargin / 4),
                decoration: BoxDecoration(
                    color: colors[50],
                    borderRadius: BorderRadius.circular(
                        styleController.cardBorderRadius / 2)),
                child: TextField(
                  autofocus: true,
                  textAlign: e == 'name' || e == 'family'
                      ? TextAlign.right
                      : TextAlign.left,
                  style: TextStyle(
                    color: styleController.primaryColor,
                  ),
                  controller: tcs[e],
                  textInputAction: TextInputAction.done,
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
