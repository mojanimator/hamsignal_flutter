import 'dart:convert';

import 'package:dabel_sport/controller/APIProvider.dart';
import 'package:dabel_sport/controller/SettingController.dart';
import 'package:dabel_sport/controller/ShopFilterController.dart';
import 'package:dabel_sport/controller/UserController.dart';
import 'package:dabel_sport/helper/helpers.dart';
import 'package:dabel_sport/helper/variables.dart';
import 'package:dabel_sport/model/Shop.dart';
import 'package:get/get.dart';

class ShopController extends GetxController with StateMixin<List<Shop>> {
  List<Shop> _data = [];
  late String _storageLink;
  bool loading = false;

  int get currentLength => _data.length;

  List<Shop> get data => _data;

  String get storageLink => _storageLink;

  set storageLink(String storageLink) {}

  set data(List<Shop> value) {
    _data = value;
  }

  late final Helper helper;
  late final apiProvider;
  late final SettingController settingController;
  late ShopFilterController filterController;
  late final UserController userController;

  ShopController() {
    apiProvider = Get.find<ApiProvider>();
    settingController = Get.find<SettingController>();
    filterController = Get.put(ShopFilterController(parent: this));
    userController = Get.find<UserController>();
    helper = Get.find<Helper>();
  }

  @override
  onInit() {
    getData();
    super.onInit();
  }

  String getProfileLink(List<dynamic>? docs, {  String type='logo'}) {
    var t = settingController.getDocType(type);

    final Map<String, dynamic>? doc =
        docs?.firstWhereOrNull((el) => el['type_id'] == t);
    if (doc != null)
      return "${Variables.LINK_STORAGE}/${doc['type_id']}/${doc['id']}.jpg";
    else
      return Variables.NOIMAGE_LINK;
  }

  String getSport(id) {
    return settingController.sport(id);
  }

  String getProvince(pId) {
    return settingController.province(pId);
  }

  String getCounty(cId) {
    return settingController.county(cId);
  }

  List<String> getSports(List<dynamic>? ids) {
    if (ids == null || ids == []) return [];
    return ids.map<String>((e) => settingController.sport("${e}")).toList();
  }

  List<String> getImageLinks(List docLinks) {
    if (docLinks.length == 0)
      return [];
    else
      return docLinks
          .map((doc) =>
              "${Variables.LINK_STORAGE}/${doc['type_id']}/${doc['id']}.jpg")
          .toList();
  }

  Future<List<Shop>?> getData({Map<String, dynamic>? param}) async {
    loading = true;
    update();
    if (param != null && param['page'] == 'clear') {
      filterController.total = -1;
      filterController.filters['page'] = '0';
      _data.clear();
      change(_data, status: RxStatus.loading());
    }

    if (filterController.total == 0 ||
        (filterController.total > 0 &&
            _data.length >= filterController.total)) {
      loading = false;
      change(_data, status: RxStatus.success());
      return null;
    }
    filterController.filters['page'] =
        (int.parse(filterController.filters['page']) + 1).toString();
    filterController.update();

    Map<String, dynamic> params = {...filterController.filters};

    //add sport,province,county to name search
    if (params['name'] != null && params['name'] != '') {
      if (params['sport'] == null) {
        params['sport'] = settingController.sports
            .where((e) => e['name'].contains(params['name']))
            .map((e) => e['id'])
            .toList();
        if (params['sport'].length == 0)
          params['sport'] = null;
        else
          params['sport'] = json.encode(params['sport']);
      }
      if (params['province'] == null) {
        params['province'] = settingController.provinces
            .where((e) => e['name'].contains(params['name']))
            .map((e) => e['id'])
            .toList();
        if (params['province'].length == 0)
          params['province'] = null;
        else
          params['province'] = json.encode(params['province']);
      }
      if (params['county'] == null) {
        params['county'] = settingController.counties
            .where((e) => e['name'].contains(params['name']))
            .map((e) => e['id'])
            .toList();
        if (params['county'].length == 0)
          params['county'] = null;
        else
          params['county'] = json.encode(params['county']);
      }
    }
    // change(_data, status: RxStatus.loading());
    final parsedJson = await apiProvider.fetch(Variables.LINK_GET_SHOPS,
        param: params, ACCESS_TOKEN: userController.ACCESS_TOKEN);
    // print(parsedJson['data'][0]);
    if (parsedJson == null || parsedJson['data'].length == 0) {
      loading = false;
      if (int.parse(filterController.filters['page']) > 1)
        change(_data, status: RxStatus.success());
      else
        change(_data, status: RxStatus.empty());
      return _data;
    } else {
      filterController.total = parsedJson["total"];

      if (int.parse(params['page']) > 0)
        _data.addAll(
            parsedJson["data"].map<Shop>((el) => Shop.fromJson(el)).toList());
      else
        _data =
            parsedJson["data"].map<Shop>((el) => Shop.fromJson(el)).toList();

      loading = false;
      change(_data, status: RxStatus.success());

      return _data;
    }
  }

  String getLink(int id) {
    return "${Variables.LINK_SHOP}/$id";
  }

  Future<Shop?> find(Map<String, dynamic> params) async {
    final parsedJson = await apiProvider.fetch(Variables.LINK_GET_SHOPS,
        param: params, ACCESS_TOKEN: userController.ACCESS_TOKEN);
// print(parsedJson);
    if (parsedJson != null && parsedJson?['data'].length > 0)
      return Shop.fromJson(parsedJson?['data']?[0]);
    else
      return null;
  }

  Future<bool> sendActivationCode({required String phone}) async {
    return await settingController.sendActivationCode(phone: phone);
  }

  Future<dynamic>? create(
      {required Map<String, dynamic> params,
      Function(double percent)? onProgress}) async {
    var tmp = {...params, 'upload_pending': true};
    tmp.removeWhere((key, value) => key == 'logo');

    // print(tmp);
    //first not send video for verifying other inputs
    var parsedJson = await apiProvider.fetch(
      Variables.LINK_CREATE_SHOP,
      param: tmp,
      ACCESS_TOKEN: userController.ACCESS_TOKEN,
      method: 'post',
    );

    // print(tmp);
    // send video after verifying other inputs
    if (parsedJson != null && parsedJson['resume'] == true) {
      parsedJson = await apiProvider.fetch(Variables.LINK_CREATE_SHOP,
          param: {...params},
          ACCESS_TOKEN: userController.ACCESS_TOKEN,
          method: 'upload',
          onProgress: (percent) =>
              onProgress != null ? onProgress(percent) : null);
    }

    if (parsedJson != null && parsedJson['errors'] != null) {
      helper.showToast(
          msg: parsedJson['errors']?[parsedJson['errors'].keys.elementAt(0)]
              ?.join("\n"),
          status: 'danger');
      return null;
    }
    return parsedJson;
  }

  Future<dynamic> edit(
      {required Map<String, dynamic> params,
      Function(double percent)? onProgress}) async {
    var parsedJson = await apiProvider.fetch(Variables.LINK_EDIT_SHOPS,
        param: params,
        ACCESS_TOKEN: userController.ACCESS_TOKEN,
        method: 'post',
        onProgress: (percent) =>
            onProgress != null ? onProgress(percent) : null);

    if (parsedJson != null && parsedJson['errors'] != null) {
      var msg;
      if (parsedJson['errors'] is List<dynamic>)
        msg = parsedJson['errors']?.join("\n").toString();
      else
        msg = parsedJson['errors'][parsedJson['errors'].keys.elementAt(0)]
            .join("\n");
      helper.showToast(msg: msg, status: 'danger');
      return null;
    }

    return parsedJson;
  }
}
