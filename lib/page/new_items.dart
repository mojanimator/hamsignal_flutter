import 'package:dabel_sport/controller/AnimationController.dart';
import 'package:dabel_sport/controller/SettingController.dart';
import 'package:dabel_sport/helper/IAPPurchase.dart';
import 'package:dabel_sport/helper/helpers.dart';
import 'package:dabel_sport/helper/styles.dart';
import 'package:dabel_sport/page/club_create.dart';
import 'package:dabel_sport/page/coach_create.dart';
import 'package:dabel_sport/page/menu_drawer.dart';
import 'package:dabel_sport/page/player_create.dart';
import 'package:dabel_sport/page/shop_create.dart';
import 'package:dabel_sport/widget/AppBar.dart';
import 'package:dabel_sport/widget/shakeanimation.dart';
import 'package:dabel_sport/widget/slide_menu.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewItemPage extends StatelessWidget {
  late final SettingController settingController;
  late final Style styleController;
  late final MyAnimationController animationController;
  late final IAPPurchase iAPPurchase;
  RxDouble _dividerWidth = 0.0.obs;
  final _key = GlobalKey();
  late EdgeInsets margin;
  late Map<String, Map<String, dynamic>> items;
  GlobalKey<SideMenuState> _sideMenuKey =
      GlobalKey<SideMenuState>(debugLabel: 'sideMenuKey');

  NewItemPage({Key? key}) : super(key: key) {
    settingController = Get.find<SettingController>();
    animationController = Get.find<MyAnimationController>();
    styleController = Get.find<Style>();
    iAPPurchase = Get.find<IAPPurchase>();
    margin = EdgeInsets.symmetric(
      horizontal: styleController.cardMargin,
      vertical: styleController.cardMargin / 4,
    );

    items = {
      'player': {
        'colors': styleController.cardPlayerColors,
        'page': PlayerCreate(),
        'tag': 'player_create'
      },
      'coach': {
        'colors': styleController.cardCoachColors,
        'page': CoachCreate(),
        'tag': 'coach_create'
      },
      'club': {
        'colors': styleController.cardClubColors,
        'page': ClubCreate(),
        'tag': 'club_create'
      },
      'shop': {
        'colors': styleController.cardShopColors,
        'page': ShopCreate(),
        'tag': 'shop_create'
      },
    };

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _dividerWidth.value = (_key.currentContext?.size?.width ?? 0) / 2;
    //   Get.to(PlayerCreate())?.then((result) {
    //     if (result == 'done') {
    //       settingController.currentPageIndex = 4;
    //       Get.find<Helper>().showToast(
    //           msg:
    //               'با موفقیت ثبت شد! می توانید اطلاعات ثبت شده را مشاهده یا ویرایش نمایید.',
    //           status: 'success');
    //     }
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      body: RefreshIndicator(
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
            decoration:
                BoxDecoration(gradient: styleController.mainGradientBackground),
            child: MyAppBar(
              sideMenuKey: _sideMenuKey,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(children: [
                  ...items.keys
                      .map((e) => ShakeWidget(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    styleController.cardBorderRadius),
                              ),
                              shadowColor:
                                  items[e]?['colors'][500].withOpacity(.5),
                              color: items[e]?['colors'][100]?.withOpacity(1.0),
                              elevation: 20,
                              margin: margin,
                              child: InkWell(
                                onTap: () =>
                                    Get.to(items[e]?['page'])?.then((result) {
                                      if (result != null &&
                                          result['msg'] !=
                                              null &&
                                          result['status'] !=
                                              null) {
                                        settingController.refresh();
                                        settingController.helper
                                            .showToast(
                                            msg: result[
                                            'msg'],
                                            status: result[
                                            'status']);
                                      }
                                }),
                                splashColor:
                                    items[e]?['colors'][500].withOpacity(.3),
                                child: Container(
                                  child: Padding(
                                    padding: EdgeInsets.all(
                                        styleController.cardMargin),
                                    child: IntrinsicHeight(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Column(
                                            children: [
                                              Text(
                                                "${'register'.tr} ${e.tr}",
                                                style: styleController
                                                    .textHeaderStyle
                                                    .copyWith(
                                                        color: items[e]
                                                            ?['colors'][900]),
                                                textAlign: TextAlign.right,
                                              ),
                                              Hero(
                                                tag: items[e]?['tag'],
                                                child: Image.asset(
                                                  'assets/images/$e.png',
                                                  color: items[e]?['colors']
                                                      [500],
                                                  height: styleController
                                                      .imageHeight,
                                                ),
                                              ),
                                            ],
                                          ),
                                          IntrinsicWidth(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: iAPPurchase.allProducts
                                                  .where((element) =>
                                                      element.id.contains(e))
                                                  .map((el) => Container(
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    styleController
                                                                            .cardBorderRadius /
                                                                        2),
                                                            color: items[e]?[
                                                                        'colors']
                                                                    [200]
                                                                .withOpacity(
                                                                    .3)),
                                                        padding: EdgeInsets.symmetric(
                                                            horizontal:
                                                                styleController
                                                                    .cardMargin,
                                                            vertical:
                                                                styleController
                                                                        .cardMargin /
                                                                    2),
                                                        margin: EdgeInsets.symmetric(
                                                            vertical:
                                                                styleController
                                                                        .cardMargin /
                                                                    4),
                                                        child: Text(
                                                            "${el.month} ${'month'.tr}: ${el.price.asPrice()} ${'currency'.tr}"),
                                                        alignment:
                                                            Alignment.center,
                                                      ))
                                                  .toList(),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                  SizedBox(
                    height: styleController.cardMargin * 6,
                  )
                ]),
              ),
            ),
          ),
        ),
        onRefresh: () {
          settingController.update();
          return Future(() => null);
        },
      ),
    );
  }
}
