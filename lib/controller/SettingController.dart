import 'dart:convert';
import 'dart:io';

import 'package:dabel_sport/controller/APIProvider.dart';
import 'package:dabel_sport/controller/BlogController.dart';
import 'package:dabel_sport/controller/CoachController.dart';
import 'package:dabel_sport/controller/PlayerController.dart';
import 'package:dabel_sport/controller/ProductController.dart';
import 'package:dabel_sport/controller/ShopController.dart';
import 'package:dabel_sport/controller/UserController.dart';
import 'package:dabel_sport/helper/helpers.dart';
import 'package:dabel_sport/helper/styles.dart';
import 'package:dabel_sport/helper/variables.dart';
import 'package:dabel_sport/model/App.dart';
import 'package:dabel_sport/model/Blog.dart';
import 'package:dabel_sport/model/Club.dart';
import 'package:dabel_sport/model/Coach.dart';
import 'package:dabel_sport/model/Player.dart';
import 'package:dabel_sport/model/Product.dart';
import 'package:dabel_sport/model/Shop.dart';
import 'package:dabel_sport/page/blog_details.dart';
import 'package:dabel_sport/page/blogs.dart';
import 'package:dabel_sport/page/club_details.dart';
import 'package:dabel_sport/page/clubs.dart';
import 'package:dabel_sport/page/coach_details.dart';
import 'package:dabel_sport/page/coaches.dart';
import 'package:dabel_sport/page/contact_us.dart';
import 'package:dabel_sport/page/player_details.dart';
import 'package:dabel_sport/page/players.dart';
import 'package:dabel_sport/page/product_details.dart';
import 'package:dabel_sport/page/products.dart';
import 'package:dabel_sport/page/shop_details.dart';
import 'package:dabel_sport/page/shops.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ClubController.dart';

class SettingController extends GetxController
    with StateMixin<Map<String, dynamic>>, GetSingleTickerProviderStateMixin {
  late List<dynamic> _sports;
  late List<dynamic> _shops;
  late List<dynamic> _days;
  late List<dynamic> _prices;
  late List<dynamic> _categories;

  List<dynamic> get categories => _categories;

  set categories(List<dynamic> value) {
    _categories = value;
  }

  late Map<String, dynamic> _cropRatio;
  late Map<String, dynamic> _limits;
  late String _chatScript;

  String get chatScript => _chatScript;

  set chatScript(String value) {
    _chatScript = value;
  }

  Map<String, dynamic> get limits => _limits;

  set limits(Map<String, dynamic> value) {
    _limits = value;
  }

  Map<String, dynamic> get cropRatio => _cropRatio;

  set cropRatio(Map<String, dynamic> value) {
    _cropRatio = value;
  }

  Helper helper = Get.find<Helper>();

  List<dynamic> get prices => _prices;

  set prices(List<dynamic> value) {
    _prices = value;
  }

  List<dynamic> get days => _days;

  set days(List<dynamic> value) {
    _days = value;
  }

  List<dynamic> get shops => _shops;

  set shops(List<dynamic> value) {
    _shops = value;
  }

  List<dynamic> get sports => _sports;

  set sports(List<dynamic> value) {
    _sports = value;
  }

  late List<dynamic> _provinces;

  bool _isVisibleBottomNavigationBar = true;

  set isVisibleBottomNavigationBar(bool value) {
    _isVisibleBottomNavigationBar = value;
  }

  List<dynamic> get provinces => _provinces;

  get isVisible => _isVisibleBottomNavigationBar;

  set provinces(List<dynamic> value) {
    _provinces = value;
  }

  late List<dynamic> _counties;
  late Map<String, dynamic> _docTypes;
  late int _appVersion;
  late String _appLink;
  Map<String, dynamic> _data = {};
  late String _storageLink;
  late App appInfo;

  int get currentLength => _data.length;

  Map<String, dynamic> get blogs => _data;

  String get storageLink => _storageLink;

  set storageLink(String storageLink) {}

  set data(Map<String, dynamic> value) {
    _data = value;
  }

  List<dynamic> get counties => _counties;

  set counties(List<dynamic> value) {
    _counties = value;
  }

  Map<String, dynamic> get docTypes => _docTypes;

  set docTypes(Map<String, dynamic> value) {
    _docTypes = value;
  }

  int get appVersion => _appVersion;

  set appVersion(int value) {
    _appVersion = value;
  }

  String get appLink => _appLink;

  set appLink(String value) {
    _appLink = value;
  }

  late final ApiProvider apiProvider;
  late final UserController userController;
  late final Style styleController;

  int _currentPageIndex = 2;

  int get currentPageIndex => _currentPageIndex;

  set currentPageIndex(int value) {
    _currentPageIndex = value;
    update();
  }

  SettingController() {
    apiProvider = Get.find<ApiProvider>();
    userController = Get.find<UserController>();
    styleController = Get.find<Style>();
  }

  @override
  onInit() async {
    await getData();
    super.onInit();
  }

  Future<Map<String, dynamic>?> getData({Map<String, dynamic>? params}) async {
    change(null, status: RxStatus.loading());
    final parsedJson = await apiProvider.fetch(
      Variables.LINK_GET_SETTINGS,
      param: params,
    );
    // print(parsedJson);
    if (parsedJson == null) {
      change(null, status: RxStatus.empty());
      return null;
    } else {
      data = parsedJson;
      provinces = _data['provinces'];
      counties = _data['counties'];

      docTypes = _data['doc_types'];
      sports = _data['sports'];
      shops = _data['shops'];
      days = _data['days'];
      prices = _data['prices'];
      cropRatio = _data['crop_ratio'];
      chatScript = _data['chat_script'];
      limits = _data['limits'];
      categories = _data['categories'];

      appInfo =
          App.fromJson(_data['app_info'], await PackageInfo.fromPlatform());

      await userController.getUser();
      change(_data, status: RxStatus.success());
      return _data;
    }
  }

  void goTo(String s) async {
    switch (s) {
      case 'site':
        if (await canLaunchUrl(Uri.parse(appInfo.siteLink)))
          launchUrl(Uri.parse(appInfo.siteLink));
        break;
      case 'email':
        final Uri uri = Uri(
          scheme: 'mailto',
          path: appInfo.emailLink,
          query:
              'subject=${'message'.tr} ${'from'.tr} ${'user'.tr} ${userController.user?.phone}&body=', //add subject and body here
        );
        if (await canLaunchUrl(uri)) launchUrl(uri);
        break;
      case 'telegram':
        if (await canLaunchUrl(Uri.parse(appInfo.telegramLink)))
          launchUrl(Uri.parse(appInfo.telegramLink),
              mode: LaunchMode.externalApplication);
        break;
      case 'instagram':
        if (await canLaunchUrl(Uri.parse(appInfo.instagramLink)))
          launchUrl(Uri.parse(appInfo.instagramLink),
              mode: LaunchMode.externalApplication);
        break;
      case 'whatsapp':
        final Uri uri;
        String phone = appInfo.phone.startsWith('0')
            ? appInfo.phone.replaceFirst('0', '98')
            : appInfo.phone;

        if (Platform.isAndroid)
          uri = Uri.parse("https://wa.me/${phone}"); // new line
        else
          uri = Uri.parse(
              "https://api.whatsapp.com/send?phone=${phone}"); // &text=${'message'.tr} ${'from'.tr} ${'user'.tr} ${userController.user?.phone}

        if (await canLaunchUrl(uri))
          launchUrl(uri, mode: LaunchMode.externalApplication);
        break;
      case 'update':
        if (!showUpdateDialogIfRequired())
          helper.showToast(msg: 'app_is_updated'.tr, status: 'success');
        break;
      case 'contact_us':
        Get.dialog(ContactUsPage(), barrierDismissible: true);
        break;
    }
  }

  String getDocType(type) {
    return docTypes[type].toString();
  }

  String? getDocId(List<dynamic>? docs, String type) {
    var t = getDocType(type);

    final Map<String, dynamic>? doc =
        docs?.firstWhereOrNull((el) => el['type_id'] == t);
    if (doc != null) return "${doc['id']}";
    return null;
  }

  String day(int? day_id) {
    if (day_id == null || day_id == '' || day_id == -1) return '';
    return days[day_id];
  }

  String shop(int? shop_id) {
    var t = shops.firstWhereOrNull((element) => element['id'] == shop_id);

    return t == null ? '' : t['name'];
  }

  String sport(String? sport_id) {
    var t = sports.firstWhereOrNull((element) => element['id'] == sport_id);
    return t == null ? '' : t['name'];
  }

  String province(String? province_id) {
    var t =
        provinces.firstWhereOrNull((element) => element['id'] == province_id);
    return t == null ? '' : t['name'];
  }

  String county(String? county_id) {
    var t = counties.firstWhereOrNull((element) => element['id'] == county_id);
    return t == null ? '' : t['name'];
  }

  String category(String? category_id) {
    var t =
        categories.firstWhereOrNull((element) => element['id'] == category_id);
    return t == null ? '' : t['name'];
  }

  Future<bool> sendActivationCode({required String phone}) async {
    final parsedJson = await apiProvider.fetch(
        Variables.LINK_GET_ACTIVATION_CODE,
        param: {'phone': phone},
        method: 'post');
    if (parsedJson == null) {
      helper.showToast(msg: 'check_network'.tr, status: 'danger');
      return false;
    } else if (parsedJson['errors'] != null) {
      helper.showToast(
          msg: parsedJson['errors']?[parsedJson['errors'].keys.elementAt(0)]
              ?[0],
          status: 'danger');
      return false;
    } else {
      helper.showToast(msg: parsedJson['msg'], status: parsedJson['status']);
      return parsedJson['status'] == 'success' ? true : false;
    }
  }

  CropAspectRatioPreset getAspectRatio(String s) {
    if (cropRatio[s] == null) return CropAspectRatioPreset.original;

    if (cropRatio[s] == 1) return CropAspectRatioPreset.square;
    if (cropRatio[s] == .75) return CropAspectRatioPreset.ratio3x4;

    return CropAspectRatioPreset.original;
  }

  Future<dynamic>? calculateCoupon(
      {required Map<String, String> params}) async {
    final parsedJson = await apiProvider.fetch(Variables.LINK_COUPON_CALCULATE,
        param: params,
        ACCESS_TOKEN: userController.ACCESS_TOKEN,
        method: 'post');

    if (parsedJson != null && parsedJson['errors'] != null) {
      helper.showToast(
          msg: parsedJson['errors']?[parsedJson['errors'].keys.elementAt(0)]
              ?[0],
          status: 'danger');
      return null;
    }
    // print(parsedJson);
    return parsedJson;
  }

  bool isEditable(String? id) {
    return userController.user?.id == id;
  }

  String expireDays(int timestamp) {
    if (timestamp == -1)
      return '0';
    else {
      DateTime currentDate = DateTime.now();
      int milli = timestamp * 1000 - currentDate.millisecondsSinceEpoch;
      if (milli > 0)
        return (milli % 1000 % 60 % 60 % 24).toStringAsFixed(0);
      else
        return '0';
    }
  }

  Future<dynamic>? makePayment({required Map<String, dynamic> params}) async {
    var parsedJson = await apiProvider.fetch(
      Variables.LINK_MAKE_PAYMENT,
      param: params,
      ACCESS_TOKEN: userController.ACCESS_TOKEN,
      method: 'post',
    );

    if (parsedJson != null && parsedJson['errors'] != null) {
      helper.showToast(
          msg: parsedJson['errors']?[parsedJson['errors'].keys.elementAt(0)]
              ?[0],
          status: 'danger');
      return null;
    }
    // print(parsedJson);
    return parsedJson;
  }

  Future<String?> pickAndCrop(
      {required ratio, required MaterialColor colors}) async {
    final ImagePicker _picker = ImagePicker();

    XFile? imageFile = await _picker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      CroppedFile? cp = await ImageCropper().cropImage(
        sourcePath: imageFile.path,

        aspectRatio:
            CropAspectRatio(ratioX: cropRatio['profile'].toDouble(), ratioY: 1),
        // aspectRatioPresets: [
        // settingController.getAspectRatio('profile'),

        // ],

        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'select_crop_section'.tr,
              toolbarColor: colors[500],
              toolbarWidgetColor: Colors.white,
              hideBottomControls: false,
              statusBarColor: colors[500],
              // initAspectRatio: settingController
              //     .getAspectRatio('profile'),
              lockAspectRatio: true),
          IOSUiSettings(
            title: 'select_crop_section'.tr,
          ),
        ],
      );

      if (cp != null) {
        File f = File(cp.path);
        return "image/${cp.path.split('.').last};base64," +
            base64.encode(await f.readAsBytes());
      }
    }
    return null;
  }

  bool showUpdateDialogIfRequired() {
    if (!appInfo.needUpdate)
      return false;
    else {
      Get.dialog(
          Center(
            child: Material(
              color: Colors.transparent,
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                        Radius.circular(styleController.cardBorderRadius))),
                child: Padding(
                  padding: EdgeInsets.all(styleController.cardMargin),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(styleController.cardMargin),
                        child: Text(
                          'new_version_exists'.tr,
                          style: styleController.textBigStyle.copyWith(
                              color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              style: ButtonStyle(
                                  padding: MaterialStateProperty.all(
                                      EdgeInsets.all(
                                          styleController.cardMargin / 2)),
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
                                      MaterialStateProperty.all(Colors.green),
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(
                                          styleController.cardBorderRadius / 2),
                                    ),
                                  ))),
                              onPressed: () async {
                                if (await canLaunchUrl(
                                    Uri.parse(appInfo.appLink)))
                                  launchUrl((Uri.parse(appInfo.appLink)));
                                Get.back();
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check, color: Colors.white),
                                  Text(
                                    'download'.tr,
                                    style: styleController.textMediumStyle
                                        .copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          barrierDismissible: true);
      return true;
    }
  }

  void resolveDeepLink(Uri? deepLink) async {
    if (deepLink == null) return;
    // print('resolving ${deepLink?.pathSegments}');
    List<String>? path = deepLink.pathSegments;
    if (path.length == 0) return;
    if (path.length == 1)
      switch (path[0]) {
        case 'blogs':
          Get.to(BlogsPage());
          break;
        case 'players':
          Get.to(PlayersPage());
          break;
        case 'coaches':
          Get.to(CoachesPage());
          break;
        case 'clubs':
          Get.to(ClubsPage());
          break;
        case 'shops':
          Get.to(ShopsPage());
          break;
        case 'products':
          Get.to(ProductsPage());
          break;
      }
    else if (path.length >= 2)
      switch (path[0]) {
        case 'blog':
          Blog? tmp = await Get.find<BlogController>().find({'id': path[1]});
          if (tmp != null) Get.to(BlogDetails(data: tmp));
          break;
        case 'player':
          Player? tmp =
              await Get.find<PlayerController>().find({'id': path[1]});
          if (tmp != null) Get.to(PlayerDetails(data: tmp));
          break;
        case 'coach':
          Coach? tmp = await Get.find<CoachController>().find({'id': path[1]});
          if (tmp != null) Get.to(CoachDetails(data: tmp));
          break;
        case 'club':
          Club? tmp = await Get.find<ClubController>().find({'id': path[1]});
          if (tmp != null) Get.to(ClubDetails(data: tmp));
          break;
        case 'shop':
          Shop? tmp = await Get.find<ShopController>().find({'id': path[1]});
          if (tmp != null) Get.to(ShopDetails(data: tmp));
          break;
        case 'product':
          Product? tmp =
              await Get.find<ProductController>().find({'id': path[1]});
          if (tmp != null) Get.to(ProductDetails(data: tmp));
          break;
      }
  }
}
