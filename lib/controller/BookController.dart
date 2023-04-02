import 'dart:convert';
import 'dart:io';

import 'package:dabel_adl/controller/APIProvider.dart';
import 'package:dabel_adl/controller/BookFilterController.dart';
import 'package:dabel_adl/controller/SettingController.dart';
import 'package:dabel_adl/controller/UserController.dart';
import 'package:dabel_adl/helper/helpers.dart';
import 'package:dabel_adl/helper/variables.dart';
import 'package:dabel_adl/model/Book.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../model/Category.dart';

class BookController extends GetxController with StateMixin<List<Book>> {
  List<Book> _data = [];
  late String _storageLink;
  bool loading = false;

  int get currentLength => _data.length;

  List<Book> get data => _data;

  String get storageLink => _storageLink;

  set storageLink(String storageLink) {}

  set data(List<Book> value) {
    _data = value;
  }

  late final apiProvider;
  late final SettingController settingController;
  late BookFilterController filterController;
  late final UserController userController;
  late final Helper helper;

  BookController() {
    apiProvider = Get.find<ApiProvider>();
    settingController = Get.find<SettingController>();
    filterController = BookFilterController(parent: this);
    userController = Get.find<UserController>();
    helper = Get.find<Helper>();
  }

  @override
  onInit() {
    // getData();
    super.onInit();
  }

  List get categories => settingController.categories
      .where((element) => element['related'] == CategoryRelate.Books)
      .toList();

  String category(String? category_id) {
    var t =
        categories.firstWhereOrNull((element) => element['id'] == category_id);
    return t == null ? '' : t['title'];
  }

  String getProfileLink(List<dynamic>? docs, {editable: false}) {
    var t = settingController.getDocType(editable ? 'license' : 'Book');

    final Map<String, dynamic>? doc =
        docs?.firstWhereOrNull((el) => el['type_id'] == t);
    if (doc != null)
      return "${Variables.LINK_STORAGE}/${doc['type_id']}/${doc['id']}.jpg";
    else
      return Variables.NOIMAGE_LINK;
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

  Future<List<Book>?> getData({
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

    if (params['province_id'] != null && params['province_id'] != '') {
      params['province'] = settingController.province(params['province_id']);
    }
    if (params['county_id'] != null && params['county_id'] != '') {
      params['county'] = settingController.county(params['county_id']);
    }
    // print(params);
    // change(_data, status: RxStatus.loading());
    final parsedJson = await apiProvider.fetch(Variables.LINK_GET_BOOKS,
        param: params, ACCESS_TOKEN: userController.ACCESS_TOKEN);
// print(parsedJson );
    if (parsedJson == null ||
        parsedJson['books'] == null ||
        parsedJson['books'].length == 0) {
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
            parsedJson["books"].map<Book>((el) => Book.fromJson(el)).toList());
      else
        _data =
            parsedJson["books"].map<Book>((el) => Book.fromJson(el)).toList();

      loading = false;
      change(_data, status: RxStatus.success());

      return _data;
    }
  }

  String getLink(int id) {
    return "";
  }

  Future<Book?> find(Map<String, dynamic> params) async {
    String link = Variables.LINK_GET_BOOKS;

    final parsedJson = await apiProvider.fetch(link,
        param: params, ACCESS_TOKEN: userController.ACCESS_TOKEN);

    if (parsedJson != null && parsedJson['books']!=null && parsedJson['books'].length>0)
      return Book.fromJson(parsedJson['books'][0]);
    else
      return null;
  }

  Future<bool> sendActivationCode({required String phone}) async {
    return await settingController.sendActivationCode(phone: phone);
  }

  Future<dynamic> mark(dynamic id) {
    return userController
        .mark(params: {'type': "App\\Book", 'content_id': "$id"});
  }

  Future<bool> buy(dynamic id) async {
    final parsedJson = await apiProvider.fetch(Variables.LINK_BUY_BOOK,
        param: {'book_id': id},
        method: 'post',
        ACCESS_TOKEN: userController.ACCESS_TOKEN);
    if (parsedJson == null || parsedJson['type'] == null)
      helper.showToast(msg: 'buy_problem'.tr, status: 'danger');
    else if (parsedJson['message'] != null)
      helper.showToast(
          msg: parsedJson['message'],
          status: parsedJson['type'] == 'success' ? 'success' : 'danger');
    if (parsedJson['wallet'] != null) {
      userController.user?.wallet = parsedJson['wallet'];
      return true;
    }
    return false;
  }

  openMap({
    required String latitude,
    required String longitude,
    required String label,
  }) async {
    Uri uri;
    if (kIsWeb) {
      uri = Uri.https('www.google.com', '/maps/place/$latitude+$longitude/',
          {'api': '1', 'query': '$latitude,$longitude'});
    } else if (Platform.isAndroid) {
      var query = '$latitude,$longitude';

      if (label != null) query += '($label)';
      //
      // uri = Uri(scheme: 'geo', host: '0,0', queryParameters: {'q': query});
      uri = Uri.https(
          "www.google.com", "/maps/place/$latitude+$longitude/@$query,17z");
    } else if (Platform.isIOS) {
      var params = {'ll': '$latitude,$longitude'};

      if (label != null) params['q'] = label;

      uri = Uri.https('maps.apple.com', '/', params);
    } else {
      uri = Uri.https('www.google.com', '/maps/search/',
          {'api': '1', 'query': '$latitude,$longitude'});
    }
    if (await canLaunchUrl(uri))
      launchUrl(uri, mode: LaunchMode.externalApplication);
    else
      helper.showToast(msg: 'cant_load_map'.tr, status: 'danger');
  }

  launchFile({required String link}) async {
    if (userController.hasPlan(goShop: true, message: true)) {
      if (await canLaunchUrlString(link))
        launchUrlString(link, mode: LaunchMode.externalApplication);
      else
        helper.showToast(msg: 'cant_load_file'.tr, status: 'danger');
    }
  }
}
