import 'dart:convert';

import 'package:dabel_sport/controller/APIProvider.dart';
import 'package:dabel_sport/controller/ClubFilterController.dart';
import 'package:dabel_sport/controller/SettingController.dart';
import 'package:dabel_sport/controller/UserController.dart';
import 'package:dabel_sport/helper/helpers.dart';
import 'package:dabel_sport/helper/variables.dart';
import 'package:dabel_sport/model/Club.dart';
import 'package:get/get.dart';

class ClubController extends GetxController with StateMixin<List<Club>> {
  List<Club> _data = [];
  late String _storageLink;
  bool loading = false;

  int get currentLength => _data.length;

  List<Club> get data => _data;

  String get storageLink => _storageLink;

  set storageLink(String storageLink) {}

  set data(List<Club> value) {
    _data = value;
  }

  late final apiProvider;
  late final SettingController settingController;
  late ClubFilterController filterController;
  late final UserController userController;
  late final Helper helper;

  ClubController() {
    apiProvider = Get.find<ApiProvider>();
    settingController = Get.find<SettingController>();
    filterController = ClubFilterController(parent: this);
    userController = Get.find<UserController>();
    helper = Get.find<Helper>();
  }

  @override
  onInit() {
    getData();
    super.onInit();
  }

  String getProfileLink(List<dynamic>? docs, {editable: false}) {
    var t = settingController.getDocType(editable ? 'license' : 'club');

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

  String? getVideoLink(List<dynamic>? docs) {
    var t = settingController.getDocType('video');
    final Map<String, dynamic>? doc =
        docs?.firstWhereOrNull((el) => el['type_id'] == t);
    if (doc != null)
      return "${Variables.LINK_STORAGE}/${doc['type_id']}/${doc['id']}.mp4";
    else
      return null;
  }

  List<String> getSports(List<dynamic>? times) {
    if (times == null || times == []) return [];
    return times
        .map<String>((e) => settingController.sport("${e['id']}"))
        .toList();
  }

  Future<List<Club>?> getData({
    Map<String, dynamic>? param,
  }) async {
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
    final parsedJson = await apiProvider.fetch(Variables.LINK_GET_CLUBS,
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
            parsedJson["data"].map<Club>((el) => Club.fromJson(el)).toList());
      else
        _data =
            parsedJson["data"].map<Club>((el) => Club.fromJson(el)).toList();

      loading = false;
      change(_data, status: RxStatus.success());

      return _data;
    }
  }

  List<String> getImageLinks(List docLinks, {  bool editable=false}) {
    var t = settingController.getDocType(  'club');
    docLinks.sort((a, b) => b['type_id'].compareTo(a['type_id']));
    if (docLinks.length == 0)
      return [];
    else
      return docLinks.where((e)=> editable? e['type_id']==t:true)
          .map((doc) =>
              "${Variables.LINK_STORAGE}/${doc['type_id']}/${doc['id']}.jpg")
          .toList();
  }

  String getLink(int id) {
    return "${Variables.LINK_CLUB}/$id";
  }

  Future<Club?> find(Map<String, dynamic> params) async {
    final parsedJson = await apiProvider.fetch(Variables.LINK_GET_CLUBS,
        param: params, ACCESS_TOKEN: userController.ACCESS_TOKEN);
// print(parsedJson);
    if (parsedJson != null && parsedJson?['data'].length > 0)
      return Club.fromJson(parsedJson?['data']?[0]);
    else
      return null;
  }

  Future<bool> sendActivationCode({required String phone}) async {
    return await settingController.sendActivationCode(phone: phone);
  }

  Future<dynamic>? create(
      {required Map<String, dynamic> params,
      Function(double percent)? onProgress}) async {
    params['times'] = json.encode(params['times']);
    var tmp = {...params, 'upload_pending': true};
    tmp.removeWhere((key, value) => key == 'images');
    tmp.removeWhere((key, value) => key == 'license');
    // print(tmp);
    //first not send video for verifying other inputs
    var parsedJson = await apiProvider.fetch(
      Variables.LINK_CREATE_CLUB,
      param: tmp,
      ACCESS_TOKEN: userController.ACCESS_TOKEN,
      method: 'post',
    );

    // print(tmp);
    // send video after verifying other inputs
    if (parsedJson != null && parsedJson['resume'] == true) {
      params['images[]'] = params['images'].where((e) => e != '').toList();
      params['images'] = null;

      parsedJson = await apiProvider.fetch(Variables.LINK_CREATE_CLUB,
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
    var parsedJson = await apiProvider.fetch(Variables.LINK_EDIT_CLUBS,
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
