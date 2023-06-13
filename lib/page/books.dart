import 'package:hamsignal/controller/AnimationController.dart';
import 'package:hamsignal/controller/SettingController.dart';
import 'package:hamsignal/controller/UserController.dart';
import 'package:hamsignal/helper/helpers.dart';
import 'package:hamsignal/helper/styles.dart';
import 'package:hamsignal/page/lawyer_details.dart';
import 'package:hamsignal/widget/search_section.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/LawyerController.dart';
import '../controller/BookController.dart';
import '../widget/filter_books.dart';
import '../widget/filter_lawyers.dart';
import '../widget/filter_legals.dart';
import '../widget/filter_locations.dart';
import '../widget/grid_book.dart';
import '../widget/grid_lawyer.dart';
import '../widget/grid_legal.dart';
import '../widget/grid_location.dart';
import '../widget/loader.dart';

class BooksPage extends StatelessWidget {
  late BookController controller;
  late MyAnimationController animationController;
  late Style style;
  late SettingController settingController;
  late UserController userController;
  ScrollController scrollController = ScrollController();
  late MaterialColor colors;

  BooksPage({Key? key, Map<String, String>? initFilter}) {
    controller = Get.find<BookController>();
    settingController = Get.find<SettingController>();
    userController = Get.find<UserController>();
    style = Get.find<Style>();
    colors = style.cardVotesColors;
    animationController = Get.find<MyAnimationController>();
    controller.filterController.set(initFilter ?? {});
    controller.getData(param: {'page': 'clear'});
    controller.filterController.change(true, status: RxStatus.success());
    scrollController.addListener(() {
      if (scrollController.position.pixels + 50 >
          scrollController.position.maxScrollExtent) {
        if (!controller.loading) {
          controller.getData();
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // Future.delayed(Duration(seconds: 1), () async{
      //   Get.to(
      //       LawyerDetails(
      //           data:await  controller.find({'id': 3009,'panel':'1'}),
      //
      //           colors: colors),
      //       transition: Transition.circularReveal,
      //       duration: Duration(milliseconds: 400));
      // });
    });
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
                  filterSection: BookFilterSection(
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
                                return GridBook(
                                  data: data[index],
                                  controller: controller,
                                  settingController: settingController,
                                  style: style,
                                  userController: userController,
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
                                      crossAxisCount:
                                          style.gridLength,
                                      childAspectRatio: 1.5),
                              itemBuilder: (BuildContext context, int index) {
                                return GridBook(
                                  data: data[index],
                                  controller: controller,
                                  settingController: settingController,
                                  style: style,
                                  userController: userController,
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
      // floatingActionButtonBook: FloatingActionButtonBook.startFloat,
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Get.to(ClubCreate())?.then((result) {
      //       if (result != null &&
      //           result['msg'] != null &&
      //           result['status'] != null) {
      //         settingController.refresh();
      //         settingController.helper
      //             .showToast(msg: result['msg'], status: result['status']);
      //       }
      //     });
      //   },
      //   backgroundColor: colors[500],
      //   child: Icon(Icons.add),
      // ),
    );
  }
}
