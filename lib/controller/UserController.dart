import 'dart:async';

import 'package:dabel_sport/controller/APIProvider.dart';
import 'package:dabel_sport/controller/SettingController.dart';
import 'package:dabel_sport/helper/helpers.dart';
import 'package:dabel_sport/helper/variables.dart';
import 'package:dabel_sport/model/user.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class UserController extends GetxController with StateMixin<User> {
  late final box = GetStorage();
  late final _ACCESS_TOKEN;
  late final Helper helper;
  late final SettingController settingController;
  User? _user;
  Map<String, dynamic> _userInfo = {};
  List<dynamic> userShops = [];
  Map<String, dynamic> _userRef = {};

  Map<String, dynamic> get userRef => _userRef;

  set userRef(Map<String, dynamic> value) {
    _userRef = value;
  }

  Map<String, dynamic> get userInfo => _userInfo;

  set userInfo(Map<String, dynamic> value) {
    _userInfo = value;
  }

  User? get user => _user;

  set user(User? value) {
    _user = value;
  }

  get ACCESS_TOKEN => _ACCESS_TOKEN.val;

  set ACCESS_TOKEN(value) {
    _ACCESS_TOKEN.val = value;
  }

  late final ApiProvider apiProvider;

  UserController() {
    _ACCESS_TOKEN = ReadWriteValue('ACCESS_TOKEN', '', () => box);
    apiProvider = Get.find<ApiProvider>();
    helper = Get.find<Helper>();
  }

  // final username = ''.val('username');
  // final age = 0.val('age');
  // final price = 1000.val('price', getBox: _otherBox);

  // or

  @override
  void onInit() async {
    // ACCESS_TOKEN = '';
    await getUser();
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

  Future<dynamic> loginOrRegister({
    required String phone,
    required String code,
    String? ref_code,
  }) async {
    final parsedJson = await apiProvider.fetch(Variables.LINK_LOGIN,
        param: {'phone': phone, 'phone_verify': code, 'ref_code': ref_code});
// print(parsedJson);
    if (parsedJson == null) {
      User u = User.nullUser();
      change(null, status: RxStatus.empty());
      return null;
    } else if (parsedJson['access_token'] == null) {
      User u = User.nullUser();
      // change(null, status: RxStatus.error('verify_error'.tr));
      helper.showToast(msg: 'verify_error'.tr, status: 'danger');
      return parsedJson;
    } else {
      // user = User.fromJson(parsedJson['user']);
      ACCESS_TOKEN = parsedJson['access_token'];
      await getUser();
      // change(user, status: RxStatus.success());
      return user;
    }
  }

  Future<User?> getUser() async {
    if (_user != null) {
      change(_user, status: RxStatus.success());
      return _user;
    }

    final parsedJson = await apiProvider.fetch(Variables.LINK_GET_USER,
        ACCESS_TOKEN: ACCESS_TOKEN);
    // print(parsedJson?['user']['expires_at']);
    if (parsedJson == null) {
      //internet error
      change(null, status: RxStatus.empty());
      return null;
    } else if (parsedJson['user'] == null) {
      change(null, status: RxStatus.error('token_error'.tr));
      return null;
    } else {
      _user = User.fromJson(parsedJson['user']);
      userInfo = parsedJson['info'];
      userShops = parsedJson['info']?['shops'];
      //

      userRef = parsedJson['ref'].length > 0
          ? parsedJson['ref'][0]
          : {
              'bestan': {'count': 0, 'sum': 0}
            };
      change(_user, status: RxStatus.success());
      return _user;
    }
  }

  Future<bool> edit({required Map<String, String> params}) async {
    final parsedJson = await apiProvider.fetch(Variables.LINK_EDIT_USER,
        param: params, ACCESS_TOKEN: ACCESS_TOKEN, method: 'post');
    if (parsedJson != null && parsedJson['errors'] != null) {
      helper.showToast(
          msg: parsedJson['errors']?[parsedJson['errors'].keys.elementAt(0)]
              ?[0],
          status: 'error');
      return false;
    }
    // print(parsedJson!['errors']);
    return true;
  }

  void logout() {
    ACCESS_TOKEN = '';
    user = null;
    getUser();
  }

// Future<bool> sendActivationCode({required String phone}) async {
//   return await settingController.sendActivationCode(phone: phone);
// }
}
