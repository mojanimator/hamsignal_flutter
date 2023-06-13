import 'package:get_storage/get_storage.dart';
import 'package:hamsignal/helper/helpers.dart';
import 'package:hamsignal/model/Product.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/AnimationController.dart';
import '../controller/SettingController.dart';
import '../controller/UserController.dart';
import '../helper/IAPPurchase.dart';
import '../helper/styles.dart';
import '../widget/AppBar.dart';
import '../widget/banner_card.dart';
import '../widget/shakeanimation.dart';
import '../widget/slide_menu.dart';
import 'menu_drawer.dart';

class ShopPage extends StatelessWidget {
  late SettingController settingController;
  late UserController userController;
  late Style style;
  late MyAnimationController animationController;
  late IAPPurchase iAPPurchase;
  late Helper helper;
  late TabBar tabBar;
  String? filter;
  GlobalKey<SideMenuState> _sideMenuKey =
      GlobalKey<SideMenuState>(debugLabel: 'sideMenuKey');
  final _key = GlobalKey();
  RxInt expireDays = 0.obs;
  RxString statusText = "".obs;
  ShopPage({this.filter = 'charge'}) {
    settingController = Get.find<SettingController>();
    animationController = Get.find<MyAnimationController>();
    style = Get.find<Style>();
    iAPPurchase = Get.find<IAPPurchase>();
    userController = Get.find<UserController>();
    iAPPurchase = Get.find<IAPPurchase>();
    helper = Get.find<Helper>();

    if (filter != 'charge')
      userController.tabControllerShop.index = 1;
    else
      userController.tabControllerShop.index = 0;
    tabBar = TabBar(
      controller: userController.tabControllerShop,
      indicator: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            style.cardMargin,
          ),
          bottom: Radius.circular(
            style.cardMargin,
          ),
        ),
        color: style.secondaryColor,
      ),
      labelColor: style.primaryColor,
      unselectedLabelColor: style.secondaryColor,
      tabs: [
        Tab(text: 'wallet_charge'.tr),
        Tab(text: 'buy_plan'.tr),
      ],
    );

    DateTime now = DateTime.now();
    DateTime expireDaysDateTime =
    userController.user?.expiresAt != null && userController.user?.expiresAt != ''
        ? DateTime.tryParse(userController.user!.expiresAt) ?? now
        : now;

    expireDays.value = expireDaysDateTime.difference(now).inDays;
    statusText.value = !userController.user!.isActive
        ? 'blocked'.tr
        : "${expireDays.value > 0 ? expireDays.value : 0} ${'day'.tr}";
    // WidgetsBinding.instance.addPostFrameCallback((_) => Future.delayed(
    //       Duration(seconds: 1),
    //       () => Get.dialog(iAPPurchase.showPlanDialog(
    //         item: iAPPurchase.plans[0],
    //       )),
    //     ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _key,
        body: userController.obx(
          (data) => RefreshIndicator(
              onRefresh: () {
                settingController.update();
                return Future(() => null);
              },
              child: SideMenu(
                  key: _sideMenuKey,
                  inverse: true,
                  closeIcon: Icon(
                    Icons.close,
                    color: style.primaryColor,
                  ),
                  radius: BorderRadius.circular(style.cardBorderRadius),
                  closeDrawer: animationController.closeDrawer,
                  menu: DrawerMenu(onTap: () {
                    final _state = _sideMenuKey.currentState;
                    if (_state!.isOpened) {
                      _state.closeSideMenu();
                      animationController.closeDrawer();
                    } else {
                      _state.openSideMenu();
                      animationController.openDrawer();
                      // _animationButtonController.reverse();
                    }
                  }),
                  background: Colors.transparent,
                  child: Container(
                      decoration: BoxDecoration(
                        gradient: style.mainGradientBackground,
                        image: DecorationImage(
                            image: AssetImage("assets/images/texture.jpg"),
                            repeat: ImageRepeat.repeat,
                            fit: BoxFit.scaleDown,
                            filterQuality: FilterQuality.medium,
                            colorFilter: ColorFilter.mode(
                                style.secondaryColor.withOpacity(.2),
                                BlendMode.colorBurn),
                            opacity: .05),
                      ),
                      child: MyAppBar(
                          sideMenuKey: _sideMenuKey,
                          child: NestedScrollView(
                            physics: BouncingScrollPhysics(),
                            floatHeaderSlivers: true,
                            headerSliverBuilder: (context, bool) => [
                              SliverAppBar(
                                automaticallyImplyLeading: false,
                                title: Padding(
                                  padding: EdgeInsets.all(style.cardMargin),
                                  child: IntrinsicHeight(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.account_balance_wallet_rounded,
                                          color: style.primaryMaterial[800],
                                        ),
                                        VerticalDivider(
                                            color: style.primaryMaterial[800]),
                                        Text(
                                          " ${"${userController.user?.wallet}".asPrice()} ${"currency".tr}",
                                          style: style.textHeaderStyle.copyWith(
                                              color:
                                                  style.primaryMaterial[800]),
                                        ),
                                        SizedBox(width: style.cardMargin*2,),
                                        Icon(
                                          Icons.person,
                                          color: style.primaryMaterial[800],
                                        ),
                                        VerticalDivider(
                                            color: style.primaryMaterial[800]),
                                        Text(
                                          statusText.value,
                                          style: style.textHeaderStyle.copyWith(
                                              color:
                                              style.primaryMaterial[800]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                backgroundColor:
                                    style.primaryColor.withOpacity(0),
                                elevation: 0.0,
                                forceElevated: false,
                                pinned: true,
                                floating: true,
                                primary: false,
                                centerTitle: false,
                                titleSpacing: NavigationToolbar.kMiddleSpacing,
                                bottom: PreferredSize(
                                  preferredSize: tabBar.preferredSize,
                                  child: Container(
                                    color: style.primaryColor,
                                    child: tabBar,
                                  ),
                                ),
                              ),
                            ],
                            body: Column(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: style.cardMargin),
                                    child: TabBarView(
                                      controller:
                                          userController.tabControllerShop,
                                      children: [
                                        //charge
                                        SingleChildScrollView(
                                            physics: BouncingScrollPhysics(),
                                            child: Column(children: [
                                              //
                                              for (ProductItem item
                                                  in iAPPurchase.products)
                                                ShakeWidget(
                                                  child: BannerCard(
                                                    margin: EdgeInsets
                                                        .symmetric(
                                                      horizontal:
                                                          style.cardMargin,
                                                      vertical:
                                                          style.cardMargin / 2,
                                                    ).copyWith(
                                                        right:
                                                            style.cardMargin /
                                                                (true ? 2 : 1)),
                                                    background: 'back1.png',
                                                    // titleColor: style.primaryColor,
                                                    title: item.name,
                                                    icon: 'wallet.png',
                                                    onClick: () {
                                                      if (userController.user ==
                                                              null ||
                                                          userController
                                                                  .user?.id ==
                                                              null) {
                                                        helper.showToast(
                                                            msg:
                                                                'login_or_register'
                                                                    .tr,
                                                            status: 'danger');
                                                        return;
                                                      }
                                                      iAPPurchase.showPayDialog(
                                                          product: item,
                                                          onPayClicked:
                                                              () async {
                                                            await iAPPurchase
                                                                .purchase(
                                                                    params: {
                                                                  'amount':
                                                                      "${item.price}0",
                                                                  'title':
                                                                      "${item.name}",
                                                                  'product_id':
                                                                      item.id,
                                                                  'consumable':
                                                                      item.consumable
                                                                          ? 1
                                                                          : 0
                                                                });
                                                          });
                                                    },
                                                  ),
                                                ),
                                              SizedBox(
                                                height: style.imageHeight,
                                              )
                                            ])),
                                        //plan
                                        SingleChildScrollView(
                                            physics: BouncingScrollPhysics(),
                                            child: Column(children: [
                                              //
                                              for (var item
                                                  in iAPPurchase.plans.toList())
                                                ShakeWidget(
                                                  child: BannerCard(
                                                    margin: EdgeInsets
                                                        .symmetric(
                                                      horizontal:
                                                          style.cardMargin,
                                                      vertical:
                                                          style.cardMargin / 2,
                                                    ).copyWith(
                                                        right:
                                                            style.cardMargin /
                                                                4),
                                                    background: 'back5.png',
                                                    // titleColor: style.primaryColor,
                                                    title:
                                                        "${item['name']} | ${"${item['price']}".asPrice()} ${'currency'.tr}",
                                                    icon: 'icon-light.png',
                                                    onClick: () {
                                                      if (userController.user ==
                                                              null ||
                                                          userController
                                                                  .user?.id ==
                                                              null) {
                                                        helper.showToast(
                                                            msg:
                                                                'login_or_register'
                                                                    .tr,
                                                            status: 'danger');
                                                        return;
                                                      }
                                                      Get.dialog(iAPPurchase
                                                          .showPlanDialog(
                                                        item: item,
                                                      ));
                                                    },
                                                  ),
                                                ),
                                              SizedBox(
                                                height: style.imageHeight,
                                              )
                                            ])),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))))),
        ));
  }
}
