import 'dart:async';

import 'package:animations/animations.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:hamsignal/controller/APIProvider.dart';
import 'package:hamsignal/controller/AdvController.dart';
import 'package:hamsignal/controller/AnimationController.dart';
import 'package:hamsignal/controller/DocumentController.dart';
import 'package:hamsignal/controller/LegalController.dart';
import 'package:hamsignal/controller/LinkController.dart';
import 'package:hamsignal/controller/EventController.dart';
import 'package:hamsignal/controller/LocationController.dart';
import 'package:hamsignal/controller/NewsController.dart';
import 'package:hamsignal/controller/SettingController.dart';
import 'package:hamsignal/controller/SignalController.dart';
import 'package:hamsignal/controller/TicketController.dart';
import 'package:hamsignal/controller/TransactionController.dart';
import 'package:hamsignal/controller/UserController.dart';
import 'package:hamsignal/helper/helpers.dart';
import 'package:hamsignal/helper/styles.dart';
import 'package:hamsignal/helper/translations.dart';
import 'package:hamsignal/helper/variables.dart';
import 'package:hamsignal/page/books.dart';
import 'package:hamsignal/page/contracts.dart';
import 'package:hamsignal/page/documents.dart';
import 'package:hamsignal/page/legals.dart';
import 'package:hamsignal/page/locations.dart';
import 'package:hamsignal/page/menu_drawer.dart';
import 'package:hamsignal/page/newses.dart';
import 'package:hamsignal/page/shop.dart';
import 'package:hamsignal/page/signals.dart';
import 'package:hamsignal/page/support_page.dart';
import 'package:hamsignal/page/register_login_screen.dart';
import 'package:hamsignal/page/splash_screen.dart';
import 'package:hamsignal/page/user_profile.dart';
import 'package:hamsignal/widget/AppBar.dart';
import 'package:hamsignal/widget/banner_card.dart';
import 'package:hamsignal/widget/shakeanimation.dart';
import 'package:hamsignal/widget/slide_menu.dart';
import 'package:hamsignal/widget/vitrin_advs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hamsignal/widget/vitrin_news.dart';
import 'package:uni_links/uni_links.dart';

import 'controller/BookController.dart';
import 'controller/ContractController.dart';
import 'controller/LawyerController.dart';
import 'model/Category.dart';
import 'page/lawyers.dart';
import 'page/tutorials.dart';

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
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await initUniLinks();
  Helper.initPushPole();
  MobileAds.instance.initialize();
  // runZonedGuarded(() async {
  runApp(MyApp());
  // }, (error, stackTrace) async {
  //   // print(error);
  //   Helper.sendError({'message': "$error \n $stackTrace"});
  // });
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  final style = Get.put(Style());

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      style.setSize(context.size?.width);
    });
    // GetStorage box = GetStorage();
    // final translate = Get.put(MyTranslations());
    // Get.updateLocale(const Locale('fa', 'IR'));

    return GetMaterialApp(
        onDispose: () {},
        title: Variables.LABEL,
        color: style.primaryColor,

        // title: 'label'.tr,
        debugShowCheckedModeBanner: false,
        // defaultTransition: Transition.native,
        translations: MyTranslations(),
        locale: const Locale('fa', 'IR'),
        fallbackLocale: const Locale('fa', 'IR'),
        theme: style.theme,
        home: MyHomePage());
  }
}

class MyHomePage extends StatelessWidget {
  final style = Get.find<Style>();
  final apiProvider = Get.put(ApiProvider());
  final helper = Get.put(Helper());

  final settingController = Get.put(SettingController());
  final userController = Get.put(UserController());

  final animationController = Get.put(MyAnimationController());
  final signalController = Get.put(SignalController());
  final lawyerController = Get.put(LawyerController());
  final newsController = Get.put(NewsController());
  final linkController = Get.put(LinkController());
  final locationController = Get.put(LocationController());
  final legalController = Get.put(LegalController());
  final bookController = Get.put(BookController());
  final documentController = Get.put(DocumentController());
  final contractController = Get.put(ContractController());
  final ticketController = Get.put(TicketController());
  final transactionController = Get.put(TransactionController());
 static RxBool ticketNotification=false.obs;
  // Get.put(IAPPurchase(
  // keys: settingController.keys,
  // products: settingController.plans,
  // plans: settingController.plans));
  MyHomePage({Key? key, title}) : super(key: key) {
    userController.getUser(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    // Get.updateLocale(const Locale('fa', 'IR'));

    return Container(
        decoration: BoxDecoration(
          gradient: style.splashBackground,
          image: DecorationImage(
              image: AssetImage("assets/images/texture.jpg"),
              repeat: ImageRepeat.repeat,
              fit: BoxFit.scaleDown,
              filterQuality: FilterQuality.medium,
              colorFilter: ColorFilter.mode(
                  style.primaryColor.withOpacity(.1), BlendMode.darken),
              opacity: .15),
          // LinearGradient(
          //   begin: Alignment.topCenter,
          //   end: Alignment.bottomCenter,
          //   colors: <Color>[
          //     style.primaryMaterial[50]!,
          //     style.primaryMaterial[50]!,
          //     style.primaryMaterial[200]!,
          //   ],
          // ),
        ),
        child: userController.obx((user) {
          if (user != null) settingController.getData();
          ticketNotification.value=user!.ticketNotification;
          return settingController.obx(
            (setting) {
              return Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.transparent,
                extendBody: true,
                // appBar: AppBar(title: Text('label'.tr)),
                bottomNavigationBar: Obx(()=>
                   ConvexAppBar.badge(
                    {
                      3: ! ticketNotification.value
                          ? Center()
                          : Stack(children: [
                              Positioned(
                                top: 0,
                                left: 0,
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                style.cardBorderRadius))),
                                    padding: EdgeInsets.all(2),
                                    child: Text(
                                      ' + ',
                                      style: style.textSmallLightStyle.copyWith(fontWeight: FontWeight.bold),
                                    )),
                              )
                            ])
                    },

                    backgroundColor: Colors.white,
                    color: style.primaryMaterial[800]!.withOpacity(.9),
                    activeColor: style.primaryColor,
                    height: style.bottomNavigationBarHeight,
                    // curveSize: 100,
                    style: TabStyle.reactCircle,
                    elevation: 5,
                    // cornerRadius: 64,
                    items: [
                      TabItem(icon: Icons.person_sharp, title: 'profile'.tr),
                      TabItem(icon: Icons.school, title: 'tutorial'.tr),
                      TabItem(icon: Icons.home, title: 'label'.tr),
                      TabItem(
                          icon: Icons.headset_mic_rounded, title: 'support'.tr),
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
                ),

                body: PageTransitionSwitcher(
                  child: <Widget>[
                    UserProfilePage(),
                    TutorialsPage(),
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
            onError: (msg) => RegisterLoginScreen(error: msg),
            onLoading: SplashScreen(
              isLoading: true,
            ),
            onEmpty: SplashScreen(),
          );
        },
            onError: (msg) => RegisterLoginScreen(error: msg),
            onLoading: SplashScreen(
              isLoading: true,
            ),
            onEmpty: SplashScreen()));
  }
}

class MainPage extends StatelessWidget {
  final style = Get.find<Style>();

  final apiProvider = Get.find<ApiProvider>();
  final userController = Get.find<UserController>();
  final animationController = Get.find<MyAnimationController>();
  final settingController = Get.find<SettingController>();
  final newsController = Get.find<NewsController>();
  final lawyerController = Get.find<LawyerController>();
  final linkController = Get.find<LinkController>();
  late EdgeInsets marginLeft;
  late EdgeInsets marginRight;
  GlobalKey<SideMenuState> _sideMenuKey =
      Get.put(GlobalKey<SideMenuState>(debugLabel: 'sideMenuKey'));

  MainPage() {
    marginLeft = EdgeInsets.symmetric(
      horizontal: style.cardMargin / 2,
      vertical: style.cardMargin / 2,
    ).copyWith(right: style.cardMargin / 4, bottom: style.cardMargin);
    marginRight = EdgeInsets.symmetric(
      horizontal: style.cardMargin / 2,
      vertical: style.cardMargin / 2,
    ).copyWith(left: style.cardMargin / 4, bottom: style.cardMargin);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      settingController.resolveDeepLink(deepLink);
      deepLink = null;
      settingController.showUpdateDialogIfRequired();

      //
      // Future.delayed(
      //   Duration(seconds: 2),
      // () => Get.to(NewsPage()),
      // () => Get.to(SignalsPage(
      //   category: 'boors'.tr,
      //   colors: style.boorsMaterial,
      // )),
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
                  style.secondaryColor.withOpacity(.2), BlendMode.darken),
              opacity: .1),
        ),
        child: MyAppBar(
          child: RefreshIndicator(
            onRefresh: refreshAll,
            child: ListView(
              padding: EdgeInsets.zero,
              physics: BouncingScrollPhysics(),
              children: [
                //advs vitrin
                if (settingController.adv.type['native'] == null ||
                    settingController.adv.advs.length == 0)
                  VitrinNews(
                      margin: EdgeInsets.symmetric(
                    horizontal: style.cardMargin / (style.isBigSize ? 2 : 1),
                  )),
                if (!(settingController.adv.type['native'] == null ||
                    settingController.adv.advs.length == 0))
                  // blog vitrin
                  VitrinAdv(
                      margin: EdgeInsets.symmetric(
                        horizontal:
                            style.cardMargin / (style.isBigSize ? 2 : 1),
                      ),
                      failedWidget: VitrinNews(
                          margin: EdgeInsets.symmetric(
                        horizontal:
                            style.cardMargin / (style.isBigSize ? 2 : 1),
                      ))),
                ShakeWidget(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(style.cardBorderRadius)),
                    ),
                    shadowColor: style.primaryColor.withOpacity(.5),
                    color: Colors.transparent,
                    elevation: 20,
                    margin: EdgeInsets.all(style.cardMargin),
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/images/texture.jpg"),
                            repeat: ImageRepeat.repeat,
                            fit: BoxFit.scaleDown,
                            filterQuality: FilterQuality.medium,
                            colorFilter: ColorFilter.mode(
                                style.primaryColor.withOpacity(.1),
                                BlendMode.darken),
                            opacity: .1),
                        borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(style.cardBorderRadius)),
                        gradient: style.cardGradientBackgroundReverse,
                      ),
                      child: Padding(
                          padding: EdgeInsets.all(style.cardMargin),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (false)
                                Padding(
                                  padding: EdgeInsets.all(style.cardMargin),
                                  child: Text(
                                    'menu'.tr,
                                    style: style.textHeaderStyle.copyWith(
                                        color: style.primaryMaterial[900]),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              if (false)
                                Divider(
                                  height: 1,
                                  thickness: 3,
                                  endIndent: Get.width / 2,
                                  color: style.cardLinkColors[900],
                                ),
                              Row(
                                children: [
                                  Expanded(
                                    child: BannerCard(
                                        margin: marginLeft,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                style.cardMargin * 2)),
                                        background: 'back1.png',
                                        title: '${"boors".tr}',
                                        icon: 'boors.gif',
                                        onClick: () {
                                          if (userController.hasPlan(
                                              goShop: true, message: true))
                                            Get.to(SignalsPage(
                                              category: 'boors'.tr,
                                              colors: style.boorsMaterial,
                                            ));
                                        }),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: BannerCard(
                                        margin: marginLeft,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                style.cardMargin * 2)),
                                        background: 'back2.png',
                                        title: '${"crypto".tr}',
                                        icon: 'crypto.gif',
                                        onClick: () {
                                          if (userController.hasPlan(
                                              goShop: true, message: true))
                                            Get.to(SignalsPage(
                                              category: 'crypto'.tr,
                                              colors: style.boorsMaterial,
                                            ));
                                        }),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: BannerCard(
                                        margin: marginLeft,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                style.cardMargin * 2)),
                                        background: 'back5.png',
                                        title: '${"forex".tr}',
                                        icon: 'forex.gif',
                                        onClick: () {
                                          if (userController.hasPlan(
                                              goShop: true, message: true))
                                            Get.to(SignalsPage(
                                              category: 'forex'.tr,
                                              colors: style.boorsMaterial,
                                            ));
                                        }),
                                  ),
                                ],
                              ),
                            ],
                          )),
                    ),
                  ),
                ),

                //blogs vitrin

                SizedBox(
                  height: style.cardVitrinHeight / 2,
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
