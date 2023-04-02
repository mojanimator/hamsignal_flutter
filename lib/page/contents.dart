import 'package:dabel_adl/controller/AnimationController.dart';
import 'package:dabel_adl/controller/SettingController.dart';
import 'package:dabel_adl/helper/styles.dart';
import 'package:dabel_adl/widget/filter_blogs.dart';
import 'package:dabel_adl/widget/search_section.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/ContentController.dart';
import '../widget/filter_contents.dart';
import '../widget/grid_content.dart';
import '../widget/loader.dart';

class ContentsPage extends StatelessWidget {
  late ContentController controller;
  late MyAnimationController animationController;
  late Style styleController;
  late SettingController settingController;
  ScrollController scrollController = ScrollController();
  late MaterialColor colors;
  final String type;

  ContentsPage(
      {Key? key, Map<String, String>? initFilter, this.type = 'news'}) {
    controller = Get.find<ContentController>();
    settingController = Get.find<SettingController>();
    styleController = Get.find<Style>();
    colors = styleController.cardContentColors;
    animationController = Get.find<MyAnimationController>();
    controller.filterController.set(initFilter ?? {});
    controller.getData(param: {'page': 'clear', 'type': type});
    controller.filterController.change(true, status: RxStatus.success());
    scrollController.addListener(() {
      if (scrollController.position.pixels + 50 >
          scrollController.position.maxScrollExtent) {
        if (!controller.loading) {
          controller.getData();
        }
      }
    });

    // WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
    //   Future.delayed(Duration(seconds: 3), () {
    //     Get.to(
    //         ClubDetails(
    //             data: controller.data[0],
    //             controller: controller,
    //             settingController: settingController,
    //             styleController: styleController,
    //             colors: colors),
    //         transition: Transition.circularReveal,
    //         duration: Duration(milliseconds: 400));
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
// appBar: AppBar(actions: [
//   IconButton(onPressed:()=> showSearch(context: context, delegate: SearchBar()), icon: Icon(Icons.search))
// ]),

      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () => controller.getData(param: {'page': 'clear'}),
        child: Container(
          decoration: BoxDecoration(gradient: styleController.splashBackground),
          child: SafeArea(
            child: Column(
              children: [
                SearchSection(
                  filterSection: ContentFilterSection(
                    controller: controller,
                  ),
                  controller: controller,
                  hintText: controller.filterController.searchHintText,
                ),
                Expanded(
                  child: controller.obx((data) {
                    if (styleController.gridLength < 2)
                      return Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              physics: BouncingScrollPhysics(),
                              controller: scrollController,
                              padding: EdgeInsets.zero,
                              shrinkWrap: false,
                              itemCount: data!.length,
                              itemBuilder: (BuildContext context, int index) {
                                return GridContent(
                                  data: data[index],
                                  controller: controller,
                                  settingController: settingController,
                                  styleController: styleController,
                                  colors: colors,
                                );
                              },
                            ),
                          ),
                          controller.loading ? Loader() : Center()
                        ],
                      );
                    else
                      return Column(
                        children: [
                          Expanded(
                            child: GridView.builder( physics: BouncingScrollPhysics(),
                              shrinkWrap: false,
                              controller: scrollController,
                              itemCount: data!.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          styleController.gridLength,
                                      childAspectRatio: 1.5),
                              itemBuilder: (BuildContext context, int index) {
                                return GridContent(
                                  data: data[index],
                                  controller: controller,
                                  settingController: settingController,
                                  styleController: styleController,
                                  colors: colors,
                                );
                              },
                            ),
                          ),
                          controller.loading ? Loader() : Center()
                        ],
                      );
                  },
                      onEmpty: Center(
                        child: Text(
                          "no_result".tr,
                          style: styleController.textBigLightStyle,
                        ),
                      ),
                      onLoading: Loader()),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   backgroundColor: styleController.primaryColor,
      //   child: Icon(Icons.add),
      // ),
    );
  }
}
