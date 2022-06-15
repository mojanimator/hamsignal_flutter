import 'package:dabel_sport/controller/ShopController.dart';
import 'package:get/get.dart';

class ShopFilterController extends GetxController with StateMixin<bool> {
  int _total = -1;
  ShopController parent;

  int get total => _total;
  String searchHintText = 'name'.tr +
      ',' +
      'product'.tr +
      ',' +
      'sport'.tr +
      ',' +
      'province'.tr +
      ',' +
      'county'.tr;

  set total(int value) {
    _total = value;
  }

  ShopFilterController({required this.parent}) {
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
      case 'gender':
        return filters[type] == 'm'
            ? 'man'.tr
            : filters[type] == 'w'
                ? 'woman'.tr
                : '';
      case 'province':
        return this.parent.settingController.province(filters[type]);
      case 'county':
        return this.parent.settingController.county(filters[type]);
      case 'sport':
        return this.parent.settingController.sport(filters[type]);
      default:
        return filters[type].toString();
    }
  }

  Map<String, dynamic> initFilters = {
    'page': '0',
    'name': '',
    'gender': null,
    'sport': null,
    'province': null,
    'county': null,
    'age_l': '',
    'age_h': '',
    // 'panel': '',
  };
  late Map<String, dynamic> filters;

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
        case 'province':
          filters[type] = idx;
          filters['county'] = null;
          break;
        case 'county':
          filters[type] = idx;

          break;
        case 'age_l':
          filters[type] = idx;
          break;
        case 'age_h':
          filters[type] = idx;
          break;
        case 'weight_l':
          filters[type] = idx;
          break;
        case 'weight_h':
          filters[type] = idx;
          break;
        case 'height_l':
          filters[type] = idx;
          break;
        case 'height_h':
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
