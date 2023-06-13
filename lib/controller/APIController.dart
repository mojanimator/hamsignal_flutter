import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

abstract class APIController<T> extends GetxController with StateMixin<T> {
  abstract Map<String, dynamic> filters;

  APIController() {}

  toggleFilter(String type, {idx}) {}

  getFilterSelected(String type, {idx}) {

  }
}
