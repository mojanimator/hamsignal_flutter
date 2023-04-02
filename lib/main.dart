import 'dart:async';

import 'package:animations/animations.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:dabel_adl/controller/APIProvider.dart';
import 'package:dabel_adl/controller/AnimationController.dart';
import 'package:dabel_adl/controller/DocumentController.dart';
import 'package:dabel_adl/controller/FinderController.dart';
import 'package:dabel_adl/controller/LegalController.dart';
import 'package:dabel_adl/controller/LinkController.dart';
import 'package:dabel_adl/controller/EventController.dart';
import 'package:dabel_adl/controller/LatestController.dart';
import 'package:dabel_adl/controller/LocationController.dart';
import 'package:dabel_adl/controller/SettingController.dart';
import 'package:dabel_adl/controller/UserController.dart';
import 'package:dabel_adl/helper/IAPPurchase.dart';
import 'package:dabel_adl/helper/helpers.dart';
import 'package:dabel_adl/helper/styles.dart';
import 'package:dabel_adl/helper/translations.dart';
import 'package:dabel_adl/helper/variables.dart';
import 'package:dabel_adl/page/Contents.dart';
import 'package:dabel_adl/page/books.dart';
import 'package:dabel_adl/page/conductor_page.dart';
import 'package:dabel_adl/page/contracts.dart';
import 'package:dabel_adl/page/documents.dart';
import 'package:dabel_adl/page/finders.dart';
import 'package:dabel_adl/page/legals.dart';
import 'package:dabel_adl/page/locations.dart';
import 'package:dabel_adl/page/menu_drawer.dart';
import 'package:dabel_adl/page/shop.dart';
import 'package:dabel_adl/page/support_page.dart';
import 'package:dabel_adl/page/register_login_screen.dart';
import 'package:dabel_adl/page/splash_screen.dart';
import 'package:dabel_adl/page/user_profile.dart';
import 'package:dabel_adl/widget/AppBar.dart';
import 'package:dabel_adl/widget/banner_card.dart';
import 'package:dabel_adl/widget/loader.dart';
import 'package:dabel_adl/widget/shakeanimation.dart';
import 'package:dabel_adl/widget/slide_menu.dart';
import 'package:dabel_adl/widget/vitrin_content.dart';
import 'package:dabel_adl/widget/vitrin_main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:uni_links/uni_links.dart';

import 'controller/BookController.dart';
import 'controller/ContentController.dart';
import 'controller/ContractController.dart';
import 'controller/LawyerController.dart';
import 'controller/LinkController.dart';
import 'controller/LinkController.dart';
import 'model/Category.dart';
import 'page/lawyers.dart';
import 'widget/vitrin_links.dart';

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
  // runZonedGuarded<Future<Null>>(() async {
  runApp(MyApp());
  // }, (error, stackTrace) async {
  //   // print(error);
  //   Helper.sendError({'message': "$error \n $stackTrace"});
  // });
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
        color: styleController.primaryColor,

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

  final settingController = Get.put(SettingController());
  final animationController = Get.put(MyAnimationController());

  MyHomePage({Key? key, title}) : super(key: key) {}

  @override
  Widget build(BuildContext context) {
    // Get.updateLocale(const Locale('fa', 'IR'));

    return Container(
        decoration: BoxDecoration(
          gradient: styleController.splashBackground,
          image: DecorationImage(
              image: AssetImage("assets/images/texture.jpg"),
              repeat: ImageRepeat.repeat,
              fit: BoxFit.scaleDown,
              filterQuality: FilterQuality.medium,
              colorFilter: ColorFilter.mode(
                  styleController.primaryColor.withOpacity(.1),
                  BlendMode.saturation),
              opacity: .05),
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
            (setting) => Get.find<UserController>().obx((user) {
                  Get.put(LawyerController());
                  Get.put(ContentController());
                  Get.put(LinkController());
                  Get.put(LocationController());
                  Get.put(LegalController());
                  Get.put(BookController());
                  Get.put(DocumentController());
                  Get.put(ContractController());
                  Get.put(FinderController());

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
                      activeColor: styleController.primaryMaterial[800],
                      height: styleController.bottomNavigationBarHeight,
                      // curveSize: 100,
                      style: TabStyle.flip,
                      elevation: 5,
                      // cornerRadius: 64,
                      items: [
                        TabItem(icon: Icons.person_sharp, title: 'profile'.tr),
                        TabItem(icon: Icons.search, title: 'search'.tr),
                        TabItem(icon: Icons.home, title: 'label'.tr),
                        TabItem(
                            icon: Icons.headset_mic_rounded,
                            title: 'support'.tr),
                        TabItem(icon: Icons.shopping_cart, title: 'shop'.tr),
                      ],

                      initialActiveIndex: settingController.currentPageIndex,
                      controller: settingController.bottomSheetController,
                      //optional, default as 0
                      onTap: (int i) {
                        settingController.currentPageIndex = i;
                        animationController.closeDrawer();
                      },
                    ),

                    body: PageTransitionSwitcher(
                      child: <Widget>[
                        UserProfilePage(),
                        FindersPage(),
                        MainPage(),
                        SupportPage(),
                        ShopPage(),
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
  final contentController = Get.find<ContentController>();
  final lawyerController = Get.find<LawyerController>();
  final linkController = Get.find<LinkController>();

  GlobalKey<SideMenuState> _sideMenuKey =
      Get.put(GlobalKey<SideMenuState>(debugLabel: 'sideMenuKey'));

  MainPage() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      settingController.resolveDeepLink(deepLink);
      deepLink = null;
      settingController.showUpdateDialogIfRequired();

      // Future.delayed(
      //   Duration(seconds: 2),
      //   () => Get.to(ContentsPage( )),
      // );
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
          child: RefreshIndicator(
            onRefresh: refreshAll,
            child: ListView(
              padding: EdgeInsets.zero,
              physics: BouncingScrollPhysics(),
              children: [
                // blog vitrin
                VitrinContent(
                    margin: EdgeInsets.symmetric(
                  horizontal: styleController.cardMargin /
                      (styleController.isBigSize ? 2 : 1),
                )),
                LinkVitrin(
                  margin: EdgeInsets.symmetric(
                    horizontal: styleController.cardMargin /
                        (styleController.isBigSize ? 2 : 1),
                    vertical: styleController.cardMargin / 2,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: BannerCard(
                          margin: EdgeInsets.symmetric(
                            horizontal: styleController.cardMargin,
                            vertical: styleController.cardMargin / 2,
                          ).copyWith(
                              right: styleController.cardMargin /
                                  (true ? 2 : 1)),
                          background: 'back7.png',
                          title: 'news'.tr,
                          // titleColor: styleController.primaryColor,
                          icon: 'news.gif',
                          onClick: () => Get.to(ContentsPage())),
                    ),
                  ],
                ),
                Row(
                  children: [

                    Expanded(
                      child: BannerCard(
                          margin: EdgeInsets.symmetric(
                            horizontal: styleController.cardMargin,
                            vertical: styleController.cardMargin / 2,
                          ).copyWith(
                              left:
                                  styleController.cardMargin / (true ? 2 : 1)),
                          background: 'back5.png',
                          title:
                              "${'lawyer'.tr}${true ? '\n' : '/'}${'expert'.tr}",
                          icon: 'lawyer.gif',
                          onClick: () => Get.to(LawyersPage())),
                    ),
                    if (true)
                      Expanded(
                        child: BannerCard(
                            margin: EdgeInsets.symmetric(
                              horizontal: styleController.cardMargin,
                              vertical: styleController.cardMargin / 2,
                            ).copyWith(
                                right: styleController.cardMargin /
                                    (true ? 2 : 1)),
                            background: 'back1.png',
                            title: 'search_legal_locations'.tr,
                            icon: 'location.gif',
                            onClick: () => Get.to(LocationsPage())),
                      ),
                  ],
                ),
                if (!true)
                  BannerCard(
                      margin: EdgeInsets.symmetric(
                        horizontal: styleController.cardMargin,
                        vertical: styleController.cardMargin / 2,
                      ),
                      background: 'back1.png',
                      title: 'search_legal_locations'.tr,
                      icon: 'location.gif',
                      onClick: () => Get.to(LocationsPage())),
                Row(
                  children: [
                    Expanded(
                      child: BannerCard(
                          margin: EdgeInsets.symmetric(
                            horizontal: styleController.cardMargin,
                            vertical: styleController.cardMargin / 2,
                          ).copyWith(
                              left:
                                  styleController.cardMargin / (true ? 2 : 1)),
                          background: 'back2.png',
                          title:
                              '${"dadkhast".tr}${true ? '\n' : '/'}${"layehe".tr}',
                          icon: 'hammer.gif',
                          onClick: () => Get.to(LegalsPage())),
                    ),
                    if (true)
                      Expanded(
                        child: BannerCard(
                            margin: EdgeInsets.symmetric(
                              horizontal: styleController.cardMargin,
                              vertical: styleController.cardMargin / 2,
                            ).copyWith(
                                right: styleController.cardMargin /
                                    (true ? 2 : 1)),
                            background: 'back4.png',
                            title: 'rules'.tr,
                            icon: 'justice.gif',
                            onClick: () => Get.to(BooksPage())),
                      ),
                  ],
                ),
                if (!true)
                  BannerCard(
                      margin: EdgeInsets.symmetric(
                        horizontal: styleController.cardMargin,
                        vertical: styleController.cardMargin / 2,
                      ),
                      background: 'back4.png',
                      title: 'rules'.tr,
                      icon: 'justice.gif',
                      onClick: () => Get.to(BooksPage())),

                Row(
                  children: [
                    Expanded(
                      child: BannerCard(
                          margin: EdgeInsets.symmetric(
                            horizontal: styleController.cardMargin,
                            vertical: styleController.cardMargin / 2,
                          ).copyWith(
                              left:
                                  styleController.cardMargin / (true ? 2 : 1)),
                          background: 'back5.png',
                          title: '${"votes".tr}',
                          icon: 'vote.gif',
                          onClick: () => Get.to(DocumentsPage(
                              colors: styleController.cardVotesColors,
                              categoryType: CategoryRelate.Votes))),
                    ),
                    if (true)
                      Expanded(
                        child: BannerCard(
                            margin: EdgeInsets.symmetric(
                              horizontal: styleController.cardMargin,
                              vertical: styleController.cardMargin / 2,
                            ).copyWith(
                                right: styleController.cardMargin /
                                    (true ? 2 : 1)),
                            background: 'back1.png',
                            title: 'opinions'.tr,
                            icon: 'vote.gif',
                            onClick: () => Get.to(DocumentsPage(
                                colors: styleController.cardOpinionsColors,
                                categoryType: CategoryRelate.Opinions))),
                      ),
                  ],
                ),
                if (!true)
                  BannerCard(
                      margin: EdgeInsets.symmetric(
                        horizontal: styleController.cardMargin,
                        vertical: styleController.cardMargin / 2,
                      ),
                      background: 'back1.png',
                      title: 'opinions'.tr,
                      icon: 'vote.gif',
                      onClick: () => Get.to(DocumentsPage(
                          colors: styleController.cardOpinionsColors,
                          categoryType: CategoryRelate.Opinions))),

                Row(
                  children: [
                    Expanded(
                      child: BannerCard(
                          margin: EdgeInsets.symmetric(
                            horizontal: styleController.cardMargin,
                            vertical: styleController.cardMargin / 2,
                          ).copyWith(
                              left:
                                  styleController.cardMargin / (true ? 2 : 1)),
                          background: 'back2.png',
                          title: '${"conventions".tr}',
                          icon: 'convention.gif',
                          onClick: () => Get.to(DocumentsPage(
                              colors: styleController.cardConventionsColors,
                              categoryType: CategoryRelate.Conventions))),
                    ),
                    if (true)
                      Expanded(
                        child: BannerCard(
                            margin: EdgeInsets.symmetric(
                              horizontal: styleController.cardMargin,
                              vertical: styleController.cardMargin / 2,
                            ).copyWith(
                                right: styleController.cardMargin /
                                    (true ? 2 : 1)),
                            background: 'back4.png',
                            title: 'contracts'.tr,
                            icon: 'contract.gif',
                            onClick: () => Get.to(ContractsPage())),
                      ),
                  ],
                ),
                if (!true)
                  BannerCard(
                      margin: EdgeInsets.symmetric(
                        horizontal: styleController.cardMargin /
                            (styleController.isBigSize ? 2 : 1),
                        vertical: styleController.cardMargin / 2,
                      ),
                      background: 'back4.png',
                      title: 'contracts'.tr,
                      icon: 'contract.gif',
                      onClick: () => Get.to(ContractsPage())),

                //blogs vitrin

                SizedBox(
                  height: styleController.cardVitrinHeight / 2,
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

    return Future.value(null);
  }
}
