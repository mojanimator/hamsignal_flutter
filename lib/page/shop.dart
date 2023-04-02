import 'package:dabel_adl/helper/helpers.dart';
import 'package:dabel_adl/model/Product.dart';
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
  late Style styleController;
  late MyAnimationController animationController;
  late IAPPurchase iAPPurchase;
  late Helper helper;
  late TabBar tabBar;
  GlobalKey<SideMenuState> _sideMenuKey =
      GlobalKey<SideMenuState>(debugLabel: 'sideMenuKey');
  final _key = GlobalKey();

  ShopPage() {
    settingController = Get.find<SettingController>();
    animationController = Get.find<MyAnimationController>();
    styleController = Get.find<Style>();
    iAPPurchase = Get.find<IAPPurchase>();
    userController = Get.find<UserController>();
    iAPPurchase = Get.find<IAPPurchase>();
    helper = Get.find<Helper>();
    tabBar = TabBar(
      controller: userController.tabControllerShop,
      indicator: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            styleController.cardMargin,
          ),
          bottom: Radius.circular(
            styleController.cardMargin,
          ),
        ),
        color: styleController.secondaryColor,
      ),
      labelColor: styleController.primaryColor,
      unselectedLabelColor: styleController.secondaryColor,
      tabs: [
        Tab(text: 'wallet_charge'.tr),
        Tab(text: 'buy_plan'.tr),
      ],
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _key,
        body: RefreshIndicator(
            onRefresh: () {
              settingController.update();
              return Future(() => null);
            },
            child: SideMenu(
                key: _sideMenuKey,
                inverse: true,
                closeIcon: Icon(
                  Icons.close,
                  color: styleController.primaryColor,
                ),
                radius: BorderRadius.circular(styleController.cardBorderRadius),
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
                      gradient: styleController.mainGradientBackground,
                      image: DecorationImage(
                          image: AssetImage("assets/images/texture.jpg"),
                          repeat: ImageRepeat.repeat,
                          fit: BoxFit.scaleDown,
                          filterQuality: FilterQuality.medium,
                          colorFilter: ColorFilter.mode(
                              styleController.secondaryColor.withOpacity(.2),
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
                              title: Padding(
                                padding:
                                    EdgeInsets.all(styleController.cardMargin),
                                child: IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      Text(
                                        "${'balance'.tr}",
                                        style: styleController.textHeaderStyle
                                            .copyWith(
                                                color: styleController
                                                    .primaryMaterial[600]),
                                      ),
                                      VerticalDivider(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons
                                                .account_balance_wallet_rounded,
                                            color: styleController
                                                .primaryMaterial[50],
                                          ),
                                          Text(
                                            " ${'balance'.tr} ",
                                            style: styleController
                                                .textHeaderStyle
                                                .copyWith(
                                                    color: styleController
                                                        .primaryMaterial[50]),
                                          ),
                                          VerticalDivider(
                                              color: styleController
                                                  .primaryMaterial[50]),
                                          Text(
                                            " ${userController.user?.wallet.asPrice()}  ${'currency'.tr}  ",
                                            style: styleController
                                                .textHeaderStyle
                                                .copyWith(
                                                    color: styleController
                                                        .primaryMaterial[50]),
                                          ),
                                        ],
                                      ),
                                      //charge wallet
                                    ],
                                  ),
                                ),
                              ),
                              backgroundColor:
                                  styleController.primaryColor.withOpacity(0),
                              elevation: 0.0,
                              forceElevated: false,
                              pinned: true,
                              floating: true,
                              primary: false,
                              centerTitle: false,
                              titleSpacing: NavigationToolbar.kMiddleSpacing,
                              automaticallyImplyLeading: true,
                              bottom: PreferredSize(
                                preferredSize: tabBar.preferredSize,
                                child: Container(
                                  color: styleController.primaryColor,
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
                                      vertical: styleController.cardMargin),
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
                                                  margin: EdgeInsets.symmetric(
                                                    horizontal: styleController
                                                        .cardMargin,
                                                    vertical: styleController
                                                        .cardMargin /
                                                        2,
                                                  ).copyWith(
                                                      right: styleController
                                                          .cardMargin /
                                                          (true ? 2 : 1)),
                                                  background: 'back5.png',
                                                  title: item.name,
                                                  icon: 'icon-light.png',
                                                  onClick: () {
                                                    if (userController.user ==
                                                        null ||
                                                        userController
                                                            .user?.id ==
                                                            null) {
                                                      helper.showToast(
                                                          msg:
                                                          'LOGIN_OR_REGISTER'
                                                              .tr,
                                                          status: 'danger');
                                                      return;
                                                    }
                                                    iAPPurchase.showPayDialog(
                                                        product: item,
                                                        onPayClicked: () async {
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
                                              height:
                                              styleController.imageHeight,
                                            )
                                          ])),
                                      //plan
                                      SingleChildScrollView(
                                          physics: BouncingScrollPhysics(),
                                          child: Column(children: [
                                            //
                                            for (var item in iAPPurchase.plans)
                                              ShakeWidget(
                                                child: BannerCard(
                                                  margin: EdgeInsets.symmetric(
                                                    horizontal: styleController
                                                        .cardMargin,
                                                    vertical: styleController
                                                            .cardMargin /
                                                        2,
                                                  ).copyWith(
                                                      right: styleController
                                                              .cardMargin /
                                                          (true ? 2 : 1)),
                                                  background: 'back1.png',
                                                  title:
                                                      "${item['title']} | ${"${item['day']}"} ${'day'.tr} | ${"${item['price']}".asPrice()} ${'currency'.tr}",
                                                  icon: 'icon-light.png',
                                                  onClick: () {
                                                    if (userController.user ==
                                                            null ||
                                                        userController
                                                                .user?.id ==
                                                            null) {
                                                      helper.showToast(
                                                          msg:
                                                              'LOGIN_OR_REGISTER'
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
                                              height:
                                                  styleController.imageHeight,
                                            )
                                          ])),

                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ))))));
  }
}
