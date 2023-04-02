import 'package:dabel_adl/controller/FinderController.dart';
import 'package:dabel_adl/model/Category.dart';
import 'package:get/get.dart';

import 'APIController.dart';

class FinderFilterController extends APIController<bool> {
  int _total = -1;
  FinderController parent;

  String searchHintText = 'search'.tr;

  int get total => _total;

  set total(int value) {
    _total = value;
  }

  Map<String, dynamic> initFilters = {
    'page': '0',
    'search': '',
    'paginate': 12,
    'type': null,

    // 'panel': 'دفتر خدمات',
  };
  late Map<String, dynamic> filters;

  FinderFilterController({required this.parent}) {
    filters = {...initFilters};
  }

  @override
  onInit() {
    change(true, status: RxStatus.success());
    super.onInit();
  }

  dynamic getFilterSelected(type, {idx}) {
    return filters[type];
  }

  dynamic getFilterName(type) {
    switch (type) {
      case 'type':
        return this.parent.type("${filters[type]}");

      default:
        return filters[type].toString();
    }
  }

  dynamic toggleFilter(String type, {idx}) {
    if (idx == null) {
      filters[type] = null;
    } else
      switch (type) {
        case 'type':
          filters['type'] = idx;
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
