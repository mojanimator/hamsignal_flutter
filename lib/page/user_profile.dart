import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:hamsignal/controller/SettingController.dart';
import 'package:hamsignal/controller/UserController.dart';
import 'package:hamsignal/helper/helpers.dart';
import 'package:hamsignal/helper/styles.dart';
import 'package:hamsignal/model/User.dart';
import 'package:hamsignal/page/shop.dart';
import 'package:hamsignal/widget/blinkanimation.dart';
import 'package:hamsignal/widget/filter_widgets.dart';
import 'package:hamsignal/widget/mini_card.dart';
import 'package:hamsignal/widget/my_text_field.dart';
import 'package:hamsignal/widget/shakeanimation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:path/path.dart' as p;
import '../controller/AnimationController.dart';
import '../controller/UserFilterController.dart';
import '../widget/MyProfileImage.dart';
import 'transactions.dart';

class UserProfilePage extends StatelessWidget {
  late final UserController userController;
  late final SettingController settingController;

  late final Style style;

  late Rx<User> user;
  Rx<List<dynamic>> counties = Rx<List<dynamic>>([]);
  late MaterialColor colors;

  late Map<String, dynamic> userInfo;
  late Map<String, dynamic> userRef;
  late TextStyle title1Style;
  late TextStyle title2Style;
  late Helper helper;
  RxBool loading = false.obs;
  Rx<Map<String, String>> cacheHeaders = Rx<Map<String, String>>({});

  late Rx<ScrollPhysics> parentScrollPhysics =
      Rx<ScrollPhysics>(BouncingScrollPhysics());
  late Rx<ScrollPhysics> childScrollPhysics =
      Rx<ScrollPhysics>(NeverScrollableScrollPhysics());
  RxString statusText = '_'.obs;
  RxInt expireDays = 0.obs;
  RxString statusTextLawyer = '_'.obs;
  RxInt expireDaysLawyer = 0.obs;
  final MyAnimationController animationController =
      Get.find<MyAnimationController>();
  late Widget profileWidget;
  late Widget documentWidget;
  late UserFilterController filterController;

  UserProfilePage({Key? key}) {
    userController = Get.find<UserController>();
    settingController = Get.find<SettingController>();
    helper = Get.find<Helper>();
    style = Get.find<Style>();
    colors = style.primaryMaterial;
    user = Rx<User>(userController.user ?? User.nullUser());
    userInfo = userController.userInfo;
    userRef = userController.userRef ?? {};
    title1Style = style.textBigStyle;
    title2Style = style.textMediumStyle;
    filterController = userController.filterController;

    // WidgetsBinding.instance.addPostFrameCallback((_) => Future.delayed(
    //     Duration(seconds: 1),
    //     () => Get.to(TransactionsPage( ),
    //         transition: Transition.topLevel,
    //         duration: Duration(milliseconds: 100))));

    //         // showEditDialog({'username': user.username}));

    profileWidget = MyProfileImage(
      controller: filterController,
      cropRatio: settingController.cropRatio['profile'],
      tag: "profile${user.value.id}",
      src: filterController.filters['avatar'],
      failAsset: 'assets/images/noimage.png',
      colors: colors,
      onEdit: (path) async {
        File f = File(path);
        filterController.filters['avatar'] = f;
        Uint8List value = await File(path).readAsBytes();
        edit({
          'avatar': MultipartFile(value,
              filename: path.split('/')[path.split('/').length - 1])
        }, type: 'avatar');
      },
    );
    documentWidget = MyProfileImage(
      controller: filterController,
      cropRatio: settingController.cropRatio['document'],
      tag: "document${user.value.id}",
      src: filterController.filters['document'],
      failAsset: 'assets/images/noimage.png',
      colors: colors,
      onEdit: (path) async {
        File f = File(path);
        filterController.filters['document'] = f;
        Uint8List value = await File(path).readAsBytes();
        edit({
          'document': MultipartFile(value,
              filename: path.split('/')[path.split('/').length - 1])
        }, type: 'lawyer');
      },
    );

    parentScrollPhysics = Rx<ScrollPhysics>(userController.parentScrollPhysics);
    childScrollPhysics = Rx<ScrollPhysics>(userController.childScrollPhysics);

    filterController.textNameCtrl.text = user.value.fullName;
    filterController.textUsernameCtrl.text = user.value.username;
    filterController.textEmailCtrl.text = user.value.email;
    filterController.textPaswOldCtrl.text = '';
    filterController.textPaswCtrl.text = '';
    filterController.textPaswConfCtrl.text = '';
    filterController.textTelCtrl.text = user.value.phone;

    userController.parentScrollController =
        userController.parentScrollController;
    userController.childScrollController = userController.childScrollController;
    userController.childScrollPhysics = userController.childScrollPhysics;
    userController.parentScrollPhysics = userController.parentScrollPhysics;

    userController.parentScrollController.addListener(() {
      if (userController.parentScrollController.offset >
              userController.parentScrollController.position.maxScrollExtent &&
          userController.childScrollController.position.maxScrollExtent > 0 &&
          childScrollPhysics.value is NeverScrollableScrollPhysics &&
          parentScrollPhysics.value is! NeverScrollableScrollPhysics) {
        userController.parentScrollController.animateTo(
            userController.parentScrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 500),
            curve: Curves.ease);
        childScrollPhysics.value = BouncingScrollPhysics();
        parentScrollPhysics.value = NeverScrollableScrollPhysics();
        userController.childScrollPhysics = childScrollPhysics.value;
        userController.parentScrollPhysics = parentScrollPhysics.value;
      }
    });
    userController.childScrollController.addListener(() {
      if (userController.childScrollController.offset < 0 &&
          parentScrollPhysics.value is NeverScrollableScrollPhysics &&
          childScrollPhysics.value is! NeverScrollableScrollPhysics) {
        parentScrollPhysics.value = BouncingScrollPhysics();
        childScrollPhysics.value = NeverScrollableScrollPhysics();
        userController.childScrollPhysics = childScrollPhysics.value;
        userController.parentScrollPhysics = parentScrollPhysics.value;
      }
    });
    DateTime now = DateTime.now();
    DateTime expireDaysDateTime =
        user.value?.expiresAt != null && user.value?.expiresAt != ''
            ? DateTime.tryParse(user.value!.expiresAt) ?? now
            : now;

    expireDays.value = expireDaysDateTime.difference(now).inDays;
    statusText.value = !user.value.isActive
        ? 'blocked'.tr
        : "${expireDays.value > 0 ? expireDays.value : 0} ${'day'.tr}";
    // : expireDays.value <  0
    //     ? 'expired'.tr
    //     : 'inactive'.tr;

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => RefreshIndicator(
        onRefresh: () async {
          refresh();
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: style.splashBackground,
          ),
          child: Scaffold(
            body: ShakeWidget(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  //profile section

                  IgnorePointer(
                    ignoring: true,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            height: Get.height / 3 + style.cardBorderRadius * 2,
                            decoration:
                                BoxDecoration(gradient: style.splashBackground),
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/icon-dark.png'),
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
                  ),

                  CustomScrollView(
                    physics: parentScrollPhysics.value,
                    controller: userController.parentScrollController,
                    shrinkWrap: false,
                    slivers: [
                      SliverToBoxAdapter(
                        child: Container(
                          height: style.topOffset,
                        ),
                      ),
                      SliverFillRemaining(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(
                                      style.cardBorderRadius * 2),
                                  topLeft: Radius.circular(
                                      style.cardBorderRadius * 2))),
                          margin: EdgeInsets.zero,
                          child: Transform.translate(
                            offset: Offset(0, -style.imageHeight / 2),
                            child: Column(
                              key: PageStorageKey<String>('profile'),
                              children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    //profile image
                                    Padding(
                                      padding: EdgeInsets.all(style.cardMargin),
                                      child: profileWidget,
                                    ),

                                    Expanded(
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: style.cardMargin),
                                          child: IntrinsicHeight(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                //status
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical:
                                                          style.cardMargin / 4),
                                                  child: TextButton(
                                                    style: style.buttonStyle(
                                                      padding: EdgeInsets.all(
                                                          style.cardMargin * 2),
                                                      radius: BorderRadius.all(
                                                        Radius.circular(
                                                            style.cardMargin),
                                                      ),
                                                      backgroundColor:
                                                          Colors.white,
                                                    ),
                                                    onPressed: () =>
                                                        Get.to(ShopPage(
                                                      filter: 'user',
                                                    )),
                                                    child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          IntrinsicHeight(
                                                              child: Row(
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .person,
                                                                      color:
                                                                      colors[600],
                                                                    ),
                                                                if (false)
                                                                Text(
                                                                  'sub'.tr,
                                                                  style: style
                                                                      .textMediumStyle,
                                                                ),
                                                                VerticalDivider(),
                                                                BlinkAnimation(
                                                                  child:
                                                                      Container(
                                                                    padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            style.cardMargin /
                                                                                2),
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.all(Radius.circular(style.cardMargin))),
                                                                    child: Text(
                                                                        statusText
                                                                            .value,
                                                                        style: style
                                                                            .textMediumStyle),
                                                                  ),
                                                                ),
                                                              ])),
                                                          if (false)
                                                            IntrinsicHeight(
                                                                child: Text(statusText
                                                                            .value ==
                                                                        'expired'
                                                                            .tr
                                                                    ? 'click_for_pay'
                                                                        .tr
                                                                    : '')),
                                                        ]),
                                                  ),
                                                ),
                                                //wallet
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical:
                                                          style.cardMargin / 4),
                                                  child: TextButton(
                                                    style: style.buttonStyle(
                                                      padding: EdgeInsets.all(
                                                          style.cardMargin * 2),
                                                      radius: BorderRadius.all(
                                                        Radius.circular(
                                                            style.cardMargin),
                                                      ),
                                                      backgroundColor:
                                                          Colors.white,
                                                    ),
                                                    onPressed: () => refresh(),
                                                    child: Row(
                                                      children: [
                                                        loading.value
                                                            ? CupertinoActivityIndicator(
                                                                color:
                                                                    colors[600])
                                                            : Icon(
                                                                Icons
                                                                    .account_balance_wallet,
                                                                color:
                                                                    colors[600],
                                                              ),
                                                        VerticalDivider(),
                                                        BlinkAnimation(
                                                          child: Text(
                                                            " ${user.value.wallet.asPrice()} ${'currency'.tr} ",
                                                            style: style
                                                                .textHeaderStyle
                                                                .copyWith(
                                                                    color: colors[
                                                                        600]),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),

                                                if (false)
                                                  Padding(
                                                    padding: EdgeInsets.symmetric(
                                                        vertical:
                                                            style.cardMargin /
                                                                4,
                                                        horizontal:
                                                            style.cardMargin *
                                                                2),
                                                    child: IntrinsicHeight(
                                                        child: Row(children: [
                                                      Text(
                                                        'score'.tr,
                                                        style: style
                                                            .textMediumStyle,
                                                      ),
                                                      BlinkAnimation(
                                                        child: Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal: style
                                                                      .cardMargin),
                                                          decoration: BoxDecoration(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          style
                                                                              .cardMargin))),
                                                          child: Text(
                                                              "${user.value.score}",
                                                              style: style
                                                                  .textMediumStyle),
                                                        ),
                                                      ),
                                                    ])),
                                                  ),
                                                // VerticalDivider(),

                                                //charge wallet
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                //fullname username
                                Wrap(
                                  runSpacing: style.cardMargin,
                                  spacing: style.cardMargin,
                                  runAlignment: WrapAlignment.spaceAround,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          color: style.primaryMaterial[50]!
                                              .withOpacity(.3),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                style.cardBorderRadius / 2),
                                          )),
                                      child: Padding(
                                        padding:
                                            EdgeInsets.all(style.cardMargin),
                                        child: IntrinsicWidth(
                                          child: IntrinsicHeight(
                                            child: Row(
                                              children: [
                                                Text(
                                                  'name'.tr,
                                                  style: style.textMediumStyle,
                                                ),
                                                VerticalDivider(),
                                                Text(
                                                  user.value.fullName,
                                                  style: style.textMediumStyle,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: style.primaryMaterial[50]!
                                              .withOpacity(.3),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                style.cardBorderRadius / 2),
                                          )),
                                      child: Padding(
                                        padding:
                                            EdgeInsets.all(style.cardMargin),
                                        child: IntrinsicWidth(
                                          child: IntrinsicHeight(
                                            child: Row(
                                              children: [
                                                Text(
                                                  'username'.tr,
                                                  style: style.textMediumStyle,
                                                ),
                                                VerticalDivider(),
                                                Text(
                                                  user.value.username,
                                                  style: style.textMediumStyle,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Expanded(
                                    child: ListView(
                                  children: [
                                    ListTile(
                                      title: Text(
                                        'user_info'.tr,
                                        style: style.textMediumStyle,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: style.cardMargin * 4),
                                      onTap: () => Get.dialog(
                                          Obx(
                                            () => Center(
                                              child: MiniCard(
                                                scrollable: true,
                                                loading: loading,
                                                shrink: true,
                                                titlePadding: EdgeInsets.all(
                                                    style.cardMargin),
                                                title: 'user_info'.tr,
                                                style: style,
                                                desc1: '',
                                                child: Container(
                                                  child: Padding(
                                                      padding: EdgeInsets.all(
                                                          style.cardMargin / 4),
                                                      child: Column(
                                                        children: [
                                                          MyTextField(
                                                            backgroundColor:
                                                                Colors.white,
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        style.cardMargin /
                                                                            4),
                                                            icon: Icons.person,
                                                            controller:
                                                                filterController
                                                                    .textNameCtrl,
                                                            hintText:
                                                                "${'name'.tr} ${'family'.tr}",
                                                            keyboardType:
                                                                TextInputType
                                                                    .name,
                                                          ),
                                                          MyTextField(
                                                            backgroundColor:
                                                                Colors.white,
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        style.cardMargin /
                                                                            4),
                                                            icon: Icons
                                                                .account_box_rounded,
                                                            controller:
                                                                filterController
                                                                    .textUsernameCtrl,
                                                            hintText:
                                                                "${'username'.tr}",
                                                            keyboardType:
                                                                TextInputType
                                                                    .name,
                                                          ),
                                                          IntrinsicHeight(
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      MyTextField(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .white,
                                                                    margin: EdgeInsets.symmetric(
                                                                        vertical:
                                                                            style.cardMargin /
                                                                                4),
                                                                    icon: Icons
                                                                        .alternate_email,
                                                                    controller:
                                                                        filterController
                                                                            .textEmailCtrl,
                                                                    hintText:
                                                                        "${'email'.tr}",
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .emailAddress,
                                                                  ),
                                                                ),
                                                                TextButton(
                                                                  onPressed: () => !user
                                                                              .value
                                                                              .emailVerified ||
                                                                          user.value.email !=
                                                                              filterController
                                                                                  .textEmailCtrl.text
                                                                      ? edit({},
                                                                          type:
                                                                              'email')
                                                                      : null,
                                                                  style: style.buttonStyle(
                                                                      backgroundColor: user
                                                                              .value
                                                                              .emailVerified
                                                                          ? Colors
                                                                              .green
                                                                          : Colors
                                                                              .red),
                                                                  child: Text(
                                                                      user.value.emailVerified
                                                                          ? 'verified'
                                                                              .tr
                                                                          : 'unverified'
                                                                              .tr,
                                                                      style: style
                                                                          .textTinyLightStyle),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: style
                                                                .cardMargin,
                                                          ),
                                                          TextButton(
                                                              style: style
                                                                  .buttonStyle(
                                                                backgroundColor:
                                                                    style.primaryMaterial[
                                                                        500],
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        vertical:
                                                                            style.cardMargin *
                                                                                2),
                                                                radius:
                                                                    BorderRadius
                                                                        .vertical(
                                                                  bottom: Radius
                                                                      .circular(
                                                                          style.cardBorderRadius /
                                                                              2),
                                                                ),
                                                              ),
                                                              onPressed:
                                                                  () async {
                                                                edit({},
                                                                    type:
                                                                        'user');
                                                              },
                                                              child: Center(
                                                                child: Text(
                                                                  "${'edit'.tr}",
                                                                  style: style
                                                                      .textMediumLightStyle
                                                                      .copyWith(
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                ),
                                                              )),
                                                        ],
                                                      )),
                                                ),
                                              ),
                                            ),
                                          ),
                                          barrierDismissible: true),
                                    ),

                                    Divider(
                                        color: style.primaryColor,
                                        endIndent: style.cardMargin * 3,
                                        indent: style.cardMargin * 3),

                                    ListTile(
                                      title: Text(
                                        'wallet_charge'.tr,
                                        style: style.textMediumStyle,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: style.cardMargin * 4),
                                      onTap: () => Get.dialog(
                                          ShopPage(
                                            filter: 'charge',
                                          ),
                                          barrierDismissible: true),
                                    ),
                                    Divider(
                                        color: style.primaryColor,
                                        endIndent: style.cardMargin * 3,
                                        indent: style.cardMargin * 3),

                                    ListTile(
                                      title: Text(
                                        'buy_plan'.tr,
                                        style: style.textMediumStyle,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: style.cardMargin * 4),
                                      onTap: () => Get.dialog(
                                          ShopPage(
                                            filter: 'all',
                                          ),
                                          barrierDismissible: true),
                                    ),
                                    Divider(
                                        color: style.primaryColor,
                                        endIndent: style.cardMargin * 3,
                                        indent: style.cardMargin * 3),
                                    ListTile(
                                      title: Text(
                                        'transactions_history'.tr,
                                        style: style.textMediumStyle,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: style.cardMargin * 4),
                                      onTap: () => Get.dialog(
                                          TransactionsPage(),
                                          barrierDismissible: true),
                                    ),
                                    Divider(
                                        color: style.primaryColor,
                                        endIndent: style.cardMargin * 3,
                                        indent: style.cardMargin * 3),
                                    ListTile(
                                      title: Text(
                                        'telegram_connect'.tr,
                                        style: style.textMediumStyle,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: style.cardMargin * 4),
                                      onTap: () => Get.dialog(
                                          Center(
                                            child: MiniCard(
                                              scrollable: true,
                                              loading: loading,
                                              shrink: true,
                                              titlePadding: EdgeInsets.all(
                                                  style.cardMargin),
                                              title: 'telegram_connect'.tr,
                                              style: style,
                                              desc1: '',
                                              child: Container(
                                                child: Padding(
                                                    padding: EdgeInsets.all(
                                                        style.cardMargin / 2),
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding: EdgeInsets
                                                              .all(style
                                                                  .cardMargin),
                                                          child: Text(
                                                            'open_telegram_and_start'
                                                                .tr,
                                                            style: style
                                                                .textMediumStyle,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height:
                                                              style.cardMargin,
                                                        ),
                                                        TextButton(
                                                            style: style
                                                                .buttonStyle(
                                                              backgroundColor:
                                                                  style.primaryMaterial[
                                                                      500],
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          style.cardMargin *
                                                                              2),
                                                              radius:
                                                                  BorderRadius
                                                                      .vertical(
                                                                bottom: Radius
                                                                    .circular(
                                                                        style.cardBorderRadius /
                                                                            2),
                                                              ),
                                                            ),
                                                            onPressed: () =>
                                                                userController
                                                                    .getTelegramConnectLink(),
                                                            child: Center(
                                                              child: Text(
                                                                "${'telegram_connect'.tr}",
                                                                style: style
                                                                    .textMediumLightStyle
                                                                    .copyWith(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                              ),
                                                            )),
                                                      ],
                                                    )),
                                              ),
                                            ),
                                          ),
                                          barrierDismissible: true),
                                    ),
                                    Divider(
                                        color: style.primaryColor,
                                        endIndent: style.cardMargin * 3,
                                        indent: style.cardMargin * 3),

                                    //change password
                                    ListTile(
                                      title: Text(
                                        'password_change'.tr,
                                        style: style.textMediumStyle,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: style.cardMargin * 4),
                                      onTap: () => Get.dialog(
                                          Center(
                                            child: MiniCard(
                                              scrollable: true,
                                              loading: loading,
                                              shrink: true,
                                              titlePadding: EdgeInsets.all(
                                                  style.cardMargin),
                                              title: 'password_change'.tr,
                                              style: style,
                                              desc1: '',
                                              child: Container(
                                                child: Padding(
                                                    padding: EdgeInsets.all(
                                                        style.cardMargin / 2),
                                                    child: Column(
                                                      children: [
                                                        if (false)
                                                          MyTextField(
                                                            backgroundColor:
                                                                Colors.white,
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        style.cardMargin /
                                                                            4),
                                                            icon:
                                                                Icons.password,
                                                            controller:
                                                                filterController
                                                                    .textPaswOldCtrl,
                                                            hintText:
                                                                'password_old'
                                                                    .tr,
                                                            keyboardType:
                                                                TextInputType
                                                                    .text,
                                                            obscure: true,
                                                          ),
                                                        MyTextField(
                                                          backgroundColor:
                                                              Colors.white,
                                                          margin: EdgeInsets
                                                              .symmetric(
                                                                  vertical:
                                                                      style.cardMargin /
                                                                          4),
                                                          icon: Icons
                                                              .password_outlined,
                                                          controller:
                                                              filterController
                                                                  .textPaswCtrl,
                                                          hintText:
                                                              "${'password_new'.tr}",
                                                          keyboardType:
                                                              TextInputType
                                                                  .text,
                                                          obscure: true,
                                                        ),
                                                        MyTextField(
                                                          backgroundColor:
                                                              Colors.white,
                                                          margin: EdgeInsets
                                                              .symmetric(
                                                                  vertical:
                                                                      style.cardMargin /
                                                                          4),
                                                          icon: Icons
                                                              .password_outlined,
                                                          controller:
                                                              filterController
                                                                  .textPaswConfCtrl,
                                                          hintText:
                                                              "${'password_rep'.tr}",
                                                          keyboardType:
                                                              TextInputType
                                                                  .text,
                                                          obscure: true,
                                                        ),
                                                        SizedBox(
                                                          height:
                                                              style.cardMargin,
                                                        ),
                                                        TextButton(
                                                            style: style
                                                                .buttonStyle(
                                                              backgroundColor:
                                                                  style.primaryMaterial[
                                                                      500],
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          style.cardMargin *
                                                                              2),
                                                              radius:
                                                                  BorderRadius
                                                                      .vertical(
                                                                bottom: Radius
                                                                    .circular(
                                                                        style.cardBorderRadius /
                                                                            2),
                                                              ),
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              edit({},
                                                                  type:
                                                                      'password');
                                                            },
                                                            child: Center(
                                                              child: Text(
                                                                "${'edit'.tr}",
                                                                style: style
                                                                    .textMediumLightStyle
                                                                    .copyWith(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                              ),
                                                            )),
                                                      ],
                                                    )),
                                              ),
                                            ),
                                          ),
                                          barrierDismissible: true),
                                    ),
                                    //exit
                                    Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: style.cardMargin * 3,
                                        vertical: style.cardMargin * 2,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: TextButton.icon(
                                                style: style.buttonStyle(
                                                    backgroundColor: Colors.red
                                                        .withOpacity(.8),
                                                    splashColor: Colors.white
                                                        .withOpacity(.5)),
                                                onPressed: () => Get.dialog(
                                                      Center(
                                                        child: Material(
                                                          color: Colors
                                                              .transparent,
                                                          child: Card(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          style
                                                                              .cardBorderRadius),
                                                            ),
                                                            shadowColor: style
                                                                .primaryColor
                                                                .withOpacity(
                                                                    .3),
                                                            color: Colors.white,
                                                            // colors[100]?.withOpacity(.8),
                                                            margin: EdgeInsets
                                                                .all(style
                                                                    .cardMargin),
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .all(style
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
                                                                        style.cardMargin /
                                                                            2),
                                                                    child: Text(
                                                                      'sure_to_exit?'
                                                                          .tr,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .right,
                                                                      style: style
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
                                                                                    return states.contains(MaterialState.pressed) ? style.secondaryColor : null;
                                                                                  },
                                                                                ),
                                                                                backgroundColor: MaterialStateProperty.all(colors[50]),
                                                                                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                                                                  borderRadius: BorderRadius.horizontal(
                                                                                    right: Radius.circular(style.cardBorderRadius / 2),
                                                                                    left: Radius.circular(style.cardBorderRadius / 4),
                                                                                  ),
                                                                                ))),
                                                                            onPressed: () => Get.back(),
                                                                            child: Text(
                                                                              'cancel'.tr,
                                                                              style: style.textMediumStyle,
                                                                            )),
                                                                      ),
                                                                      VerticalDivider(
                                                                        indent:
                                                                            style.cardMargin /
                                                                                2,
                                                                        endIndent:
                                                                            style.cardMargin /
                                                                                2,
                                                                      ),
                                                                      Expanded(
                                                                        child: TextButton(
                                                                            style: style.buttonStyle(backgroundColor: Colors.red, splashColor: Colors.white.withOpacity(.5)),
                                                                            onPressed: () {
                                                                              Get.back();
                                                                              userController.logout();
                                                                            },
                                                                            child: Text(
                                                                              'verify'.tr,
                                                                              style: style.textMediumLightStyle,
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
                                                  style: style
                                                      .textMediumLightStyle,
                                                )),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
                                SizedBox(
                                  height: style.bottomNavigationBarHeight / 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),

                  Visibility(
                      visible: loading.value,
                      child: Container(
                        color: style.primaryColor.withOpacity(.7),
                        child: Center(
                          child: ShakeWidget(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(style.cardMargin))),
                              child: Padding(
                                padding: EdgeInsets.all(style.cardMargin),
                                child: CircularProgressIndicator(
                                    color: style.primaryColor),
                              ),
                            ),
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  refresh() async {
    loading.value = true;
    userController.user = null;
    await userController.getUser(refresh: true);
    loading.value = false;
  }

  edit(Map<String, dynamic> params, {String? type = 'user'}) async {
    loading.value = true;
    switch (type) {
      case 'password':
        params = {
          'password_old': filterController.textPaswOldCtrl.text,
          'password_new': filterController.textPaswCtrl.text,
          'password_rep': filterController.textPaswConfCtrl.text,
        };
        break;

      case 'user':
        params = {
          'fullname': filterController.textNameCtrl.text,
          'username': filterController.textUsernameCtrl.text,
          'email': filterController.textEmailCtrl.text,
          'avatar': params['avatar'] ?? ''
        };

        break;
      case 'email':
        params = {
          'email': filterController.textEmailCtrl.text,
        };

        break;
      case 'avatar':
        params = {'avatar': params['avatar']};
        // if (params['avatar'] == '' || params['avatar'] == null)
        //   params.remove('avatar');
        break;
    }
    Map res = await userController.edit(params: params, type: type);
    if (res['status'] == 'success') {
      if (params['password_new'] != '') {
        filterController.textPaswOldCtrl.clear();
        filterController.textPaswCtrl.clear();
        filterController.textPaswConfCtrl.clear();
      }
      if (res['email_verified'] != null) {
        user.value.emailVerified = res['email_verified'];
        user.update((val) {
          // user.value = val!;
        });
      }
    }
    loading.value = false;
    // if (res) Future.delayed(Duration(seconds: 6),()=>Get.back());
  }

  isEditable() {
    return true;
  }
}
