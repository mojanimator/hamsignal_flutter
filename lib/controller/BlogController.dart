import 'dart:convert';

import 'package:dabel_sport/controller/APIProvider.dart';
import 'package:dabel_sport/controller/BlogFilterController.dart';
import 'package:dabel_sport/controller/SettingController.dart';
import 'package:dabel_sport/controller/UserController.dart';
import 'package:dabel_sport/helper/variables.dart';
import 'package:dabel_sport/model/Blog.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class BlogController extends GetxController with StateMixin<List<Blog>> {
  int _total = 0;
  List<Blog> _data = [];

  late String _storageLink;

  bool loading = false;

  int get currentLength => _data.length;

  List<Blog> get data => _data;

  String get storageLink => _storageLink;

  set storageLink(String storageLink) {}

  set data(List<Blog> value) {
    _data = value;
  }

  int get total => _total;

  set total(int value) {
    _total = value;
  }

  late final ApiProvider apiProvider;
  late final SettingController settingController;
  late final UserController userController;
  late final BlogFilterController filterController;

  BlogController() {
    apiProvider = Get.find<ApiProvider>();
    settingController = Get.find<SettingController>();
    userController = Get.find<UserController>();
    filterController = BlogFilterController(parent: this);
    _storageLink =
        Variables.LINK_STORAGE + '/${settingController.getDocType('blog')}';
  }

  @override
  onInit() {
    super.onInit();
  }

  Future<List<Blog>?> getData({Map<String, dynamic>? param}) async {
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
    final parsedJson = await apiProvider.fetch(Variables.LINK_GET_BLOGS,
        param: params, ACCESS_TOKEN: userController.ACCESS_TOKEN);

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
            parsedJson["data"].map<Blog>((el) => Blog.fromJson(el)).toList());
      else
        _data =
            parsedJson["data"].map<Blog>((el) => Blog.fromJson(el)).toList();

      loading = false;
      change(_data, status: RxStatus.success());

      return _data;
    }
  }

  static getCategoty(category_id) {
    return 'test';
  }

  getImageLinks(List<dynamic>? docs) {
    if (docs == null || docs.length == 0) return [];
    return docs
        .map((doc) =>
            "${Variables.LINK_STORAGE}/${doc['type_id']}/${doc['id']}.jpg")
        .toList();
  }

  getThumbLink(List<dynamic>? docs) {
    if (docs == null || docs.length == 0) return [];
    return docs
        .map((doc) =>
            "${Variables.LINK_STORAGE}/${doc['type_id']}/${doc['id']}.jpg")
        .toList()[0];
  }

  Future<Blog?> find(Map<String, dynamic> params) async {
    final parsedJson = await apiProvider.fetch(Variables.LINK_FIND_BLOG,
        param: params, ACCESS_TOKEN: userController.ACCESS_TOKEN);
// print(parsedJson);
    if (parsedJson != null)
      return Blog.fromJson(parsedJson);
    else
      return null;
  }

  getCategory(String category_id) {
    return settingController.category(category_id);
  }
}
