import 'dart:convert';

import 'package:dabel_adl/controller/APIProvider.dart';
import 'package:dabel_adl/controller/LawyerFilterController.dart';
import 'package:dabel_adl/controller/SettingController.dart';
import 'package:dabel_adl/controller/UserController.dart';
import 'package:dabel_adl/helper/helpers.dart';
import 'package:dabel_adl/helper/variables.dart';
import 'package:dabel_adl/model/Lawyer.dart';
import 'package:get/get.dart';

import '../model/Category.dart';

class LawyerController extends GetxController with StateMixin<List<Lawyer>> {
  List<Lawyer> _data = [];
  late String _storageLink;
  bool loading = false;

  int get currentLength => _data.length;

  List<Lawyer> get data => _data;

  String get storageLink => _storageLink;

  set storageLink(String storageLink) {}

  set data(List<Lawyer> value) {
    _data = value;
  }

  late final apiProvider;
  late final SettingController settingController;
  late LawyerFilterController filterController;
  late final UserController userController;
  late final Helper helper;

  LawyerController() {
    apiProvider = Get.find<ApiProvider>();
    settingController = Get.find<SettingController>();
    filterController = LawyerFilterController(parent: this);
    userController = Get.find<UserController>();
    helper = Get.find<Helper>();
  }

  @override
  onInit() {
    // getData();
    super.onInit();
  }

  String getProfileLink(List<dynamic>? docs, {editable: false}) {
    var t = settingController.getDocType(editable ? 'license' : 'Lawyer');

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

  Future<List<Lawyer>?> getData({
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
    if (params['search'] != null && params['search'] != '') {}
    // change(_data, status: RxStatus.loading());
    final parsedJson = await apiProvider.fetch(Variables.LINK_GET_LAWYERS,
        param: params, ACCESS_TOKEN: userController.ACCESS_TOKEN);
// print(parsedJson );
    if (parsedJson == null ||
        parsedJson['lawyers'] == null ||
        parsedJson['lawyers'].length == 0) {
      loading = false;
      if (int.parse(filterController.filters['page']) > 1)
        change(_data, status: RxStatus.success());
      else
        change(_data, status: RxStatus.empty());
      return _data;
    } else {
      filterController.total = parsedJson["total"];

      if (int.parse(params['page']) > 0)
        _data.addAll(parsedJson["lawyers"]
            .map<Lawyer>((el) => Lawyer.fromJson(el))
            .toList());
      else
        _data = parsedJson["lawyers"]
            .map<Lawyer>((el) => Lawyer.fromJson(el))
            .toList();

      loading = false;
      change(_data, status: RxStatus.success());

      return _data;
    }
  }

  List<String> getImageLinks(List docLinks, {bool editable = false}) {
    var t = settingController.getDocType('Lawyer');
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

  Future<Lawyer?> find(Map<String, dynamic> params) async {
    String link = Variables.LINK_GET_LAWYERS;
    if (params['id'] != null) link = "${link}/${params['id']}";
    final parsedJson = await apiProvider.fetch(link,
        param: params, ACCESS_TOKEN: userController.ACCESS_TOKEN);

    if (parsedJson != null)
      return Lawyer.fromJson(parsedJson);
    else
      return null;
  }

  Future<bool> sendActivationCode({required String phone}) async {
    return await settingController.sendActivationCode(phone: phone);
  }

  Future<dynamic> mark(dynamic id) {
    return userController
        .mark(params: {'type': "App\\User", 'content_id': "$id"});
  }

 List get categories => settingController.categories
      .where((element) => element['related'] == CategoryRelate.Lawyer)
      .toList();

  String category(String? category_id) {
    var t =
        categories.firstWhereOrNull((element) => "${element['id']}" == category_id);
    return t == null ? '' : t['title'];
  }
}
