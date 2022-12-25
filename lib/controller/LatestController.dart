import 'package:dabel_sport/controller/APIProvider.dart';
import 'package:dabel_sport/helper/variables.dart';
import 'package:dabel_sport/model/Club.dart';
import 'package:dabel_sport/model/Coach.dart';
import 'package:dabel_sport/model/Player.dart';
import 'package:dabel_sport/model/Product.dart';
import 'package:dabel_sport/model/Shop.dart';
import 'package:dabel_sport/model/latest.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class LatestController extends GetxController with StateMixin<List<Latest>> {
  int _total = 0;
  List<Latest> _data = [];
  int _docType = 7;
  late String _storageLink;

  int get currentLength => _data.length;

  int get docType => _docType;

  List<Latest> get data => _data;

  String get storageLink => _storageLink;

  set storageLink(String storageLink) {}

  set data(List<Latest> value) {
    _data = value;
  }

  int get total => _total;

  set total(int value) {
    _total = value;
  }

  late final apiProvider;
  late final settingController;

  LatestController() {
    apiProvider = Get.find<ApiProvider>();

    _storageLink = Variables.LINK_STORAGE + '/$_docType';
  }

  @override
  onInit() {
    getData();
    super.onInit();
  }

  Future<List<Latest>?> getData({Map<String, dynamic>? param}) async {
    update();
    if (param != null && param['page'] == 'clear') {
      _data.clear();
      change(_data, status: RxStatus.loading());
      param['page'] = 1;
    }
    change([], status: RxStatus.loading());

    final parsedJson =
        await apiProvider.fetch(Variables.LINK_GET_LATEST, param: param);
    // print(parsedJson["data"][1]);
    if (parsedJson == null || parsedJson['data'].length == 0) {
      change(null, status: RxStatus.empty());
      return null;
    } else {
      total = parsedJson["total"];

      if (param != null && param['page'] > 1)
        _data.addAll(parsedJson["data"]
            .map<Latest>((el) => Latest.fromJson(el))
            .toList());
      else
        _data = parsedJson["data"]
            .map<Latest>((el) => Latest.fromJson(el))
            .toList();

      change(_data, status: RxStatus.success());
      return _data;
    }
  }

  static getCategoty(category_id) {
    return 'test';
  }

  String getLink(String id) {
    return "${Variables.LINK_PLAYER}/$id";
  }

  Future<dynamic> find(Map<String, dynamic> params) async {
    var t = params['type'];
    var parsedJson;
    switch (t) {
      case 'pl':
        parsedJson =
            await apiProvider.fetch(Variables.LINK_GET_PLAYERS, param: params);
        if (parsedJson != null && parsedJson['data'].length > 0)
          return Player.fromJson(parsedJson['data'][0]);
        else
          return null;

      case 'co':
        parsedJson =
            await apiProvider.fetch(Variables.LINK_GET_COACHES, param: params);
        if (parsedJson != null && parsedJson['data'].length > 0)
          return Coach.fromJson(parsedJson['data'][0]);
        else
          return null;

      case 'cl':
        parsedJson =
            await apiProvider.fetch(Variables.LINK_GET_CLUBS, param: params);
        if (parsedJson != null && parsedJson['data'].length > 0)
          return Club.fromJson(parsedJson['data'][0]);
        else
          return null;

      case 'sh':
        parsedJson =
            await apiProvider.fetch(Variables.LINK_GET_SHOPS, param: params);
        if (parsedJson != null && parsedJson['data'].length > 0)
          return Shop.fromJson(parsedJson['data'][0]);
        else
          return null;

      case 'pr':
        parsedJson =
            await apiProvider.fetch(Variables.LINK_GET_PRODUCTS, param: params);
        if (parsedJson != null && parsedJson['data'].length > 0)
          return Product.fromJson(parsedJson['data'][0]);
        else
          return null;
    }
  }
}
