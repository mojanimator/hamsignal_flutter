import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:hamsignal/controller/APIProvider.dart';
import 'package:hamsignal/controller/SettingController.dart';
import 'package:hamsignal/helper/helpers.dart';
import 'package:hamsignal/helper/variables.dart';
import 'package:hamsignal/model/User.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pushpole/pushpole.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../helper/IAPPurchase.dart';
import '../model/Category.dart';
import '../page/shop.dart';
import 'UserFilterController.dart';

class UserController extends GetxController
    with StateMixin<User>, GetTickerProviderStateMixin {
  late final box = GetStorage();
  var _ACCESS_TOKEN;

  late final Helper helper;
  late final SettingController settingController;
  late UserFilterController filterController;
  User? user;
  Map<String, dynamic> _userInfo = {};
  List<dynamic> userShops = [];
  Map<String, dynamic> userRef = {};

  Map<String, dynamic> get userInfo => _userInfo;

  set userInfo(Map<String, dynamic> value) {
    _userInfo = value;
  }

  get ACCESS_TOKEN => _ACCESS_TOKEN.val;

  set ACCESS_TOKEN(value) {
    _ACCESS_TOKEN.val = value;
  }

  late final ApiProvider apiProvider;
  ScrollPhysics parentScrollPhysics = BouncingScrollPhysics();

  ScrollPhysics childScrollPhysics = NeverScrollableScrollPhysics();

  ScrollController parentScrollController = ScrollController();
  ScrollController childScrollController = ScrollController();

  late TabController tabControllerProfile;
  final profileTabs = [
    Tab(text: 'user_info'.tr),
    Tab(text: 'user_lawyer_info'.tr),
  ];

  late TabController tabControllerShop;

  UserController() {
    _ACCESS_TOKEN = ReadWriteValue('ACCESS_TOKEN', '', () => box);

    // _ACCESS_TOKEN.val = '';
    apiProvider = Get.find<ApiProvider>();
    helper = Get.find<Helper>();
    settingController = Get.find<SettingController>();
    filterController = Get.put(UserFilterController(this));

    tabControllerShop = TabController(length: 2, vsync: this, initialIndex: 0);
    tabControllerProfile =
        TabController(length: 2, vsync: this, initialIndex: 0);
    tabControllerProfile.addListener(() {
      parentScrollController.animateTo(0,
          duration: Duration(milliseconds: 700), curve: Curves.ease);
      update();
    });
  }

// final username = ''.val('username');
// final age = 0.val('age');
// final price = 1000.val('price', getBox: _otherBox);

// or

  @override
  void onInit() async {
    // ACCESS_TOKEN = '';
    // await getUser(refresh: true);

    super.onInit();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void updateAge() {
    // final age = 0.val('age');
    // or
    final age = ReadWriteValue('age', 0 /*, () => box*/);

    age.val = 1; // will save to box
    final realAge = age.val; // will read from box
  }

  Future<dynamic> preAuth({
    required String phone,
  }) async {
    return await apiProvider.fetch(Variables.LINK_PRE_AUTH,
        param: {
          'phone': phone,
        },
        method: 'post',
        tryReminded: ApiProvider.maxRetry);
  }

  Future<dynamic> login({
    required String phone,
    required String password,
  }) async {
    await Helper.getPackageInfo();
    final parsedJson = await apiProvider
        .fetch(Variables.LINK_USER_LOGIN, method: 'post', param: {
      'phone': phone,
      'password': password,
      'push_id': await PushPole.getId(),
      'app_version':
          "${Helper.packageInfo?.version}|${Helper.packageInfo?.buildNumber}"
    });
// print(parsedJson);
    if (parsedJson == null) {
      User u = User.nullUser();
      change(null, status: RxStatus.empty());
      return null;
    } else if (parsedJson['auth_header'] == null) {
      User u = User.nullUser();
      // change(null, status: RxStatus.error('verify_error'.tr));
      helper.showToast(
          msg: parsedJson['message'] ?? 'verify_error'.tr, status: 'danger');
      return parsedJson;
    } else {
      // user = User.fromJson(parsedJson);
      ACCESS_TOKEN = parsedJson['auth_header'];
      Helper.localStorage(key: 'USER', write: jsonEncode(parsedJson));
      Helper.localStorage(
          key: 'ACCESS_TOKEN', write: parsedJson['auth_header']);
      helper.showToast(
          msg: parsedJson['message'] ?? 'welcome'.tr, status: 'success');
      user = await getUser();
      // await getUser();
      change(user, status: RxStatus.success());
      return user;
    }
  }

  Future<dynamic> register({
    required String phone,
    required String code,
    required String email,
    required String fullname,
    required String username,
    required String password,
    required String passwordVerify,
    required String inviter,
  }) async {
    await Helper.getPackageInfo();
    var params = {
      'app_version':
          "${Helper.packageInfo?.version}|${Helper.packageInfo?.buildNumber}",
      'phone': phone,
      'phone_verify': code,
      'fullname': fullname,
      'username': username,
      'email': email,
      'password': password,
      'password_verify': passwordVerify,
      'marketer_code': inviter,
      'push_id': await PushPole.getId(),
    };

    final parsedJson = await apiProvider.fetch(Variables.LINK_USER_REGISTER,
        param: params, method: 'post');
// print(parsedJson);

    if (parsedJson == null) {
      User u = User.nullUser();
      change(null, status: RxStatus.empty());
      return null;
    } else if (parsedJson['error'] != null) {
      helper.showToast(
          msg: (parsedJson['error'] is String)
              ? parsedJson['error']
              : parsedJson['error']?[parsedJson['error'].keys.elementAt(0)]?[0],
          status: 'danger');
      return {'status': 'error'};
    } else if (parsedJson['token'] == null) {
      User u = User.nullUser();
      // change(null, status: RxStatus.error('verify_error'.tr));
      helper.showToast(msg: 'verify_error'.tr, status: 'danger');
      return parsedJson;
    } else {
      user = User.fromJson(parsedJson);
      ACCESS_TOKEN = parsedJson['token'];
      Helper.localStorage(key: 'USER', write: jsonEncode(parsedJson));
      // await getUser();
      helper.showToast(
          msg: parsedJson['message'] ?? 'welcome'.tr, status: 'success');
      change(user, status: RxStatus.success());
      return user;
    }
  }

  Future<User?> getUser({refresh = false}) async {
    if (user != null && !refresh) {
      change(user, status: RxStatus.success());
      await filterController.initFilters();
      return user;
    }
    var u = '';
    if (refresh)
      Helper.localStorage(key: 'USER', write: '');
    else
      u = Helper.localStorage(key: 'USER', def: '');

    if (u != '') {
      user = User.fromJson(jsonDecode(u));
      await filterController.initFilters();
      change(user, status: RxStatus.success());
      return user;
    }
    final parsedJson = await apiProvider.fetch(Variables.LINK_GET_USER_INFO,
        ACCESS_TOKEN: ACCESS_TOKEN, method: 'get', param: {});

    if (parsedJson == null) {
      //internet error
      change(null, status: RxStatus.empty());
      return null;
    } else if (parsedJson['status'] == null ||
        parsedJson['status'] != 'success') {
      helper.showToast(
          msg: parsedJson['message'] ?? 'token_error'.tr, status: 'danger');
      change(null, status: RxStatus.error('token_error'.tr));
      return null;
    } else {
      user = User.fromJson(parsedJson);

      await filterController.initFilters();
      change(user, status: RxStatus.success());
      return user;
    }
  }

  Future edit({required Map<String, dynamic> params, String? type}) async {
    final parsedJson = await apiProvider.fetch(
            type == 'password'
                ? Variables.LINK_UPDATE_PASSWORD
                : type == 'avatar'
                    ? Variables.LINK_UPDATE_AVATAR
                    : type == 'email'
                        ? Variables.LINK_UPDATE_EMAIL
                        : Variables.LINK_UPDATE_PROFILE,
            param: params,
            ACCESS_TOKEN: ACCESS_TOKEN,
            method: 'post') ??
        {};
    if (parsedJson['error'] != null) {
      helper.showToast(
          msg: (parsedJson['error'] is String)
              ? parsedJson['error']
              : parsedJson['error']?[parsedJson['error'].keys.elementAt(0)]?[0],
          status: 'danger');
      return {'status': 'error'};
    }
    if (parsedJson['errors'] != null) {
      helper.showToast(
          msg: parsedJson['errors']?[parsedJson['errors'].keys.elementAt(0)]
              ?[0],
          status: 'danger');
      return {'status': 'error'};
    }
    if (parsedJson['message'] != null) {
      helper.showToast(
          msg: parsedJson['message'], status: parsedJson['status']);
      return parsedJson['status'] != null && parsedJson['status'] == 'success'
          ? parsedJson
          : {'status': 'error'};
    }

    return {'status': 'error'};
  }

  void logout() {
    ACCESS_TOKEN = '';
    user = null;
    getUser();
  }

  bool hasPlan({bool goShop = false, bool message = false}) {
    DateTime? dt =
        user?.expiresAt != null ? DateTime.tryParse(user!.expiresAt!) : null;

    bool res = ACCESS_TOKEN == '' ||
        dt == null ||
        ((dt.millisecondsSinceEpoch - DateTime.now().millisecondsSinceEpoch) <=
            0);

    if (res) {
      if (goShop) Get.to(ShopPage());
      if (message)
        helper.showToast(msg: 'please_buy_plan'.tr, status: 'danger');
    }

    return !res;
  }

  recoverPassword({required String phone}) async {
    return await apiProvider.fetch(Variables.LINK_USER_FORGET_PASSWORD,
        param: {'phone': phone}, method: 'post');
  }

  Future<dynamic> mark({required Map<String, String> params}) async {
    final res = await apiProvider.fetch(Variables.LINK_SET_BOOKMARK,
        method: 'post', ACCESS_TOKEN: ACCESS_TOKEN, param: params);
    if (res != null && res['message'] != null)
      helper.showToast(msg: res['message'], status: 'success');
    return res;
  }

// Future<bool> sendActivationCode({required String phone}) async {
//   return await settingController.sendActivationCode(phone: phone);
// }

  List categories() {
    return settingController.categories.toList();
  }

  String category(String? category_id) {
    var t = categories()
        .firstWhereOrNull((element) => element['id'] == category_id);
    return t == null ? '' : t['title'];
  }

  Future<bool> getTelegramConnectLink() async {
    final res = await apiProvider.fetch(Variables.LINK_TELEGRAM_CONNECT,
        method: 'post', ACCESS_TOKEN: ACCESS_TOKEN);

    if (res == null || res['status'] != null && res['status'] != 'success')
      return false;
    if (res['status'] != null &&
        res['status'] == 'success' &&
        res['url'] != null) {
      if (await canLaunchUrlString(res['url']))
        launchUrlString(res['url'], mode: LaunchMode.externalApplication);
    }

    return true;
  }

  Future buy(Map<String, String> params) async {
    final parsedJson = await apiProvider.fetch(Variables.LINK_BUY,
        param: params, ACCESS_TOKEN: ACCESS_TOKEN, method: 'post');
    return parsedJson;
  }

  Future<dynamic>? calculateCoupon(
      {required Map<String, String> params}) async {
    final parsedJson = await apiProvider.fetch(Variables.LINK_COUPON_CALCULATE,
        param: params, ACCESS_TOKEN: ACCESS_TOKEN, method: 'post');

    if (parsedJson == null || parsedJson['error'] != null) {
      helper.showToast(
          msg: parsedJson?['error'] ?? 'request_error'.tr, status: 'danger');
      return {};
    }
    helper.showToast(msg: 'coupon_accepted'.tr, status: 'success');
    // print(parsedJson);
    return parsedJson;
  }
}
