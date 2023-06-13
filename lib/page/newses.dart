import 'package:hamsignal/controller/AnimationController.dart';
import 'package:hamsignal/controller/NewsController.dart';
import 'package:hamsignal/controller/SettingController.dart';
import 'package:hamsignal/helper/styles.dart';
import 'package:hamsignal/widget/grid_news.dart';
import 'package:hamsignal/widget/search_section.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widget/filter_news.dart';
import '../widget/loader.dart';

class NewsPage extends StatelessWidget {
  late NewsController controller;
  late MyAnimationController animationController;
  late Style style;
  late SettingController settingController;
  ScrollController scrollController = ScrollController();
  late MaterialColor colors;
  final String type;

  NewsPage({Key? key, Map<String, String>? initFilter, this.type = 'news'}) {
    controller = Get.find<NewsController>();
    settingController = Get.find<SettingController>();
    style = Get.find<Style>();
    colors = style.cardNewsColors;
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
    //             style: style,
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
          decoration: BoxDecoration(gradient: style.splashBackground),
          child: SafeArea(
            child: Column(
              children: [
                SearchSection(
                  filterSection: NewsFilterSection(
                    controller: controller,
                  ),
                  controller: controller,
                  hintText: controller.filterController.searchHintText,
                ),
                Expanded(
                  child: controller.obx((data) {
                    if (style.gridLength < 2)
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
                                return GridNews(
                                  data: data[index],
                                  controller: controller,
                                  settingController: settingController,
                                  style: style,
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
                            child: GridView.builder(
                              physics: BouncingScrollPhysics(),
                              shrinkWrap: false,
                              controller: scrollController,
                              itemCount: data!.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: style.gridLength,
                                      childAspectRatio: 1.5),
                              itemBuilder: (BuildContext context, int index) {
                                return GridNews(
                                  data: data[index],
                                  controller: controller,
                                  settingController: settingController,
                                  style: style,
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
                          style: style.textBigLightStyle,
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
      //   backgroundColor: style.primaryColor,
      //   child: Icon(Icons.add),
      // ),
    );
  }
}
