import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dabel_adl/controller/APIProvider.dart';
import 'package:dabel_adl/controller/ContentController.dart';
import 'package:dabel_adl/controller/LinkController.dart';
import 'package:dabel_adl/controller/UserController.dart';
import 'package:dabel_adl/helper/IAPPurchase.dart';
import 'package:dabel_adl/helper/helpers.dart';
import 'package:dabel_adl/helper/styles.dart';
import 'package:dabel_adl/helper/variables.dart';
import 'package:dabel_adl/model/App.dart';
import 'package:dabel_adl/model/Club.dart';
import 'package:dabel_adl/model/Link.dart';
import 'package:dabel_adl/model/Player.dart';
import 'package:dabel_adl/model/Product.dart';
import 'package:dabel_adl/model/Shop.dart';
import 'package:dabel_adl/page/contact_us.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../model/Content.dart';
import '../page/content_details.dart';
import '../page/contents.dart';
import 'APIController.dart';
import 'AnimationController.dart';

class SettingController extends APIController<Map<String, dynamic>>
    with GetSingleTickerProviderStateMixin {
  late List<dynamic> shops;
  late List<dynamic> days;
  late List<dynamic> years;
  late List<dynamic> prices;
  late List<dynamic> plans;
  late Map<String, dynamic> _keys;
  String? payment;

  late Map<String, dynamic> cropRatio = {'profile': 1.0, 'document': null};
  late Map<String, dynamic> _limits;
  late String _chatScript;

  String get chatScript => _chatScript;

  set chatScript(String value) {
    _chatScript = value;
  }

  Map<String, dynamic> get limits => {'club': 1};

  set limits(Map<String, dynamic> value) {
    _limits = value;
  }

  Helper helper = Get.find<Helper>();

  bool _isVisibleBottomNavigationBar = true;

  set isVisibleBottomNavigationBar(bool value) {
    _isVisibleBottomNavigationBar = value;
  }

  get isVisible => _isVisibleBottomNavigationBar;

  Map<String, dynamic> get keys => _keys;

  set keys(Map<String, dynamic> value) {
    _keys = value;
  }

  late List<dynamic> categories;
  late List<dynamic> provinces;
  late List<dynamic> counties;
  late Map<String, dynamic> dates;
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

  late TabController bottomSheetController;

  SettingController() {
    apiProvider = Get.find<ApiProvider>();

    styleController = Get.find<Style>();

    bottomSheetController =
        TabController(length: 5, initialIndex: currentPageIndex, vsync: this);
    bottomSheetController.addListener(() {
      // settingController.currentPageIndex =bottomSheetController.index;
    });
  }

  @override
  onInit() async {
    await getData(params: {'market': Variables.MARKET});
    super.onInit();
  }

  Future<Map<String, dynamic>?> getData({Map<String, dynamic>? params}) async {
    change(null, status: RxStatus.loading());
    final parsedJson = await apiProvider.fetch(Variables.LINK_GET_SETTINGS,
        param: params, tryReminded: ApiProvider.maxRetry);
    // print(parsedJson);
    if (parsedJson == null) {
      change(null, status: RxStatus.empty());
      return null;
    } else {
      data = parsedJson;
      keys = _data['keys'];
      prices = _data['prices'];
      plans = _data['plans'];
      provinces = _data['provinces'];
      counties = _data['counties'];
      categories = _data['categories'];
      dates = _data['dates'];
      payment = _data['payment'];
      appInfo = App.fromJson(
          _data['app_info'] ?? {}, await PackageInfo.fromPlatform());

      Variables.LINK_SEND_ERROR = appInfo.errorLink != ''
          ? appInfo.errorLink
          : Variables.LINK_SEND_ERROR;
      if (!Get.isRegistered<UserController>())
        userController = Get.put(UserController());
      else
        Get.find<IAPPurchase>().init();
      change(_data, status: RxStatus.success());
      return _data;
    }
  }

  void goTo(String s) async {
    switch (s) {
      case 'your_comments':
        if (await canLaunchUrlString(appInfo.marketLink))
          launchUrlString(appInfo.marketLink,
              mode: LaunchMode.externalApplication);
        break;
      case 'site':
        if (await canLaunchUrl(Uri.parse(appInfo.siteLink)))
          launchUrl(Uri.parse(appInfo.siteLink),
              mode: LaunchMode.externalApplication);
        break;
      case 'email':
        final Uri uri = Uri(
          scheme: 'mailto',
          path: appInfo.emailLink,
          query:
              'subject=${'message'.tr} ${'from'.tr} ${'user'.tr} ${userController.user?.mobile}&body=', //add subject and body here
        );
        if (await canLaunchUrl(uri))
          launchUrl(uri, mode: LaunchMode.externalApplication);
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
    return "";
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

  String province(dynamic province_id) {
    var t = provinces
        .firstWhereOrNull((element) => "${element['id']}" == "$province_id");

    return t == null ? '' : t['title'];
  }

  String county(dynamic county_id) {
    var t = counties
        .firstWhereOrNull((element) => "${element['id']}" == "$county_id");
    return t == null ? '' : t['title'];
  }

  Future<bool> sendActivationCode({required String phone}) async {
    final parsedJson = await apiProvider.fetch(
        Variables.LINK_GET_ACTIVATION_CODE,
        param: {'phone': phone},
        method: 'post');
    // return true;
    // print(parsedJson);
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

  String expireDays(int timestamp) {
    if (timestamp == -1)
      return '0';
    else {
      DateTime currentDate = DateTime.now();
      int milli = timestamp * 1000 - currentDate.millisecondsSinceEpoch;

      if (milli > 0)
        return ((((milli / 1000) / 60) / 60) / 24).toStringAsFixed(0);
      else
        return '0';
    }
  }

  Future<String?> pickAndCrop(
      {required ratio, required MaterialColor colors}) async {
    final ImagePicker _picker = ImagePicker();

    XFile? imageFile = await _picker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      CroppedFile? cp = await ImageCropper().cropImage(
        sourcePath: imageFile.path,

        aspectRatio: ratio != null
            ? CropAspectRatio(ratioX: ratio.toDouble(), ratioY: 1)
            : null,
        // CropAspectRatio(ratioX:ratio cropRatio['profile'].toDouble(), ratioY: 1),
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
              initAspectRatio: ratio != null
                  ? CropAspectRatioPreset.square
                  : CropAspectRatioPreset.originalFa,

              // initAspectRatio: settingController
              //     .getAspectRatio('profile'),
              lockAspectRatio: ratio != null),
          IOSUiSettings(
            title: 'select_crop_section'.tr,
          ),
        ],
      );

      if (cp != null) {
        File f = File(cp.path);
        return cp.path;
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
                                    Uri.parse(appInfo.marketLink)))
                                  launchUrl((Uri.parse(appInfo.marketLink)),
                                      mode: LaunchMode.externalApplication);
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

    List<String>? path = deepLink.pathSegments;
    if (path.length == 0) return;
    if (path.length == 1) {
      var model = path[0];
      switch (model) {
        case 'contents':
          Get.to(ContentsPage());
          break;
      }
    } else if (path.length >= 2) {
      var model = path[0];
      var id = path[1];

      if (path.length == 4 && path.contains('panel') && path.contains('edit')) {
        model = path[1];
        id = path[3];
      }
      switch (model) {
        case 'content':
          Content? tmp = await Get.find<ContentController>().find({'id': id});
          if (tmp != null) Get.to(ContentDetails(data: tmp));
          break;
      }
    }
  }

  Future<dynamic> clearImageCache({required String url}) async {
    // apiProvider.fetch(url, method: 'get', headers: {
    //   'Pragma': 'no-cache',
    //   // 'Cache-Control': 'no-cache, no-store',
    //   'X-LiteSpeed-Purge': url,
    //   'Cache-Control': 'max-age=0, no-cache, no-store',
    // });
    return await CachedNetworkImage.evictFromCache(url);
  }

  String category(category_id) {
    var t = categories
        .firstWhereOrNull((element) => "${element['id']}" == "$category_id");
    return t == null ? '' : t['title'];
  }

  @override
  Map<String, dynamic> filters = {};
}
