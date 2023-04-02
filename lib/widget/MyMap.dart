import 'dart:math' as math;

import 'package:dabel_adl/widget/shakeanimation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class MyMap extends StatelessWidget {
  final String? location;

  double? lat, lng;
  late Rx<LatLng> point;
  Rx<LatLng?> center = Rx<LatLng>(LatLng(35.715298, 51.404343));
  double? height;
  bool editable;
  bool fullScreen;
  RxBool addingMarker = RxBool(false);

  Function(String point) onChanged;

  MapController? mapController;

  MyMap(
      {Key? key,
      required String? this.location,
      double? this.height,
      bool this.fullScreen = false,
      bool this.editable = false,
      MapController? this.mapController,
      required Function(String point) this.onChanged}) {
    this.fullScreen = fullScreen;

    if (location != null && location != '') {
      List<String>? tmp = location?.split(',');
      if (tmp != null && tmp != []) {
        lat = double.tryParse(tmp[0]);
        lng = double.tryParse(tmp[1]);
        if (lat != null && lng != null)
          point = Rx<LatLng>(LatLng(lat as double, lng as double));
      }
    } else {
      point = Rx<LatLng>(LatLng(35.715298, 51.404343));
    }
  }

  void toggleMarker() {
    addingMarker.value = !addingMarker.value;
  }

  @override
  Widget build(BuildContext context) {
    // if (point == null)
    //   return Center(
    //     child: Icon(
    //       Icons.place,
    //       color: Colors.red,
    //     ),
    //   );
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Obx(
            () => FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  interactiveFlags:
                      InteractiveFlag.all & ~InteractiveFlag.rotate,
                  center: point.value,
                  zoom: fullScreen ? 16 : 8.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                    // attributionBuilder: (_) {
                    //   return Text("© OpenStreetMap contributors");
                    // },
                  ),
                  MarkerLayer(
                    markers: [
                      if (point.value != null)
                        Marker(
                          point: point.value,
                          builder: (ctx) => Container(
                            child: Icon(
                              Icons.location_on_rounded,
                              color: Colors.red,
                              size: fullScreen ? 50 : 30.0,
                            ),
                          ),
                        ),
                    ],
                  ),
                ]),
          ),
          InkWell(
            onTap: () {
              fullScreen = true;
              Get.dialog(
                Obx(() => Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                            tag: 'map',
                            child: FlutterMap(
                              options: MapOptions(
                                  interactiveFlags: InteractiveFlag.all &
                                      ~InteractiveFlag.rotate,
                                  center: point.value,
                                  zoom: fullScreen ? 16 : 8.0,
                                  // plugins: [],
                                  onPositionChanged: (pos, bool) {
                                    center.value = pos.center;
                                    mapController?.move(
                                        pos.center!, fullScreen ? 16 : 10.0);
                                    // if (onChanged != null) onChanged!(pos.center as LatLng);
                                  }),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                  subdomains: ['a', 'b', 'c'],
                                  // attributionBuilder: (_) {
                                  //   return Text("© OpenStreetMap contributors");
                                  // },
                                ),
                                MarkerLayer(
                                  markers: [
                                    if (point.value != null)
                                      Marker(
                                        point: point.value,
                                        builder: (ctx) => Container(
                                          child: Icon(
                                            Icons.location_on_rounded,
                                            color: Colors.red,
                                            size: fullScreen ? 50 : 30.0,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                              // nonRotatedLayers: [],
                            )),
                        if (addingMarker.value && fullScreen)
                          Positioned(
                            right: 22,
                            left: 0,
                            top: 14,
                            bottom: 0,
                            child: Center(
                              child: GestureDetector(
                                onTap: () {
                                  point.value = center.value!;
                                  // mapController.move(point.value, 13);
                                  onChanged(
                                      "${point.value.latitude},${point.value.longitude}");
// mapController.move(point.value , 13);
                                },
                                child: ShakeWidget(
                                    shakeOnRebuild: true,
                                    child: Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.rotationY(math.pi),
                                      child: Icon(
                                        Icons.maps_ugc,
                                        color: Colors.black,
                                        size: 50,
                                      ),
                                    )),
                              ),
                            ),
                          ),
                        if (fullScreen)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 8,
                            child: Container(
                              color: Colors.black.withOpacity(.2),
                              padding: EdgeInsets.all(4),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (addingMarker.value && editable)
                                      FloatingActionButton(
                                        onPressed: () async {
                                          point.value = center.value!;

                                          onChanged(
                                              "${point.value.latitude},${point.value.longitude}");
                                        },
                                        heroTag: 'accept_marker',
                                        backgroundColor: Colors.transparent,
                                        shape: StadiumBorder(
                                            side: BorderSide(
                                                color: Colors.white, width: 1)),
                                        elevation: 1,
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.white,
                                        ),
                                      ),
                                    if (editable)
                                      FloatingActionButton(
                                        onPressed: () async {
                                          addingMarker.value =
                                              !addingMarker.value;
                                        },
                                        heroTag: 'toggle_marker',
                                        backgroundColor: Colors.transparent,
                                        shape: StadiumBorder(
                                            side: BorderSide(
                                                color: Colors.white, width: 1)),
                                        elevation: 1,
                                        child: Icon(
                                          addingMarker.value
                                              ? Icons.location_off_sharp
                                              : Icons.add_location_alt_outlined,
                                          color: Colors.white,
                                        ),
                                      ),
                                    FloatingActionButton(
                                      onPressed: () async {
                                        Get.back();
                                      },
                                      heroTag: 'close',
                                      backgroundColor: Colors.transparent,
                                      shape: StadiumBorder(
                                          side: BorderSide(
                                              color: Colors.white, width: 1)),
                                      elevation: 1,
                                      child: Icon(
                                        Icons.clear,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    )),
                useSafeArea: true,
              );
            },
          )
        ],
      ),
    );
  }
}
