import 'dart:convert';

import 'package:get/get.dart';
import 'package:get/get_connect/connect.dart';

class ApiProvider extends GetConnect {
  static const int maxRetry = 3;

  ApiProvider() {
    // final box = GetStorage();
    // blogController = Get.find<BlogController>();
  }

  Future<Map<String, dynamic>?> fetch(String url,
      {Map<String, dynamic>? param,
      String method = 'get',
      String? ACCESS_TOKEN,
      Map<String, dynamic> headers = const {},
      Function(double percent)? onProgress,
      int tryReminded = 0}) async {
    Map<String, dynamic>? params = {...param ?? {}};
    // Map<String, dynamic>? params = {...param ?? {}};
    // print(url);
    for (var key in params.keys) {
      if (params[key] is int) {
        params[key] = params[key].toString();
      }
    }
    Response response;
    if (method == 'get')
      response = await get(
        makeUrl(url: url, params: params),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          ...headers,
          ...{
            'Authorization': ACCESS_TOKEN != null ? 'Bearer $ACCESS_TOKEN' : ''
          }
        },
      ).timeout(
        Duration(seconds: 60),
        onTimeout: () {
          print("timeout get");
          return Future.value(Response(body: {'errors': 'check_network'.tr}));
        },
      ).catchError((error, stacktrace) =>
          Response(body: {'errors': 'check_network'.tr}));
    else
      response = await post(url, FormData(params),
              headers: {
                // "Content-Type": "application/json",
                "Accept": "application/json",
                ...headers,
                ...{
                  'Authorization':
                      ACCESS_TOKEN != null ? 'Bearer $ACCESS_TOKEN' : ''
                }
              },
              uploadProgress: (percent) =>
                  onProgress != null ? onProgress(percent) : null)
          .timeout(Duration(seconds: 60), onTimeout: () {
        print("timeout post");
        return Future.value(Response(body: {'errors': 'check_network'.tr}));
      }).catchError((error, stacktrace) =>
              Response(body: {'errors': 'check_network'.tr}));

    // if (url.contains('setting')) print(response.bodyString);
    // if (url.contains('login')) print(response.bodyString);

    // if (url.contains('edit')) print(response.bodyString);
    // if (url.contains('user')) print(response.bodyString);
    // if (url.contains('create')) print(response.bodyString);
    // if (url.contains('blog')) print(response.bodyString);
    // print(Variables.DOMAIN);
    // if (Variables.DOMAIN.startsWith('https:'))
    //   Variables.DOMAIN = Variables.DOMAIN.replaceFirst('https:', 'http:');
    // if (url.startsWith('https:'))
    //   url = url.replaceFirst('https:', 'http:');
    //
    print(url);
    print(response.bodyString);
    // //
    // print(response.status.code);
    //{"message":"Unauthenticated."}
    if (response.status.code == 401 ||
        response.status.code == 422 ||
        response.status.code == 429) {
      return Future.value({
        'user': null,
        'error': (response.body is List ? response.body[0] : null) ??
            (response.body['errors'] != null
                ? response.body['errors'] is Map
                    ? (response.body['errors'].values.first is List
                        ? response.body['errors'].values.first[0]
                        : response.body['errors'].values.first)
                    : (response.body['errors'] is List
                        ? response.body['errors'][0]
                        : null)
                : null) ??
            response.body['message']
      });
    } else if (response.status.hasError) {
      return Future.value(null);
    } else if (response.bodyString == null) {
      if (tryReminded <= 0) return Future.value(null);
      tryReminded--;
      Future.delayed(Duration(seconds: 2));
      fetch(url,
          method: method,
          ACCESS_TOKEN: ACCESS_TOKEN,
          headers: headers,
          param: params,
          onProgress: onProgress,
          tryReminded: tryReminded);
    } else {
      try {
        return json.decode(response.bodyString as String);
      } catch (e) {
        return Future.value(null);
      }
    }
  }

  String makeUrl({required String url, Map<String, dynamic>? params}) {
    Uri uri = Uri.parse(url);

    if (params != null)
      return uri.replace(queryParameters: params).toString();
    else
      return uri.toString();
  }
}
