import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:dabel_adl/controller/APIProvider.dart';
import 'package:dabel_adl/controller/SettingController.dart';
import 'package:dabel_adl/helper/helpers.dart';
import 'package:dabel_adl/helper/variables.dart';
import 'package:dabel_adl/model/User.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../helper/IAPPurchase.dart';
import '../model/Category.dart';
import '../page/shop.dart';
import 'UserFilterController.dart';

class UserController extends GetxController
    with StateMixin<User>, GetTickerProviderStateMixin {
  late final box = GetStorage();
  late final _ACCESS_TOKEN;

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
    await getUser(refresh: true);
    Get.put(IAPPurchase(
        keys: settingController.keys,
        products: settingController.prices,
        plans: settingController.plans));

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
          'auth_mobile': phone,
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
      'auth_mobile': phone,
      'auth_login_password': password,
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
      helper.showToast(
          msg: parsedJson['message'] ?? 'welcome'.tr, status: 'success');
      user = await getUser(refresh: true, withLawyer: true);
      // await getUser();
      change(user, status: RxStatus.success());
      return user;
    }
  }

  Future<dynamic> register({
    required String phone,
    required String code,
    required String fullname,
    required String password,
    required String inviter,
    required bool isLawyer,
  }) async {
    await Helper.getPackageInfo();
    var params = {
      'app_version':
          "${Helper.packageInfo?.version}|${Helper.packageInfo?.buildNumber}",
      'auth_mobile': phone,
      'auth_code': code,
      'auth_fullname': fullname,
      'auth_password': password,
      'marketer_code': inviter,
    };
    if (isLawyer) params["is_lawyer"] = "1";

    final parsedJson = await apiProvider.fetch(Variables.LINK_USER_REGISTER,
        param: params, method: 'post');
// print(parsedJson);
    if (parsedJson == null) {
      User u = User.nullUser();
      change(null, status: RxStatus.empty());
      return null;
    } else if (parsedJson['auth_header'] == null) {
      User u = User.nullUser();
      // change(null, status: RxStatus.error('verify_error'.tr));
      helper.showToast(msg: 'verify_error'.tr, status: 'danger');
      return parsedJson;
    } else {
      user = User.fromJson(parsedJson);
      ACCESS_TOKEN = parsedJson['auth_header'];
      Helper.localStorage(key: 'USER', write: jsonEncode(parsedJson));
      // await getUser();
      change(user, status: RxStatus.success());
      return user;
    }
  }

  Future<User?> getUser({refresh = false, withLawyer = true}) async {
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
        ACCESS_TOKEN: ACCESS_TOKEN,
        method: 'post',
        param: {'with_lawyer': withLawyer});

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

  Future<bool> edit(
      {required Map<String, dynamic> params, String? type}) async {
    final parsedJson = await apiProvider.fetch(
        type == 'password'
            ? Variables.LINK_UPDATE_PASSWORD
            : type == 'lawyer'
                ? Variables.LINK_UPDATE_LAWYER_PROFILE
                : Variables.LINK_UPDATE_PROFILE,
        param: params,
        ACCESS_TOKEN: ACCESS_TOKEN,
        method: 'post');
    if (parsedJson != null && parsedJson['error'] != null) {
      helper.showToast(
          msg: (parsedJson['error'] is String)
              ? parsedJson['error']
              : parsedJson['error']?[parsedJson['error'].keys.elementAt(0)]?[0],
          status: 'danger');
      return false;
    }
    if (parsedJson != null && parsedJson['errors'] != null) {
      helper.showToast(
          msg: parsedJson['errors']?[parsedJson['errors'].keys.elementAt(0)]
              ?[0],
          status: 'danger');
      return false;
    }
    if (parsedJson != null && parsedJson['message'] != null) {
      helper.showToast(
          msg: parsedJson['message'], status: parsedJson['status']);
      return parsedJson['status'] != null && parsedJson['status'] == true;
    }

    return true;
  }

  void logout() {
    ACCESS_TOKEN = '';
    user = null;
    getUser();
  }

  bool hasPlan({bool goShop = false, bool message = false}) {
    DateTime? dt =
        user?.expiredAt != null ? DateTime.tryParse(user!.expiredAt!) : null;

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
        param: {'auth_mobile': phone}, method: 'post');
  }

  Future<dynamic> mark({required Map<String, String> params}) {
    return apiProvider.fetch(Variables.LINK_SET_BOOKMARK,
        method: 'post', ACCESS_TOKEN: ACCESS_TOKEN, param: params);
  }

  Future<bool> sendContact({required Map<String, dynamic> params}) async {
    final res = await apiProvider.fetch(Variables.LINK_SEND_CONTACT,
        method: 'post', ACCESS_TOKEN: ACCESS_TOKEN, param: params);

    if (res != null && res['error'] != null && res['error'].keys.length > 0) {
      helper.showToast(
          msg: res['error'][res['error'].keys.toList()[0]][0],
          status: 'danger');
      return false;
    }

    if (res != null && res['status'] != null) {
      helper.showToast(msg: res['message'], status: res['status']);
      return res['status'] == 'success';
    }
    return true;
  }

// Future<bool> sendActivationCode({required String phone}) async {
//   return await settingController.sendActivationCode(phone: phone);
// }

  List categories() {
    return settingController.categories
        .where((element) => element['related'] == CategoryRelate.Lawyer)
        .map<Map>((e) => {
              ...e,
              ...{
                'selected': user != null &&
                        user!.categories.split(', ').contains(e['title'])
                    ? true
                    : false
              }
            })
        .toList();
  }

  String category(String? category_id) {
    var t = categories()
        .firstWhereOrNull((element) => element['id'] == category_id);
    return t == null ? '' : t['title'];
  }
}
