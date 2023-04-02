import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dabel_adl/controller/SettingController.dart';
import 'package:dabel_adl/controller/UserController.dart';
import 'package:dabel_adl/helper/helpers.dart';
import 'package:dabel_adl/helper/styles.dart';
import 'package:dabel_adl/model/User.dart';
import 'package:dabel_adl/widget/blinkanimation.dart';
import 'package:dabel_adl/widget/filter_widgets.dart';
import 'package:dabel_adl/widget/mini_card.dart';
import 'package:dabel_adl/widget/my_text_field.dart';
import 'package:dabel_adl/widget/shakeanimation.dart';
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
import 'contents.dart';

class UserProfilePage extends StatelessWidget {
  late final UserController userController;
  late final SettingController settingController;

  late final Style styleController;

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
    styleController = Get.find<Style>();
    colors = styleController.primaryMaterial;
    user = Rx<User>(userController.user ?? User.nullUser());
    userInfo = userController.userInfo;
    userRef = userController.userRef ?? {};
    title1Style = styleController.textBigStyle;
    title2Style = styleController.textMediumStyle;
    filterController = userController.filterController;

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

    counties.value = settingController.counties
        .where((e) => e['province_id'] == filterController.filters['province'])
        .toList();

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
        }, type: 'user');
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
    filterController.textEmailCtrl.text = user.value.email;
    filterController.textPaswOldCtrl.text = '';
    filterController.textPaswCtrl.text = '';
    filterController.textPaswConfCtrl.text = '';
    filterController.textPaswConfCtrl.text = '';
    filterController.textTelCtrl.text = user.value.tel;
    filterController.textMelliCodeCtrl.text = user.value.lawyerMelicard;
    filterController.textLawyerCodeCtrl.text = user.value.lawyerNumber;
    filterController.textLawyerAddressCtrl.text = user.value.lawyerAddress;
    filterController.textLawyerBioCtrl.text = user.value.cv;

    userController.parentScrollController =
        userController.parentScrollController;
    userController.childScrollController = userController.childScrollController;
    userController.childScrollPhysics = userController.childScrollPhysics;
    userController.parentScrollPhysics = userController.parentScrollPhysics;

    userController.parentScrollController.addListener(() {
      // print("------");
      // print(parentScrollController.offset);
      // print(parentScrollController.position.maxScrollExtent);
      // print(parentScrollController.position.minScrollExtent);
      // print("*****");
      // print(childScrollController.offset);
      // print(childScrollController.position.maxScrollExtent);
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
        user.value?.expiredAt != null && user.value?.expiredAt != ''
            ? DateTime.tryParse(user.value!.expiredAt) ?? now
            : now;

    expireDays.value = expireDaysDateTime.difference(now).inDays;
    statusText.value = user.value.isBlock
        ? 'blocked'.tr
        : expireDays.value > 0
            ? "${expireDays.value} ${'day'.tr}"
            : expireDays.value <= 0
                ? 'expired'.tr
                : 'inactive'.tr;

    expireDaysDateTime =
        user.value?.lawyerExpiredAt != null && user.value?.lawyerExpiredAt != ''
            ? DateTime.tryParse(user.value!.lawyerExpiredAt) ?? now
            : now;

    expireDaysLawyer.value = expireDaysDateTime.difference(now).inDays;
    statusTextLawyer.value = user.value.isBlock
        ? 'blocked'.tr
        : expireDaysLawyer.value > 0 && (user.value?.isShowLawyer ?? false)
            ? "${expireDaysLawyer.value} ${'day'.tr}"
            : expireDaysLawyer.value > 0 &&
                    (!(user.value?.isShowLawyer ?? false))
                ? "${'in_queue'.tr}"
                : expireDaysLawyer.value <= 0 &&
                        (user.value?.isShowLawyer ?? false)
                    ? 'expired'.tr
                    : 'inactive'.tr;
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
            gradient: styleController.splashBackground,
          ),
          child: Scaffold(
            // bottomSheet: SizeTransition(
            //   sizeFactor: animationController.bottomNavigationBarController,
            //   child: Column(
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //       TextButton(
            //           style: styleController.buttonStyle(
            //
            //             padding: EdgeInsets.symmetric(
            //                 vertical: styleController.cardMargin * 3 / 2),
            //             radius: BorderRadius.vertical(
            //               top: Radius.circular(
            //                   styleController.cardBorderRadius / 2),
            //             ),
            //           ),
            //           onPressed: () async {
            //             loading.value = true;
            //
            //             loading.value = false;
            //           },
            //           child: Center(
            //             child: Text(
            //               "${'edit'.tr}",
            //               style: styleController.textMediumLightStyle
            //                   .copyWith(fontWeight: FontWeight.bold),
            //             ),
            //           )),
            //       SizedBox(
            //         height: styleController.bottomNavigationBarHeight,
            //       )
            //     ],
            //   ),
            // ),
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
                            height: Get.height / 3 +
                                styleController.cardBorderRadius * 2,
                            decoration: BoxDecoration(
                                gradient: styleController.splashBackground),
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/icon-light.png'),
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
                          height: styleController.topOffset,
                        ),
                      ),
                      SliverFillRemaining(
                        child: Container(
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
                              key: PageStorageKey<String>('profile'),
                              children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    profileWidget,
                                    //profile image
                                    Expanded(
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Padding(
                                          padding: EdgeInsets.all(
                                              styleController.cardMargin),
                                          child: IntrinsicHeight(
                                            child: Row(
                                              children: [
                                                Text(
                                                  "${'balance'.tr}",
                                                  style: styleController
                                                      .textHeaderStyle
                                                      .copyWith(
                                                          color: colors[600]),
                                                ),
                                                VerticalDivider(),
                                                TextButton(
                                                  onPressed: () => refresh(),
                                                  style: styleController
                                                      .buttonStyle(
                                                    radius: BorderRadius
                                                        .circular(styleController
                                                                .cardBorderRadius /
                                                            2),
                                                    backgroundColor:
                                                        styleController
                                                            .primaryMaterial[50],
                                                    padding: EdgeInsets.symmetric(
                                                        horizontal:
                                                            styleController
                                                                    .cardMargin /
                                                                2,
                                                        vertical: styleController
                                                                .cardMargin /
                                                            4),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        " ${user.value.wallet.asPrice()}  ${'currency'.tr}  ",
                                                        style: styleController
                                                            .textHeaderStyle
                                                            .copyWith(
                                                                color: colors[
                                                                    600]),
                                                      ),
                                                      loading.value
                                                          ? CupertinoActivityIndicator(
                                                              color:
                                                                  colors[600])
                                                          : Icon(
                                                              Icons.refresh,
                                                              color:
                                                                  colors[600],
                                                            )
                                                    ],
                                                  ),
                                                ),
                                                //charge wallet
                                                VerticalDivider(),
                                                TextButton(
                                                  onPressed: () {
                                                    settingController
                                                        .currentPageIndex = 4;
                                                    settingController
                                                        .bottomSheetController
                                                        .animateTo(4);
                                                  },
                                                  style: styleController
                                                      .buttonStyle(
                                                    radius: BorderRadius
                                                        .circular(styleController
                                                                .cardBorderRadius /
                                                            2),
                                                    backgroundColor:
                                                        styleController
                                                            .primaryMaterial[50],
                                                    padding: EdgeInsets.symmetric(
                                                        horizontal:
                                                            styleController
                                                                    .cardMargin /
                                                                2,
                                                        vertical: styleController
                                                                .cardMargin /
                                                            4),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        "  ${'charge'.tr}  ",
                                                        style: styleController
                                                            .textHeaderStyle
                                                            .copyWith(
                                                                color: colors[
                                                                    600]),
                                                      ),
                                                      Icon(
                                                        Icons
                                                            .account_balance_wallet,
                                                        color: colors[600],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: colors[50],
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(
                                            styleController.cardMargin),
                                        bottom: Radius.circular(
                                            styleController.cardMargin / 4),
                                      )),
                                  margin: EdgeInsets.symmetric(
                                      horizontal: styleController.cardMargin),
                                  child: TabBar(
                                    controller:
                                        userController.tabControllerProfile,
                                    tabs: userController.profileTabs,
                                    labelColor: colors[50],
                                    indicatorWeight: 2,
                                    indicator: BoxDecoration(
                                        color: colors[500],
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(
                                              styleController.cardMargin),
                                          bottom: Radius.circular(
                                              styleController.cardMargin / 4),
                                        )),
                                    indicatorColor: colors[500],
                                    unselectedLabelColor: colors[500],
                                  ),
                                ),
                                Expanded(
                                  child: SingleChildScrollView(
                                    physics: childScrollPhysics.value,
                                    controller:
                                        userController.childScrollController,
                                    child: Column(
                                      children: [
                                        //user info

                                        Visibility(
                                          visible: userController
                                                  .tabControllerProfile.index ==
                                              0,
                                          child: MiniCard(
                                            title: 'user_info'.tr,
                                            styleController: styleController,
                                            desc1: '',
                                            child: Container(
                                              child: Padding(
                                                  padding: EdgeInsets.all(
                                                      styleController
                                                              .cardMargin /
                                                          4),
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding: EdgeInsets.symmetric(
                                                        vertical:    styleController
                                                                .cardMargin /
                                                                4),
                                                        child: TextButton(
                                                          style: styleController
                                                              .buttonStyle(
                                                            padding: EdgeInsets.all(
                                                                styleController
                                                                    .cardMargin *
                                                                    2),
                                                            radius: BorderRadius.all(
                                                              Radius.circular(
                                                                  styleController
                                                                      .cardMargin),
                                                            ),
                                                            backgroundColor:
                                                            styleController
                                                                .primaryMaterial[
                                                            50]!
                                                                .withOpacity(.3),
                                                          ),
                                                          onPressed: () {
                                                            settingController.currentPageIndex=4;
                                                            settingController
                                                                .bottomSheetController
                                                                .animateTo(4);
                                                          },
                                                          child: Row(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                              children: [
                                                                IntrinsicHeight(
                                                                    child: Row(
                                                                        children: [
                                                                          Text(
                                                                            'status'.tr,
                                                                            style: styleController
                                                                                .textMediumStyle,
                                                                          ),
                                                                          VerticalDivider(),
                                                                          BlinkAnimation(
                                                                            child:
                                                                            Container(
                                                                              padding: EdgeInsets.symmetric(
                                                                                  horizontal:
                                                                                  styleController.cardMargin),
                                                                              decoration: BoxDecoration(
                                                                                  color: styleController
                                                                                      .primaryMaterial[
                                                                                  100]!
                                                                                      .withOpacity(
                                                                                      .2),
                                                                                  borderRadius:
                                                                                  BorderRadius.all(Radius.circular(styleController.cardMargin))),
                                                                              child: Text(
                                                                                  statusText
                                                                                      .value,
                                                                                  style: styleController
                                                                                      .textMediumStyle),
                                                                            ),
                                                                          )
                                                                        ])),
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
                                                      MyTextField(
                                                        backgroundColor:
                                                            Colors.white,
                                                        margin: EdgeInsets.symmetric(
                                                            vertical:
                                                                styleController
                                                                        .cardMargin /
                                                                    4),
                                                        icon: Icons.person,
                                                        controller:
                                                            filterController
                                                                .textNameCtrl,
                                                        hintText:
                                                            "${'name'.tr} ${'family'.tr}",
                                                        keyboardType:
                                                            TextInputType.name,
                                                      ),
                                                      MyTextField(
                                                        backgroundColor:
                                                            Colors.white,
                                                        margin: EdgeInsets.symmetric(
                                                            vertical:
                                                                styleController
                                                                        .cardMargin /
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
                                                      TextButton(
                                                          style: styleController
                                                              .buttonStyle(
                                                            backgroundColor:
                                                                styleController
                                                                        .primaryMaterial[
                                                                    500],
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        styleController.cardMargin *
                                                                            2),
                                                            radius: BorderRadius
                                                                .vertical(
                                                              bottom: Radius.circular(
                                                                  styleController
                                                                          .cardBorderRadius /
                                                                      2),
                                                            ),
                                                          ),
                                                          onPressed: () async {
                                                            edit({},
                                                                type: 'user');
                                                          },
                                                          child: Center(
                                                            child: Text(
                                                              "${'edit'.tr}",
                                                              style: styleController
                                                                  .textMediumLightStyle
                                                                  .copyWith(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                            ),
                                                          )),
                                                    ],
                                                  )),
                                            ),
                                          ),
                                        ),

                                        //change password
                                        Visibility(
                                          visible: userController
                                                  .tabControllerProfile.index ==
                                              0,
                                          child: MiniCard(
                                            title: 'password_change'.tr,
                                            styleController: styleController,
                                            desc1: '',
                                            child: Container(
                                              child: Padding(
                                                  padding: EdgeInsets.all(
                                                      styleController
                                                              .cardMargin /
                                                          4),
                                                  child: Column(
                                                    children: [
                                                      MyTextField(
                                                        backgroundColor:
                                                            Colors.white,
                                                        margin: EdgeInsets.symmetric(
                                                            vertical:
                                                                styleController
                                                                        .cardMargin /
                                                                    4),
                                                        icon: Icons.password,
                                                        controller:
                                                            filterController
                                                                .textPaswOldCtrl,
                                                        hintText:
                                                            'password_old'.tr,
                                                        keyboardType:
                                                            TextInputType.text,
                                                        obscure: true,
                                                      ),
                                                      MyTextField(
                                                        backgroundColor:
                                                            Colors.white,
                                                        margin: EdgeInsets.symmetric(
                                                            vertical:
                                                                styleController
                                                                        .cardMargin /
                                                                    4),
                                                        icon: Icons
                                                            .password_outlined,
                                                        controller:
                                                            filterController
                                                                .textPaswCtrl,
                                                        hintText:
                                                            "${'password_new'.tr}",
                                                        keyboardType:
                                                            TextInputType.text,
                                                        obscure: true,
                                                      ),
                                                      MyTextField(
                                                        backgroundColor:
                                                            Colors.white,
                                                        margin: EdgeInsets.symmetric(
                                                            vertical:
                                                                styleController
                                                                        .cardMargin /
                                                                    4),
                                                        icon: Icons
                                                            .password_outlined,
                                                        controller:
                                                            filterController
                                                                .textPaswConfCtrl,
                                                        hintText:
                                                            "${'password_rep'.tr}",
                                                        keyboardType:
                                                            TextInputType.text,
                                                        obscure: true,
                                                      ),
                                                      TextButton(
                                                          style: styleController
                                                              .buttonStyle(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        styleController.cardMargin *
                                                                            2),
                                                            radius: BorderRadius
                                                                .vertical(
                                                              bottom: Radius.circular(
                                                                  styleController
                                                                          .cardBorderRadius /
                                                                      2),
                                                            ),
                                                          ),
                                                          onPressed: () async {
                                                            edit({},
                                                                type:
                                                                    'password');
                                                          },
                                                          child: Center(
                                                            child: Text(
                                                              "${'edit'.tr}",
                                                              style: styleController
                                                                  .textMediumLightStyle
                                                                  .copyWith(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                            ),
                                                          )),
                                                    ],
                                                  )),
                                            ),
                                          ),
                                        ),
                                        // lawyer info
                                        Visibility(
                                          visible: userController
                                                  .tabControllerProfile.index ==
                                              1,
                                          child: MiniCard(
                                            disabled: !user.value.isLawyer,
                                            title: 'user_lawyer_info'.tr,
                                            styleController: styleController,
                                            desc1: '',
                                            child: Container(
                                              padding: EdgeInsets.all(
                                                  styleController.cardMargin /
                                                      4),
                                              child: Column(
                                                children: [
                                                  // lawyer status
                                                  TextButton(
                                                    style: styleController
                                                        .buttonStyle(
                                                      padding: EdgeInsets.all(
                                                          styleController
                                                                  .cardMargin *
                                                              2),
                                                      radius: BorderRadius.all(
                                                        Radius.circular(
                                                            styleController
                                                                .cardMargin),
                                                      ),
                                                      backgroundColor:
                                                          styleController
                                                              .primaryMaterial[
                                                                  50]!
                                                              .withOpacity(.3),
                                                    ),
                                                    onPressed: () { settingController.currentPageIndex=4;settingController
                                                        .bottomSheetController
                                                        .animateTo(4);},
                                                    child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          IntrinsicHeight(
                                                              child: Row(
                                                                  children: [
                                                                Text(
                                                                  'status'.tr,
                                                                  style: styleController
                                                                      .textMediumStyle,
                                                                ),
                                                                VerticalDivider(),
                                                                BlinkAnimation(
                                                                  child:
                                                                      Container(
                                                                    padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            styleController.cardMargin),
                                                                    decoration: BoxDecoration(
                                                                        color: styleController
                                                                            .primaryMaterial[
                                                                                100]!
                                                                            .withOpacity(
                                                                                .2),
                                                                        borderRadius:
                                                                            BorderRadius.all(Radius.circular(styleController.cardMargin))),
                                                                    child: Text(
                                                                        statusTextLawyer
                                                                            .value,
                                                                        style: styleController
                                                                            .textMediumStyle),
                                                                  ),
                                                                )
                                                              ])),
                                                          IntrinsicHeight(
                                                              child: Text(statusTextLawyer
                                                                          .value ==
                                                                      'expired'
                                                                          .tr
                                                                  ? 'click_for_pay'
                                                                      .tr
                                                                  : '')),
                                                        ]),
                                                  ),
                                                  SizedBox(
                                                    height: styleController
                                                        .cardMargin,
                                                  ),
                                                  //document image
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      documentWidget,
                                                      Center(
                                                        child: Text(
                                                          'lawyer_document'.tr,
                                                          style: styleController
                                                              .textMediumStyle,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  //sex
                                                  MyToggleButtons(
                                                    type: 'sex',
                                                    controller:
                                                        filterController,
                                                    styleController:
                                                        styleController,
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
                                                  ),
                                                  MyToggleButtons(
                                                    type: 'lawyer/expert',
                                                    controller:
                                                        filterController,
                                                    styleController:
                                                        styleController,
                                                    children: [
                                                      Container(
                                                          padding: EdgeInsets.all(
                                                              styleController
                                                                  .cardMargin),
                                                          child: Text(
                                                              'lawyer'.tr)),
                                                      Container(
                                                          padding: EdgeInsets.all(
                                                              styleController
                                                                  .cardMargin),
                                                          child:
                                                              Text('expert'.tr))
                                                    ],
                                                  ),
                                                  MyTextField(
                                                    backgroundColor:
                                                        Colors.white,
                                                    margin: EdgeInsets.symmetric(
                                                        vertical: styleController
                                                                .cardMargin /
                                                            4),
                                                    icon: Icons.person,
                                                    controller: filterController
                                                        .textNameCtrl,
                                                    hintText:
                                                        "${'name'.tr} ${'family'.tr}",
                                                    keyboardType:
                                                        TextInputType.name,
                                                  ),
                                                  MyTextField(
                                                    backgroundColor:
                                                        Colors.white,
                                                    margin: EdgeInsets.symmetric(
                                                        vertical: styleController
                                                                .cardMargin /
                                                            4),
                                                    icon: Icons.alternate_email,
                                                    controller: filterController
                                                        .textEmailCtrl,
                                                    hintText: "${'email'.tr}",
                                                    keyboardType: TextInputType
                                                        .emailAddress,
                                                  ),
                                                  //tel
                                                  MyTextField(
                                                    backgroundColor:
                                                        Colors.white,
                                                    margin: EdgeInsets.symmetric(
                                                        vertical: styleController
                                                                .cardMargin /
                                                            4),
                                                    icon: Icons.phone,
                                                    controller: filterController
                                                        .textTelCtrl,
                                                    hintText: "${'tel'.tr}",
                                                    keyboardType:
                                                        TextInputType.number,
                                                  ),
                                                  //code
                                                  MyTextField(
                                                    backgroundColor:
                                                        Colors.white,
                                                    margin: EdgeInsets.symmetric(
                                                        vertical: styleController
                                                                .cardMargin /
                                                            4),
                                                    icon: Icons
                                                        .account_box_rounded,
                                                    controller: filterController
                                                        .textLawyerCodeCtrl,
                                                    hintText:
                                                        "${'lawyer_code'.tr}",
                                                    keyboardType:
                                                        TextInputType.text,
                                                  ),
                                                  //melli
                                                  MyTextField(
                                                    backgroundColor:
                                                        Colors.white,
                                                    margin: EdgeInsets.symmetric(
                                                        vertical: styleController
                                                                .cardMargin /
                                                            4),
                                                    icon: Icons.credit_card,
                                                    controller: filterController
                                                        .textMelliCodeCtrl,
                                                    hintText:
                                                        "${'code_melli'.tr}",
                                                    keyboardType:
                                                        TextInputType.number,
                                                  ),
                                                  MyDropdownButton(
                                                    onChanged: (idx) {
                                                      counties.value = settingController
                                                          .counties
                                                          .where((e) =>
                                                              e['province_id'] ==
                                                              filterController
                                                                      .filters[
                                                                  'province'])
                                                          .toList();
                                                    },
                                                    styleController:
                                                        styleController,
                                                    controller: userController
                                                        .filterController,
                                                    type: 'province',
                                                    children: settingController
                                                        .provinces,
                                                    margin: EdgeInsets.only(
                                                        left: styleController
                                                                .cardMargin /
                                                            4,
                                                        right: styleController
                                                            .cardMargin,
                                                        bottom: styleController
                                                                .cardMargin /
                                                            4,
                                                        top: styleController
                                                                .cardMargin /
                                                            4),
                                                  ),
                                                  MyDropdownButton(
                                                    styleController:
                                                        styleController,
                                                    controller:
                                                        filterController,
                                                    type: 'county',
                                                    children: counties.value,
                                                    margin: EdgeInsets.only(
                                                        left: styleController
                                                                .cardMargin /
                                                            4,
                                                        right: styleController
                                                            .cardMargin,
                                                        bottom: styleController
                                                                .cardMargin /
                                                            4,
                                                        top: styleController
                                                                .cardMargin /
                                                            4),
                                                  ),

                                                  MyDatePicker(
                                                      beforeData:
                                                          DateTime.tryParse(user
                                                              .value
                                                              .lawyerBirthday),
                                                      children:
                                                          settingController
                                                              .dates,
                                                      controller: userController
                                                          .filterController,
                                                      styleController:
                                                          styleController,
                                                      onChanged: (date) {}),

                                                  MyMultiSelect(
                                                      onChanged: (data) {
                                                        userController
                                                                .filterController
                                                                .filters[
                                                            'categories'] = data;
                                                      },
                                                      children: userController
                                                              .filterController
                                                              .filters[
                                                          'categories'],
                                                      controller: userController
                                                          .filterController,
                                                      styleController:
                                                          styleController,
                                                      colors: colors),

                                                  MyTextField(
                                                    backgroundColor:
                                                        Colors.white,
                                                    margin: EdgeInsets.symmetric(
                                                        vertical: styleController
                                                                .cardMargin /
                                                            4),
                                                    icon: Icons
                                                        .home_repair_service_sharp,
                                                    controller: filterController
                                                        .textLawyerAddressCtrl,
                                                    hintText: "${'address'.tr}",
                                                    keyboardType:
                                                        TextInputType.text,
                                                    minLines: 3,
                                                  ),
                                                  MyTextField(
                                                    backgroundColor:
                                                        Colors.white,
                                                    margin: EdgeInsets.symmetric(
                                                        vertical: styleController
                                                                .cardMargin /
                                                            4),
                                                    icon: Icons
                                                        .account_box_rounded,
                                                    controller: filterController
                                                        .textLawyerBioCtrl,
                                                    hintText: "${'cv'.tr}",
                                                    keyboardType:
                                                        TextInputType.text,
                                                    minLines: 3,
                                                  ),
                                                  TextButton(
                                                      style: styleController
                                                          .buttonStyle(
                                                        padding: EdgeInsets.symmetric(
                                                            vertical:
                                                                styleController
                                                                        .cardMargin *
                                                                    2),
                                                        radius: BorderRadius
                                                            .vertical(
                                                          bottom: Radius.circular(
                                                              styleController
                                                                      .cardBorderRadius /
                                                                  2),
                                                        ),
                                                      ),
                                                      onPressed: () async {
                                                        edit({},
                                                            type: 'lawyer');
                                                      },
                                                      child: Center(
                                                        child: Text(
                                                          "${'edit'.tr}",
                                                          style: styleController
                                                              .textMediumLightStyle
                                                              .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                        ),
                                                      ))
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        //exit
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                            horizontal:
                                                styleController.cardMargin,
                                            vertical:
                                                styleController.cardMargin / 2,
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
                                                    style: styleController
                                                        .buttonStyle(
                                                            backgroundColor:
                                                                Colors.red,
                                                            splashColor: Colors
                                                                .white
                                                                .withOpacity(
                                                                    .5)),
                                                    onPressed: () => Get.dialog(
                                                          Center(
                                                            child: Material(
                                                              color: Colors
                                                                  .transparent,
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
                                                                color: Colors
                                                                    .white,
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
                                                                        padding:
                                                                            EdgeInsets.all(styleController.cardMargin /
                                                                                2),
                                                                        child:
                                                                            Text(
                                                                          'sure_to_exit?'
                                                                              .tr,
                                                                          textAlign:
                                                                              TextAlign.right,
                                                                          style:
                                                                              styleController.textBigStyle,
                                                                        ),
                                                                      ),
                                                                      Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
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
                                                                                  'cancel'.tr,
                                                                                  style: styleController.textMediumStyle,
                                                                                )),
                                                                          ),
                                                                          VerticalDivider(
                                                                            indent:
                                                                                styleController.cardMargin / 2,
                                                                            endIndent:
                                                                                styleController.cardMargin / 2,
                                                                          ),
                                                                          Expanded(
                                                                            child: TextButton(
                                                                                style: styleController.buttonStyle(backgroundColor: Colors.red, splashColor: Colors.white.withOpacity(.5)),
                                                                                onPressed: () {
                                                                                  Get.back();
                                                                                  userController.logout();
                                                                                },
                                                                                child: Text(
                                                                                  'verify'.tr,
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
                                                          barrierDismissible:
                                                              true,
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
                                        SizedBox(
                                          height: styleController
                                                  .bottomNavigationBarHeight /
                                              2,
                                        ),
                                      ],
                                    ),
                                  ),
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
                        color: styleController.primaryColor.withOpacity(.7),
                        child: Center(
                          child: ShakeWidget(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(
                                          styleController.cardMargin))),
                              child: Padding(
                                padding:
                                    EdgeInsets.all(styleController.cardMargin),
                                child: CircularProgressIndicator(
                                    color: styleController.primaryColor),
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
      case 'lawyer':
        params = {
          'fullname': filterController.textNameCtrl.text,
          'email': filterController.textEmailCtrl.text,
          'tel': filterController.textTelCtrl.text,
          'address': filterController.textLawyerAddressCtrl.text,
          'lawyer_number': filterController.textLawyerCodeCtrl.text,
          'lawyer_melicard': filterController.textMelliCodeCtrl.text,
          'lawyer_birthday': (filterController.filters['year'] != null &&
                  filterController.filters['month'] != null &&
                  filterController.filters['day'] != null)
              ? "${filterController.filters['year'].padLeft(4, '0')}-${filterController.filters['month'].padLeft(2, '0')}-${filterController.filters['day'].padLeft(2, '0')}"
              : null,
          'cv': filterController.textLawyerBioCtrl.text,
          'city_id': filterController.filters['county'],
          'lawyer_sex': filterController.filters['sex'] ? 1 : 0,
          'is_lawyer': !filterController.filters['lawyer/expert'] ? 1 : 0,
          'is_expert': filterController.filters['lawyer/expert'] ? 1 : 0,
          'categories': filterController.filters['categories']
              .where((e) => e['selected'] == true)
              .map((e) {
                return e['id'];
              })
              .toList()
              .join(','),
          'document': params['document'] ?? ''
        };

        if (params['document'] == '' || params['document'] == null)
          params.remove('document');

        break;
      case 'user':
        params = {
          'fullname': filterController.textNameCtrl.text,
          'email': filterController.textEmailCtrl.text,
          'avatar': params['avatar'] ?? ''
        };
        if (params['avatar'] == '' || params['avatar'] == null)
          params.remove('avatar');
        break;
    }
    var res = await userController.edit(params: params, type: type);
    if (res && params['password_old'] != '') {
      filterController.textPaswOldCtrl.clear();
      filterController.textPaswCtrl.clear();
      filterController.textPaswConfCtrl.clear();
    }
    loading.value = false;
  }

  isEditable() {
    return true;
  }
}
