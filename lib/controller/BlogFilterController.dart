import 'package:dabel_sport/controller/BlogController.dart';
import 'package:get/get.dart';

class BlogFilterController extends GetxController with StateMixin<bool> {
  int _total = -1;
  BlogController parent;
  String searchHintText = 'search'.tr;

  int get total => _total;

  set total(int value) {
    _total = value;
  }

  Map<String, dynamic> initFilters = {
    'page': '0',
    'name': '',

    'sport': null,
    'category': null,

    // 'panel': '',
  };
  late Map<String, dynamic> filters;

  BlogFilterController({required this.parent}) {
    filters = {...initFilters};
  }

  @override
  onInit() {
    change(true, status: RxStatus.success());
    super.onInit();
  }

  dynamic getFilterSelected(type) {
    return filters[type];
  }

  dynamic getFilterName(type) {
    switch (type) {
      case 'category':
        return this.parent.settingController.category(filters[type]);
      case 'sport':
        return this.parent.settingController.sport(filters[type]);
      default:
        return filters[type].toString();
    }
  }

  dynamic toggleFilter(String type, {idx}) {
    if (idx == null) {
      filters[type] = null;
    } else
      switch (type) {
        case 'sport':
          filters[type] = idx;
          break;

        case 'category':
          filters[type] = idx;
          break;
      }

    update();
    this.parent.getData(param: {'page': 'clear'});
  } //set pre filters for list

  void set(Map<String, String> filter) {
    filters = {...initFilters};
    if (filter == {}) {
    } else {
      for (var key in filter.keys) filters[key] = filter[key];
    }
  }
}
