import 'dart:convert';

import 'package:hamsignal/controller/APIProvider.dart';
import 'package:hamsignal/controller/SignalFilterController.dart';
import 'package:hamsignal/controller/SettingController.dart';
import 'package:hamsignal/controller/UserController.dart';
import 'package:hamsignal/helper/helpers.dart';
import 'package:hamsignal/helper/variables.dart';
import 'package:hamsignal/model/Signal.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../model/Category.dart';

class SignalController extends GetxController with StateMixin<List<Signal>> {
  List<Signal> _data = [];
  late String _storageLink;
  bool loading = false;

  int get currentLength => _data.length;

  List<Signal> get data => _data;

  String get storageLink => _storageLink;

  set storageLink(String storageLink) {}

  set data(List<Signal> value) {
    _data = value;
  }

  late final apiProvider;
  late final SettingController settingController;
  late SignalFilterController filterController;
  late final UserController userController;
  late final Helper helper;

  SignalController() {
    apiProvider = Get.find<ApiProvider>();
    settingController = Get.find<SettingController>();
    filterController = SignalFilterController(parent: this);
    userController = Get.find<UserController>();
    helper = Get.find<Helper>();
  }

  @override
  onInit() {
    // getData();
    super.onInit();
  }

  String getProfileLink(List<dynamic>? docs, {editable: false}) {
    var t = settingController.getDocType(editable ? 'license' : 'Signal');

    final Map<String, dynamic>? doc =
        docs?.firstWhereOrNull((el) => el['type_id'] == t);
    if (doc != null)
      return "${Variables.LINK_STORAGE}/${doc['type_id']}/${doc['id']}.jpg";
    else
      return Variables.NO_IMAGE_LINK;
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

  Future<List<Signal>?> getData({
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
    // print(params);
    //add sport,province,county to name search
    if (params['search'] != null && params['search'] != '') {}
    // change(_data, status: RxStatus.loading());
    final parsedJson = await apiProvider.fetch(Variables.LINK_GET_SIGNALS,
        param: params, ACCESS_TOKEN: userController.ACCESS_TOKEN);
    // print(parsedJson);
    if (parsedJson == null ||
        parsedJson['data'] == null ||
        parsedJson['data'].length == 0) {
      loading = false;
      if (int.parse(filterController.filters['page']) > 1)
        change(_data, status: RxStatus.success());
      else
        change(_data, status: RxStatus.empty());
      return _data;
    } else {
      filterController.total = parsedJson["total"];

      if (int.parse(params['page']) > 0)
        _data.addAll(parsedJson["data"]
            .map<Signal>((el) => Signal.fromJson(el))
            .toList());
      else
        _data = parsedJson["data"]
            .map<Signal>((el) => Signal.fromJson(el))
            .toList();

      loading = false;
      change(_data, status: RxStatus.success());

      return _data;
    }
  }

  List<String> getImageLinks(List docLinks, {bool editable = false}) {
    var t = settingController.getDocType('Signal');
    docLinks.sort((a, b) => b['type_id'].compareTo(a['type_id']));
    if (docLinks.length == 0)
      return [];
    else
      return docLinks
          .where((e) => editable ? e['type_id'] == t : true)
          .map((doc) =>
              "${Variables.LINK_STORAGE}/${doc['type_id']}/${doc['id']}.jpg")
          .toList();
  }

  String getLink(int id) {
    return "";
  }

  Future<Signal?> find(Map<String, dynamic> params) async {
    String link = Variables.LINK_GET_SIGNALS;
    if (params['id'] != null) link = "${link}/${params['id']}";
    final parsedJson = await apiProvider.fetch(link,
        param: params, ACCESS_TOKEN: userController.ACCESS_TOKEN);

    if (parsedJson != null)
      return Signal.fromJson(parsedJson);
    else
      return null;
  }

  Future<bool> sendActivationCode({required String phone}) async {
    return await settingController.sendActivationCode(phone: phone);
  }

  Future<dynamic> mark(dynamic id) {
    return userController.mark(params: {
      'for_type': "${settingController.types['signal']}",
      'for_id': "$id"
    });
  }

  List get categories => settingController.categories.toList();

  String get admin =>
      settingController.admins.firstWhereOrNull((e) => e['name']);

  String categoryId(String? category_name) {
    var t = categories
        .firstWhereOrNull((element) => "${element['name']}" == category_name);
    return t == null ? '' : "${t['id']}";
  }

  String categoryName(String? category_id) {
    var t = categories
        .firstWhereOrNull((element) => "${element['id']}" == category_id);
    return t == null ? '' : t['name'];
  }

  bookmark(String id) {}

  goTo(String link) async {
    if (await canLaunchUrlString(link))
      launchUrlString(link, mode: LaunchMode.externalApplication);
  }
}
