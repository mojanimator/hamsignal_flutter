import 'dart:convert';

import 'package:get/get_connect/connect.dart';

class ApiProvider extends GetConnect {
  ApiProvider() {
    // final box = GetStorage();
    // blogController = Get.find<BlogController>();
  }

  Future<Map<String, dynamic>?> fetch(String url,
      {Map<String, dynamic>? param,
      String method = 'get',
      String? ACCESS_TOKEN,
      Map<String, dynamic> headers = const {},
      Function(double percent)? onProgress}) async {
    Map<String, dynamic>? params = {...param ?? {}};
    // Map<String, dynamic>? params = {...param ?? {}};
// print(param);
    for (var key in params.keys) {
      if (params[key] is int) {
        params[key] = params[key].toString();
      }
    }
    final Response response;
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
      );
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
              onProgress != null ? onProgress(percent) : null);

    // if (url.contains('setting')) print(response.bodyString);
    // if (url.contains('login')) print(response.bodyString);

    // if (url.contains('edit')) print(response.bodyString);
    // if (url.contains('user')) print(response.bodyString);
    // if (url.contains('create')) print(response.bodyString);
    // if (url.contains('blog')) print(response.bodyString);
    // print(response.bodyString);

    //{"message":"Unauthenticated."}
    if (response.status.code == 401 ||
        response.status.code == 422 ||
        response.status.code == 429) {
      return Future.value({'user': null, 'errors': response.body['errors']});
    } else if (response.status.hasError || response.bodyString == null) {
      return Future.value(null);
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
