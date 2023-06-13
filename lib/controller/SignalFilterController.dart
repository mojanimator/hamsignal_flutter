import 'package:hamsignal/controller/SignalController.dart';
import 'package:get/get.dart';

import 'APIController.dart';

class SignalFilterController extends APIController<bool> {
  int _total = -1;
  SignalController parent;

  get searchHintText => 'search'.tr;

  int get total => _total;

  set total(int value) {
    _total = value;
  }

  Map<String, dynamic> initFilters = {
    'page': '0',
    'search': '',
    'category': null,
    'position': null,
    'bookmark': null,

    // 'panel': '',
  };
  late Map<String, dynamic> filters;

  SignalFilterController({required this.parent}) {
    filters = {...initFilters};
  }

  @override
  onInit() {
    change(true, status: RxStatus.success());
    super.onInit();
  }

  dynamic getFilterSelected(type, {idx}) {
    if (type == 'position') {
      return [filters[type] == 'Buy', filters[type] == 'Sell'];
    }
    if (type == 'bookmark') {
      return [filters[type] == 1, filters[type] == 0];
    } else
      return filters[type];
  }

  dynamic getFilterName(type) {
    switch (type) {
      case 'position':
        return "${filters[type]}".tr;
      case 'bookmark':
        return filters[type] == 1 ? '➕' : '➖';

      default:
        return filters[type].toString();
    }
  }

  dynamic toggleFilter(String type, {idx}) {
    if (idx == null) {
      filters[type] = null;
    } else
      switch (type) {
        case 'position':
          if (idx == 0) {
            if (filters[type] == 'Buy')
              filters[type] = null;
            else
              filters[type] = 'Buy';
          } else if (idx == 1) {
            if (filters[type] == 'Sell')
              filters[type] = null;
            else
              filters[type] = 'Sell';
          }
          break;
        case 'bookmark':
          if (idx == 0) {
            if (filters[type] == 1)
              filters[type] = null;
            else
              filters[type] = 1;
          } else if (idx == 1) {
            if (filters[type] == 0)
              filters[type] = null;
            else
              filters[type] = 0;
          }
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
