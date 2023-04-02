import 'dart:convert';

import 'package:dabel_adl/controller/APIProvider.dart';
import 'package:dabel_adl/controller/SettingController.dart';
import 'package:dabel_adl/controller/UserController.dart';
import 'package:dabel_adl/helper/variables.dart';
import 'package:dabel_adl/model/Content.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../model/Category.dart';
import 'ContentFilterController.dart';

class ContentController extends GetxController with StateMixin<List<Content>> {
  int _total = 0;
  List<Content> _data = [];

  late String _storageLink;

  bool loading = false;

  int get currentLength => _data.length;

  List<Content> get data => _data;

  String get storageLink => _storageLink;

  set storageLink(String storageLink) {}

  set data(List<Content> value) {
    _data = value;
  }

  int get total => _total;

  set total(int value) {
    _total = value;
  }

  late final ApiProvider apiProvider;
  late final SettingController settingController;
  late final UserController userController;
  late final ContentFilterController filterController;

  ContentController() {
    apiProvider = Get.find<ApiProvider>();
    settingController = Get.find<SettingController>();
    userController = Get.find<UserController>();
    filterController = ContentFilterController(parent: this);
    _storageLink =
        Variables.LINK_STORAGE + '/${settingController.getDocType('Content')}';
  }

  @override
  onInit() {
    super.onInit();
  }

  Future<List<Content>?> getMain({Map<String, dynamic>? param}) async {
    loading = true;
    update();

    Map<String, dynamic> params = {};

    final parsedJson = await apiProvider.fetch(Variables.LINK_GET_MAIN,
        param: params, ACCESS_TOKEN: userController.ACCESS_TOKEN);
    // print(parsedJson);
    if (parsedJson == null || parsedJson['contents'].length == 0) {
      loading = false;

      change(_data, status: RxStatus.empty());
      return _data;
    } else {
      _data = parsedJson["contents"]
          .map<Content>((el) => Content.fromJson(el))
          .toList();

      loading = false;
      change(_data, status: RxStatus.success());

      return _data;
    }
  }

  Future<List<Content>?> getData({Map<String, dynamic>? param}) async {
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

    final parsedJson = await apiProvider.fetch(Variables.LINK_GET_CONTENTS,
        param: params, ACCESS_TOKEN: userController.ACCESS_TOKEN);

    if (parsedJson == null || parsedJson['contents'].length == 0) {
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
            .map<Content>((el) => Content.fromJson(el))
            .toList());
      else
        _data = parsedJson["contents"]
            .map<Content>((el) => Content.fromJson(el))
            .toList();

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

  Future<Content?> find(Map<String, dynamic> params) async {
    String link = Variables.LINK_GET_CONTENTS;
    if (params['id'] != null) link = "${link}/${params['id']}";
    final parsedJson = await apiProvider.fetch(link,
        param: params, ACCESS_TOKEN: userController.ACCESS_TOKEN);

    if (parsedJson != null)
      return Content.fromJson(parsedJson);
    else
      return null;
  }

 List get categories => settingController.categories
      .where((element) => [
            CategoryRelate.Contents,
          ].contains(element['related']))
      .toList();

  String category(String? category_id) {
    var t =
        categories.firstWhereOrNull((element) => "${element['id']}" == category_id);

    return t == null ? '' : t['title'];
  }
}
