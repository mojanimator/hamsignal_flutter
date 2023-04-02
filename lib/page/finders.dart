import 'package:dabel_adl/controller/AnimationController.dart';
import 'package:dabel_adl/controller/SettingController.dart';
import 'package:dabel_adl/controller/UserController.dart';
import 'package:dabel_adl/helper/helpers.dart';
import 'package:dabel_adl/helper/styles.dart';
import 'package:dabel_adl/page/lawyer_details.dart';
import 'package:dabel_adl/widget/search_section.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/FinderController.dart';
import '../controller/LawyerController.dart';
import '../controller/LegalController.dart';
import '../widget/filter_finders.dart';
import '../widget/filter_lawyers.dart';
import '../widget/filter_legals.dart';
import '../widget/filter_locations.dart';
import '../widget/grid_lawyer.dart';
import '../widget/grid_legal.dart';
import '../widget/grid_location.dart';
import '../widget/loader.dart';

class FindersPage extends StatelessWidget {
  late FinderController controller;
  late MyAnimationController animationController;
  late Style styleController;
  late SettingController settingController;
  late UserController userController;
  ScrollController scrollController = ScrollController();
  late MaterialColor colors;

  FindersPage({Key? key, Map<String, String>? initFilter}) {
    controller = Get.find<FinderController>();
    settingController = Get.find<SettingController>();
    userController = Get.find<UserController>();
    styleController = Get.find<Style>();
    colors = styleController.cardLegalColors;
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
          decoration: BoxDecoration(
            gradient: styleController.splashBackground,
            image: DecorationImage(
                image: AssetImage("assets/images/texture.jpg"),
                repeat: ImageRepeat.repeat,
                fit: BoxFit.scaleDown,
                filterQuality: FilterQuality.medium,
                colorFilter: ColorFilter.mode(
                    styleController.primaryColor.withOpacity(.2),
                    BlendMode.colorBurn),
                opacity: .03),
          ),
          child: SafeArea(
            child: Column(
              children: [
                SearchSection(
                  filterSection: FinderFilterSection(
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
                                return controller.getGrid(
                                  data: data[index],
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
                                          styleController.gridLength,
                                      childAspectRatio: 1.5),
                              itemBuilder: (BuildContext context, int index) {
                                return controller.getGrid(
                                  data: data[index],
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
      // floatingActionButtonLegal: FloatingActionButtonLegal.startFloat,
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
