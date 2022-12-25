import 'dart:async';

import 'package:animations/animations.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:dabel_sport/controller/APIProvider.dart';
import 'package:dabel_sport/controller/AnimationController.dart';
import 'package:dabel_sport/controller/BlogController.dart';
import 'package:dabel_sport/controller/ClubController.dart';
import 'package:dabel_sport/controller/CoachController.dart';
import 'package:dabel_sport/controller/EventController.dart';
import 'package:dabel_sport/controller/LatestController.dart';
import 'package:dabel_sport/controller/PlayerController.dart';
import 'package:dabel_sport/controller/ProductController.dart';
import 'package:dabel_sport/controller/SettingController.dart';
import 'package:dabel_sport/controller/ShopController.dart';
import 'package:dabel_sport/controller/TournamentController.dart';
import 'package:dabel_sport/controller/UserController.dart';
import 'package:dabel_sport/helper/helpers.dart';
import 'package:dabel_sport/helper/styles.dart';
import 'package:dabel_sport/helper/translations.dart';
import 'package:dabel_sport/helper/variables.dart';
import 'package:dabel_sport/page/conductor_page.dart';
import 'package:dabel_sport/page/menu_drawer.dart';
import 'package:dabel_sport/page/messages_page.dart';
import 'package:dabel_sport/page/new_items.dart';
import 'package:dabel_sport/page/register_login_screen.dart';
import 'package:dabel_sport/page/splash_screen.dart';
import 'package:dabel_sport/page/user_profile.dart';
import 'package:dabel_sport/widget/AppBar.dart';
import 'package:dabel_sport/widget/loader.dart';
import 'package:dabel_sport/widget/slide_menu.dart';
import 'package:dabel_sport/widget/vitrin_blog.dart';
import 'package:dabel_sport/widget/vitrin_clubs.dart';
import 'package:dabel_sport/widget/vitrin_coaches.dart';
import 'package:dabel_sport/widget/vitrin_latest.dart';
import 'package:dabel_sport/widget/vitrin_main.dart';
import 'package:dabel_sport/widget/vitrin_players.dart';
import 'package:dabel_sport/widget/vitrin_shops.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:uni_links/uni_links.dart';

Uri? deepLink;
StreamSubscription? _sub;

Future<void> initUniLinks() async {
  // Platform messages may fail, so we use a try/catch PlatformException.
  try {
    deepLink = await getInitialUri(); //first run
    _sub = uriLinkStream.listen((Uri? link) {
      //when run app in background
      // print("deep link resume: $deepLink");

      if (link != null) deepLink = link;
    }, onError: (err) {
      // Handle exception by warning the user their action did not succeed
    });
    // print("deep link start: $deepLink");

    // Parse the link and warn the user, if it is not correct,
    // but keep in mind it could be `null`.
  } on PlatformException {
    // Handle exception by warning the user their action did not succeed
    // return?
  }
}

void main() async {
  await GetStorage.init();
  await initUniLinks();
  runZonedGuarded<Future<Null>>(() async {
    runApp(MyApp());
  }, (error, stackTrace) async {
    // print(error);
    Helper.sendError({'message': "$error \n $stackTrace"});
  });
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  final styleController = Get.put(Style());

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      styleController.setSize(context.size?.width);
    });
    // GetStorage box = GetStorage();
    // final translate = Get.put(MyTranslations());
    // Get.updateLocale(const Locale('fa', 'IR'));

    return GetMaterialApp(
        onDispose: () {},
        title: Variables.LABEL,
        // title: 'label'.tr,
        debugShowCheckedModeBanner: false,
        // defaultTransition: Transition.native,
        translations: MyTranslations(),
        locale: const Locale('fa', 'IR'),
        fallbackLocale: const Locale('fa', 'IR'),
        theme: styleController.theme,
        home: MyHomePage());
  }
}

class MyHomePage extends StatelessWidget {
  final styleController = Get.find<Style>();
  final apiProvider = Get.put(ApiProvider());
  final helper = Get.put(Helper());
  final userController = Get.put(UserController());
  final settingController = Get.put(SettingController());
  final animationController = Get.put(MyAnimationController());

  MyHomePage({Key? key, title}) : super(key: key) {}

  @override
  Widget build(BuildContext context) {
    // Get.updateLocale(const Locale('fa', 'IR'));

    return Container(
        decoration: BoxDecoration(gradient: styleController.splashBackground
            // LinearGradient(
            //   begin: Alignment.topCenter,
            //   end: Alignment.bottomCenter,
            //   colors: <Color>[
            //     styleController.primaryMaterial[50]!,
            //     styleController.primaryMaterial[50]!,
            //     styleController.primaryMaterial[200]!,
            //   ],
            // ),
            ),
        child: settingController.obx(
            (setting) => userController.obx((user) {
                  Get.put(BlogController());
                  Get.put(LatestController());
                  Get.put(PlayerController());
                  Get.put(CoachController());
                  Get.put(ClubController());
                  Get.put(ShopController());
                  Get.put(ProductController());
                  Get.put(EventController());
                  Get.put(TournamentController());
                  TabController bottomSheetController = TabController(
                      length: 5,
                      initialIndex: settingController.currentPageIndex,
                      vsync: Get.find<MyAnimationController>());

                  bottomSheetController.addListener(() {
                    // settingController.currentPageIndex =bottomSheetController.index;
                  });
                  return Scaffold(
                    resizeToAvoidBottomInset: false,
                    backgroundColor: Colors.transparent,
                    extendBody: true,
                    // appBar: AppBar(title: Text('label'.tr)),
                    bottomNavigationBar: ConvexAppBar.badge(
                      {
                        3: true
                            ? Center()
                            : Stack(children: [
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(styleController
                                                  .cardBorderRadius))),
                                      padding: EdgeInsets.all(2),
                                      child: Text(
                                        '3+',
                                        style:
                                            styleController.textSmallLightStyle,
                                      )),
                                )
                              ])
                      },

                      backgroundColor: Colors.white,
                      color:
                          styleController.primaryMaterial[500]!.withOpacity(.9),
                      activeColor: Colors.deepPurple,
                      height: styleController.bottomNavigationBarHeight,
                      // curveSize: 100,
                      style: TabStyle.flip,
                      elevation: 5,
                      // cornerRadius: 64,
                      items: [
                        TabItem(icon: Icons.add, title: ' '),
                        TabItem(
                            icon: Image.asset('assets/images/conductor.png'),
                            title: ' '),
                        TabItem(icon: Icons.home, title: ' '),
                        TabItem(icon: Icons.message, title: ' '),
                        TabItem(icon: Icons.person_sharp, title: ' '),
                      ],
                      initialActiveIndex: settingController.currentPageIndex,
                      controller: bottomSheetController,
                      //optional, default as 0
                      onTap: (int i) {
                        settingController.currentPageIndex = i;
                        animationController.closeDrawer();
                      },
                    ),

                    body: PageTransitionSwitcher(
                      child: <Widget>[
                        NewItemPage(),
                        ConductorPage(),
                        MainPage(),
                        MessagesPage(),
                        UserProfilePage(),
                      ][settingController.currentPageIndex],
                      transitionBuilder: (
                        Widget child,
                        Animation<double> primaryAnimation,
                        Animation<double> secondaryAnimation,
                      ) {
                        return FadeScaleTransition(
                          animation: primaryAnimation,

                          // animation: Tween(begin: 0.0, end: 1.0).animate(
                          // CurvedAnimation(
                          //   parent: animationController.bottomNavigationBarController,
                          //   curve: Curves.ease,
                          // ),),
                          // secondaryAnimation: secondaryAnimation,
                          child: child,
                        );
                      },
                    ),
                  );
                },
                    onLoading: SplashScreen(
                      isLoading: true,
                    ),
                    onEmpty: SplashScreen(),
                    onError: (msg) => RegisterLoginScreen(error: msg)),
            onLoading: SplashScreen(
              isLoading: true,
            ),
            onEmpty: SplashScreen()));
  }
}

class MainPage extends StatelessWidget {
  final styleController = Get.find<Style>();

  final apiProvider = Get.find<ApiProvider>();
  final animationController = Get.find<MyAnimationController>();
  final settingController = Get.find<SettingController>();
  final blogController = Get.find<BlogController>();
  final latestController = Get.find<LatestController>();
  final playerController = Get.find<PlayerController>();
  final coachController = Get.find<CoachController>();
  final clubController = Get.find<ClubController>();
  final shopController = Get.find<ShopController>();
  final productController = Get.find<ProductController>();

  GlobalKey<SideMenuState> _sideMenuKey =
      Get.put(GlobalKey<SideMenuState>(debugLabel: 'sideMenuKey'));

  MainPage() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      settingController.resolveDeepLink(deepLink);
      deepLink = null;
      settingController.showUpdateDialogIfRequired();
    });
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   final _state = _sideMenuKey.currentState;
    //   if (_state!.isOpened) {
    //     _state.closeSideMenu();
    //     animationController.closeDrawer();
    //   } else {
    //     _state.openSideMenu();
    //     animationController.openDrawer();
    //     // _animationButtonController.reverse();
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return SideMenu(
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
          child: RefreshIndicator(
            onRefresh: refreshAll,
            child: ListView(
              physics: AlwaysScrollableScrollPhysics(),
              children: [
                // main vitrin
                MainVitrin(
                  margin: EdgeInsets.only(
                    left: styleController.cardMargin,
                    right: styleController.cardMargin,
                  ),
                ),
                //blogs vitrin

                VitrinBlog(
                  colors: Colors.deepPurple,
                ),

                //latest vitrin
                latestController.obx((data) {
                  return VitrinLatest(
                    data!,
                    latestController,
                    swiperFraction: .5,
                    colors: Colors.blue,
                  );
                }, onEmpty: Center(), onLoading: Loader()),
                Row(
                  children: [
                    //players vitrin
                    Expanded(
                        child: VitrinPlayers(
                      playerController,
                      colors: styleController.cardPlayerColors,
                      margin: EdgeInsets.only(
                        left: styleController.cardMargin / 4,
                        right: styleController.cardMargin,
                        top: styleController.cardMargin / 4,
                        bottom: styleController.cardMargin / 4,
                      ),
                    )),
                    // coaches vitrin
                    if (styleController.isBigSize)
                      Expanded(
                          child: VitrinCoaches(
                        coachController,
                        colors: styleController.cardCoachColors,
                        margin: EdgeInsets.only(
                            left: styleController.cardMargin,
                            right: styleController.cardMargin / 4),
                      )),
                  ],
                ),
                if (!styleController.isBigSize)
                  Row(
                    children: [
                      Expanded(
                          child: VitrinCoaches(
                        coachController,
                        colors: styleController.cardCoachColors,
                        margin: EdgeInsets.only(
                            left: styleController.cardMargin,
                            right: styleController.cardMargin / 4),
                      )),
                    ],
                  ),
                Row(
                  children: [
                    //players vitrin
                    Expanded(
                        child: VitrinClubs(
                      clubController,
                      colors: styleController.cardClubColors,
                      margin: EdgeInsets.only(
                        left: styleController.cardMargin / 4,
                        right: styleController.cardMargin,
                        top: styleController.cardMargin / 4,
                        bottom: styleController.cardMargin / 4,
                      ),
                    )),
                    if (styleController.isBigSize)
                      // coaches vitrin
                      Expanded(
                          child: VitrinShops(
                        shopController,
                        colors: styleController.cardShopColors,
                        margin: EdgeInsets.only(
                            left: styleController.cardMargin,
                            right: styleController.cardMargin / 4),
                      )),
                  ],
                ),
                if (!styleController.isBigSize)
                  // coaches vitrin
                  Row(
                    children: [
                      Expanded(
                          child: VitrinShops(
                        shopController,
                        colors: styleController.cardShopColors,
                        margin: EdgeInsets.only(
                            left: styleController.cardMargin,
                            right: styleController.cardMargin / 4),
                      )),
                    ],
                  ),
                SizedBox(
                  height: styleController.cardMargin * 2,
                )
              ],
            ),
          ),
          sideMenuKey: _sideMenuKey,
        ),
      ),
    );
  }

  Future<void> refreshAll() {
    settingController.refresh();
    // blogController.getData();
    latestController.getData(param: {'page': 'clear'});
    playerController.getData(param: {'page': 'clear'});
    coachController.getData(param: {'page': 'clear'});
    clubController.getData(param: {'page': 'clear'});
    shopController.getData(param: {'page': 'clear'});
    return Future.value(null);
  }
}
