import 'package:dabel_sport/controller/ProductController.dart';
import 'package:get/get.dart';

class ProductFilterController extends GetxController with StateMixin<bool> {
  int _total = -1;
  ProductController parent;

  int get total => _total;
  String searchHintText = 'name'.tr + ',' + 'sport'.tr + ',' + 'shop'.tr;

  set total(int value) {
    _total = value;
  }

  Map<String, dynamic> initFilters = {
    'page': '0',
    'shop': '',
    'name': '',

    'sport': null,

    // 'panel': '',
  };
  late Map<String, dynamic> filters;

  ProductFilterController({required this.parent}) {
    filters = {...initFilters};
  }

  @override
  onInit() {
    change(true, status: RxStatus.success());
    super.onInit();
  }

  dynamic getFilterSelected(type) {
    if (type == 'gender') {
      if (filters[type] == 'm')
        return [false, true, false];
      else if (filters[type] == 'w')
        return [false, false, true];
      else
        return [false, false, false];
    } else
      return filters[type];
  }

  dynamic getFilterName(type) {
    switch (type) {
      case 'sport':
        return this.parent.settingController.sport(filters[type]);
      case 'shop':
        return this.parent.settingController.shop(filters[type]);
      default:
        return filters[type].toString();
    }
  }

  dynamic toggleFilter(String type, {idx}) {
    if (idx == null) {
      if (type.contains('_l') || type.contains('_h'))
        filters[type] = '';
      else
        filters[type] = null;
    } else
      switch (type) {
        case 'gender':
          if (idx == 1) {
            if (filters[type] == 'm')
              filters[type] = null;
            else
              filters[type] = 'm';
          } else if (idx == 2) {
            if (filters[type] == 'w')
              filters[type] = null;
            else
              filters[type] = 'w';
          } else if (idx == 0) filters[type] = null;
          break;
        case 'sport':
          filters[type] = idx;
          break;
        case 'shop':
          filters[type] = idx;

          break;
      }


    update();
    this.parent.getData(param: {'page': 'clear'});
  } //set pre filters for list

  void set(Map<String, dynamic> filter) {
    filters = {...initFilters};
    if (filter == {}) {
    } else {
      for (var key in filter.keys) filters[key] = filter[key];
    }
  }
}
