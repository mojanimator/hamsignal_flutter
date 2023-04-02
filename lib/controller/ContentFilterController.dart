import 'package:dabel_adl/controller/ContentController.dart';
import 'package:get/get.dart';

import 'APIController.dart';

class ContentFilterController extends APIController<bool> {
  int _total = -1;
  ContentController parent;
  String searchHintText = 'search'.tr;

  int get total => _total;

  set total(int value) {
    _total = value;
  }

  Map<String, dynamic> initFilters = {
    'page': '0',
    'name': '',
    'type': 'news',
    'sport': null,
    'category_id': null,

    // 'panel': '',
  };
  late Map<String, dynamic> filters;

  ContentFilterController({required this.parent}) {
    filters = {...initFilters};
  }

  @override
  onInit() {
    change(true, status: RxStatus.success());
    super.onInit();
  }

  dynamic getFilterSelected(type,{idx}) {
    return filters[type];
  }

  dynamic getFilterName(type) {
    switch (type) {
      case 'category_id':
        return this.parent.category("${filters[type]}");

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

        case 'category_id':
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
