import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dabel_adl/controller/APIController.dart';
import 'package:dabel_adl/controller/UserFilterController.dart';
import 'package:dabel_adl/helper/variables.dart';
import 'package:dabel_adl/widget/shakeanimation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:http/http.dart' as http;
import '../controller/SettingController.dart';
import '../helper/styles.dart';

class MyProfileImage extends StatelessWidget {
  Rx<Map<String, String>> cacheHeaders = Rx<Map<String, String>>({});
  late final APIController controller;
  late final Style styleController;
  late final SettingController settingController;
  late MaterialColor colors;
  late bool isEditable;
  Function? onEdit;
  late String tag;
  String? failAsset;
  late Rx<dynamic> src;
  double? cropRatio;
  Rx<File?> imageFile = Rx<File?>(null);
  Rx<bool> loading = Rx<bool>(false);

  MyProfileImage(
      {MaterialColor? colors,
      String? tag,
      src,
      this.cropRatio,
      Function? this.onEdit,
      String? this.failAsset,
      required APIController this.controller}) {
    styleController = Get.find<Style>();
    settingController = Get.find<SettingController>();
    this.colors = colors ?? styleController.primaryMaterial;
    this.tag = tag ?? DateTime.now().millisecondsSinceEpoch.toString();
    this.src = Rx<dynamic>(src ?? '');
    this.isEditable = onEdit != null;

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      loading.value = true;
      if (src is String) {
        var link = Uri.tryParse("${this.src.value}");
        dynamic response =
            link != null ? (await http.get(link)) : Response(statusCode: 404);
        imageFile.value ??=
            await File((await getTemporaryDirectory()).path + '/' + "$tag")
                .writeAsBytes(response.bodyBytes);
      }
      if (src is File) {
        imageFile.value = src;
      }
      loading.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (data) => InkWell(
        onTap: () => Navigator.of(context).push(PageRouteBuilder(
            opaque: false,
            barrierDismissible: true,
            pageBuilder: (BuildContext context, _, __) {
              return Hero(
                tag: tag,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      width: Get.width,
                      height: Get.height,
                      decoration: BoxDecoration(
                          gradient: styleController.splashBackground),
                      child: Obx(
                        () => InteractiveViewer(
                          child: imageFile.value != null
                              ? Image.file(
                                  imageFile.value as File,
                                  fit: BoxFit.contain,
                                )
                              : Image.asset(
                                  failAsset ?? 'assets/images/icon-dark.png',
                                  fit: BoxFit.contain),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: styleController.cardMargin * 2,
                      child: Container(
                        color: Colors.black.withOpacity(.7),
                        padding: EdgeInsets.all(styleController.cardMargin * 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () {
                                Get.back();
                              },
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                    CircleBorder(
                                        side: BorderSide(
                                            color: colors[50]!, width: 1)),
                                  ),
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith(
                                          (states) => states.contains(
                                                  MaterialState.pressed)
                                              ? styleController.secondaryColor
                                              : Colors.transparent)),
                              child: Padding(
                                padding: EdgeInsets.all(
                                    styleController.cardMargin / 2),
                                child: Icon(
                                  Icons.clear,
                                  color: colors[50],
                                ),
                              ),
                            ),
                            if (isEditable)
                              TextButton(
                                onPressed: () async {
                                  loading.value = true;
                                  String? path =
                                      await settingController.pickAndCrop(
                                    ratio: cropRatio,
                                    colors: colors,
                                  );

                                  if (path != null && onEdit != null) {
                                    Get.back();
                                    onEdit!(path);
                                    cacheHeaders.value = {
                                      'Cache-Control':
                                          'max-age=0, no-cache, no-store'
                                    };
                                    settingController.clearImageCache(
                                        url: "${src.value}");

                                    imageFile.update((val) {
                                      imageFile.value = File(path);
                                    });
                                    Future.delayed(
                                        Duration(
                                          seconds: 10,
                                        ),
                                        () => imageFile.refresh());
                                    imageFile.refresh();
                                  }
                                    loading.value = false;
                                },
                                style: ButtonStyle(
                                    shape: MaterialStateProperty.all(
                                      CircleBorder(
                                          side: BorderSide(
                                              color: colors[50]!, width: 1)),
                                    ),
                                    backgroundColor:
                                        MaterialStateProperty.resolveWith(
                                            (states) => states.contains(
                                                    MaterialState.pressed)
                                                ? styleController.secondaryColor
                                                : Colors.transparent)),
                                child: Padding(
                                  padding: EdgeInsets.all(
                                      styleController.cardMargin / 2),
                                  child: Icon(
                                    Icons.add_photo_alternate_outlined,
                                    color: colors[50],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            })),
        child: Hero(
          tag: tag,
          child: ShakeWidget(
            child: Obx(
              () => Stack(
                children: [
                  if (imageFile.value != null)
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(
                            styleController.cardBorderRadius,
                          ),
                          bottom: Radius.circular(
                              styleController.cardBorderRadius / 4),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(
                            styleController.cardBorderRadius,
                          ),
                          bottom: Radius.circular(
                              styleController.cardBorderRadius / 4),
                        ),
                        child: Image.file(
                          imageFile.value as File,
                          height: styleController.imageHeight,
                          width: styleController.imageHeight,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  if (imageFile.value == null)
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(
                            styleController.cardBorderRadius,
                          ),
                          bottom: Radius.circular(
                              styleController.cardBorderRadius / 4),
                        ),
                      ),
                      child: Image.asset(
                          failAsset ?? 'assets/images/icon-dark.png',
                          height: styleController.imageHeight,
                          width: styleController.imageHeight,
                          fit: BoxFit.contain),
                    ),
                  if (false)
                    Positioned.fill(
                      child: IgnorePointer(
                        ignoring: true,
                        child: Icon(
                          Icons.zoom_out_map_sharp,
                          color: colors[50],
                        ),
                      ),
                    ),
                  if (loading.value)
                    Positioned.fill(
                      child: CupertinoActivityIndicator(
                        color: colors[50],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ) ,onEmpty: Center(),onError:(er)=> Center(),onLoading: Center()
    );
  }
}
