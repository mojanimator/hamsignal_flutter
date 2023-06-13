import 'dart:convert';
import 'dart:io';

import 'package:hamsignal/controller/APIProvider.dart';
import 'package:hamsignal/controller/DocumentFilterController.dart';
import 'package:hamsignal/controller/SettingController.dart';
import 'package:hamsignal/controller/UserController.dart';
import 'package:hamsignal/helper/helpers.dart';
import 'package:hamsignal/helper/variables.dart';
import 'package:hamsignal/model/Document.dart';
import 'package:hamsignal/page/document_details.dart';
import 'package:hamsignal/page/documents.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/Category.dart';

class DocumentController extends GetxController
    with StateMixin<List<Document>> {
  List<Document> _data = [];
  late String _storageLink;
  bool loading = false;

  int get currentLength => _data.length;

  List<Document> get data => _data;

  String get storageLink => _storageLink;

  set storageLink(String storageLink) {}

  set data(List<Document> value) {
    _data = value;
  }

  late final apiProvider;
  late final SettingController settingController;
  late DocumentFilterController filterController;
  late final UserController userController;
  late final Helper helper;

  DocumentController() {
    apiProvider = Get.find<ApiProvider>();
    settingController = Get.find<SettingController>();
    filterController = DocumentFilterController(parent: this);
    userController = Get.find<UserController>();
    helper = Get.find<Helper>();
  }

  @override
  onInit() {
    // getData();
    super.onInit();
  }

  List get categories => settingController.categories
      .where((element) => [
            CategoryRelate.Conventions,
            CategoryRelate.Votes,
            CategoryRelate.Opinions
          ].contains(element['related']))
      .toList();

  String category(String? category_id) {
    var t = categories
        .firstWhereOrNull((element) => "${element['id']}" == category_id);
    return t == null ? '' : t['title'];
  }

  String getProfileLink(List<dynamic>? docs, {editable: false}) {
    var t = settingController.getDocType(editable ? 'license' : 'Document');

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

  Future<List<Document>?> getData({
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

    // change(_data, status: RxStatus.loading());
    final parsedJson = await apiProvider.fetch(Variables.LINK_GET_DOCUMENTS,
        param: params, ACCESS_TOKEN: userController.ACCESS_TOKEN);
// print(parsedJson );
    if (parsedJson == null ||
        parsedJson['contents'] == null ||
        parsedJson['contents'].length == 0) {
      loading = false;
      if (int.parse(filterController.filters['page']) > 1)
        change(_data, status: RxStatus.success());
      else
        change(_data, status: RxStatus.empty());
      return _data;
    } else {
      filterController.total = parsedJson["total"];

      if (int.parse(params['page']) > 0)
        _data.addAll(parsedJson["contents"]
            .map<Document>((el) => Document.fromJson(el))
            .toList());
      else
        _data = parsedJson["contents"]
            .map<Document>((el) => Document.fromJson(el))
            .toList();

      loading = false;
      change(_data, status: RxStatus.success());

      return _data;
    }
  }

  String getLink(int id) {
    return "";
  }

  Future<Document?> find(Map<String, dynamic> params) async {
    String link = Variables.LINK_GET_DOCUMENTS;
    final parsedJson = await apiProvider.fetch(link,
        param: params, ACCESS_TOKEN: userController.ACCESS_TOKEN);

    if (parsedJson != null && parsedJson['contents']!=null && parsedJson['contents'].length>0)
      return Document.fromJson(parsedJson['contents'][0]);
    else
      return null;
  }

  Future<bool> sendActivationCode({required String phone}) async {
    return await settingController.sendActivationCode(phone: phone);
  }

  Future<dynamic> mark(dynamic id, int categoryType) {
    String type = "App\\Document";
    if (categoryType == CategoryRelate.Opinions) type = "App\\Opinion";
    if (categoryType == CategoryRelate.Votes) type = "App\\Vote";
    if (categoryType == CategoryRelate.Conventions) type = "App\\Convention";
    return userController.mark(params: {'type': type, 'content_id': "$id"});
  }

  launchPage({required int categoryType, required Document data,required MaterialColor colors}) {
    if (userController.hasPlan(goShop: true, message: true)) {
      MaterialColor colors = settingController.style.primaryMaterial;


      Get.to(DocumentDetails(
        colors: colors,
        categoryType: categoryType,
        data: data,
      ));
    }
  }
}
