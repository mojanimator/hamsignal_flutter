import 'dart:convert';

import 'package:hamsignal/controller/APIProvider.dart';
import 'package:hamsignal/controller/SettingController.dart';
import 'package:hamsignal/controller/UserController.dart';
import 'package:hamsignal/helper/variables.dart';
import 'package:hamsignal/model/News.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../model/Category.dart';
import 'NewsFilterController.dart';

class NewsController extends GetxController with StateMixin<List<News>> {
  int _total = 0;
  List<News> _data = [];

  late String _storageLink;

  bool loading = false;

  int get currentLength => _data.length;

  List<News> get data => _data;

  String get storageLink => _storageLink;

  set storageLink(String storageLink) {}

  set data(List<News> value) {
    _data = value;
  }

  int get total => _total;

  set total(int value) {
    _total = value;
  }

  late final ApiProvider apiProvider;
  late final SettingController settingController;
  late final UserController userController;
  late final NewsFilterController filterController;

  NewsController() {
    apiProvider = Get.find<ApiProvider>();
    settingController = Get.find<SettingController>();
    userController = Get.find<UserController>();
    filterController = NewsFilterController(parent: this);
    _storageLink =
        Variables.LINK_STORAGE + '/${settingController.getDocType('News')}';
  }

  @override
  onInit() {
    super.onInit();
  }

  Future<List<News>?> getMain({Map<String, dynamic>? param}) async {
    loading = true;
    update();

    Map<String, dynamic> params = {};

    final parsedJson = await apiProvider.fetch(Variables.LINK_GET_NEWS,
        param: params, ACCESS_TOKEN: userController.ACCESS_TOKEN);
    // print(parsedJson);
    if (parsedJson == null ||
        parsedJson['data'] == null ||
        parsedJson['data'].length == 0) {
      loading = false;

      change(_data, status: RxStatus.empty());
      return _data;
    } else {
      _data = parsedJson["data"].map<News>((el) => News.fromJson(el)).toList();

      loading = false;
      change(_data, status: RxStatus.success());

      return _data;
    }
  }

  Future<List<News>?> getData({Map<String, dynamic>? param}) async {
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

    final parsedJson = await apiProvider.fetch(Variables.LINK_GET_NEWS,
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
            parsedJson["data"].map<News>((el) => News.fromJson(el)).toList());
      else
        _data =
            parsedJson["data"].map<News>((el) => News.fromJson(el)).toList();

      loading = false;
      change(_data, status: RxStatus.success());

      return _data;
    }
  }

  static getCategoty(category_id) {
    return 'test';
  }

  getImagesLink(List<String>? list) {
    if (list == null || list.length == 0)
      return [];
    else
      list.map((e) => e).toList();
  }

  getThumbLink({String? image, List<dynamic> photos = const []}) {
    if (photos.length > 0) {
      if (photos[0] != null) if (photos[0]['photo_thumb'] != null)
        return photos[0]['photo_thumb'];
      if (photos[0]['photo'] != null) return photos[0]['photo'];
    }

    return image;
  }

  Future<News?> find(Map<String, dynamic> params) async {
    String link = Variables.LINK_GET_NEWS;

    final parsedJson = await apiProvider.fetch(link,
        param: params, ACCESS_TOKEN: userController.ACCESS_TOKEN);

    if (parsedJson != null)
      return News.fromJson(parsedJson);
    else
      return null;
  }

  List get categories => settingController.categories.toList();

  String category(String? category_id) {
    var t = categories
        .firstWhereOrNull((element) => "${element['id']}" == category_id);

    return t == null ? '' : t['name'];
  }
}
