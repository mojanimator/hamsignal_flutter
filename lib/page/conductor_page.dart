import 'package:hamsignal/controller/AnimationController.dart';
import 'package:hamsignal/controller/EventController.dart';
import 'package:hamsignal/helper/helpers.dart';
import 'package:hamsignal/helper/styles.dart';
import 'package:hamsignal/model/Event.dart';
import 'package:hamsignal/page/menu_drawer.dart';
import 'package:hamsignal/widget/AppBar.dart';
import 'package:hamsignal/widget/blinkanimation.dart';
import 'package:hamsignal/widget/loader.dart';
import 'package:hamsignal/widget/mini_card.dart';
import 'package:hamsignal/widget/slide_menu.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ConductorPage extends StatelessWidget {
  late EventController controller;
  late Style style;
  late MaterialColor colors;
  late TabController tabController;
  late MyAnimationController animationController;
  GlobalKey<SideMenuState> _sideMenuKey =
      GlobalKey<SideMenuState>(debugLabel: 'sideMenuKey');

  Map<String, String> dateTime = {};

  ConductorPage({Key? key}) {
    controller = Get.find<EventController>();
    style = Get.find<Style>();
    animationController = Get.find<MyAnimationController>();
    colors = style.primaryMaterial;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SideMenu(
        key: _sideMenuKey,
        inverse: true,
        closeIcon: Icon(
          Icons.close,
          color: style.primaryColor,
        ),
        radius: BorderRadius.circular(style.cardBorderRadius),
        closeDrawer: animationController.closeDrawer,
        menu: DrawerMenu(onTap: () {
          final _state = _sideMenuKey.currentState;
          if (_state!.isOpened) {
            _state.closeSideMenu();
            animationController.closeDrawer();
          } else {
            _state.openSideMenu();
            animationController.openDrawer();
            // _animationButtonController.reverse();
          }
        }),
        background: Colors.transparent,
        child: Container(
          decoration:
              BoxDecoration(gradient: style.mainGradientBackground),
          child: MyAppBar(
              child: controller.obx((data) {
                int index = 0;
                dateTime = createTabDateTime(data);
                for (int idx = 0; idx < data!.keys.length; idx++)
                  if (data.keys.elementAt(idx) == controller.today) index = idx;
                controller.currentTabIndex.value = index;
                tabController = TabController(
                  length: data.keys.length,
                  vsync: animationController,
                  initialIndex: controller.currentTabIndex.value,
                );
                tabController.addListener(() {
                  controller.currentTabIndex.value = tabController.index;
                });
                return Container(
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            height: style.cardMargin,
                          ),
                          Obx(
                            () => SizedBox(
                              height: style.tabHeight,
                              child: TabBar(
                                labelPadding: EdgeInsets.zero,
                                indicatorPadding: EdgeInsets.zero,
                                tabs: getTabs(data.keys),
                                controller: tabController,
                                isScrollable: true,
                                indicatorWeight: 1,
                                indicator: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                        style.cardBorderRadius / 2)),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),

                          Expanded(
                            child: TabBarView(
                                physics: AlwaysScrollableScrollPhysics(),
                                controller: tabController,
                                children: data.keys.map(
                                  (day) {
                                    return Column(
                                      children: [
                                        SizedBox(
                                          height: style.cardMargin * 3,
                                        ),
                                        Text(dateTime[day] ?? '',style: style.textBigStyle.copyWith(color: colors[500]),),
                                        Expanded(
                                          child:data[day]==null?Center(child: Text('conductor_not_exists'.tr,style: style.textMediumStyle,),): RefreshIndicator(
                                            onRefresh: () => refresh(),
                                            child: ListView.builder(
                                              physics:
                                                  AlwaysScrollableScrollPhysics(),
                                              // controller: scrollController,
                                              padding: EdgeInsets.zero,
                                              shrinkWrap: false,
                                              itemCount:  data[day].keys.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return MiniCard(
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal:
                                                          style
                                                                  .cardMargin /
                                                              2,
                                                      vertical: 0),
                                                  colors: ([
                                                    Colors.deepPurple,
                                                    Colors.indigo
                                                  ]..shuffle())
                                                      .first,
                                                  title: data[day]
                                                      .keys
                                                      .elementAt(index),
                                                  desc1: '',
                                                  style:
                                                      style,
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .stretch,
                                                      children: data[day][
                                                              data[day]
                                                                  .keys
                                                                  .elementAt(
                                                                      index)]
                                                          .map<Widget>(
                                                              (event) =>
                                                                  eventRow(
                                                                      event))
                                                          .toList()),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ).toList()),
                          ),
                        ],
                      ),
                      Visibility(visible: controller.loading, child: Loader())
                    ],
                  ),
                );
              },
                  onLoading: Loader(),
                  onError: (str) => Column(
                        children: [
                          Text(
                            'check_network'.tr,
                            style: style.textHeaderLightStyle,
                          ),
                          SizedBox(height: style.cardMargin),
                          TextButton(
                              onPressed: () => refresh(),
                              style: style
                                  .buttonStyle(backgroundColor:style.primaryColor),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: style.cardMargin / 2,
                                  horizontal: style.cardMargin,
                                ),
                                child: Text(
                                  'retry'.tr,
                                  style: style.textHeaderLightStyle,
                                ),
                              )),
                        ],
                      )),
              sideMenuKey: _sideMenuKey),
        ),
      ),
    );
  }

  refresh() async {
    controller.getData(params: {'group': '1'});
    return Future(() => null);
  }

  getTabs(Iterable<String> keys) {
    return keys
        .map(
          (day) => Center(
            child: FittedBox(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: style.cardMargin),
                child: Text(
                  day,
                  style: style.textMediumStyle.copyWith(
                      color: keys.elementAt(controller.currentTabIndex.value) ==
                              day
                          ? colors[500]
                          : colors[50]),
                ),
              ),
            ),
          ),
        )
        .toList();
  }

  Widget eventRow(Map<String, dynamic> event) {
    Event e = Event.fromJson(event);
    return InkWell(
      onTap: () async {
        if (await canLaunch(e.link)) launch(e.link);
      },
      child: Column(
        children: [
          Divider(),
          if(e.title=='...')
    Text('conductor_not_exists'.tr,style: style.textMediumStyle,),
    if(e.title!='...')
          IntrinsicHeight(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: e.team1 == '' || e.team2 == ''
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.spaceEvenly,
                  children: [
                    if (e.team1 != '')
                      Text(
                        e.team1,
                        style: style.textMediumStyle.copyWith(
                            color: colors[600], fontWeight: FontWeight.bold),
                      ),
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          Text(e.score1,
                              style: style.textSmallStyle
                                  .copyWith(color: colors[500])),
                          !e.status.contains('progressing'.tr)
                              ? e.score2 == '' && e.score1 == ''
                                  ? Text(
                                      e.time != '' &&
                                              e.time.split('|').length > 1
                                          ? e.time.split('|')[1]
                                          : e.time,
                                      style: style.textSmallStyle
                                          .copyWith(color: colors[500]))
                                  : VerticalDivider()
                              : liveBlinker(),
                          Text(e.score2,
                              style: style.textSmallStyle
                                  .copyWith(color: colors[500])),
                        ],
                      ),
                    ),
                    if (e.team2 != '')
                      Text(
                        e.team2,
                        style: style.textMediumStyle.copyWith(
                            color: colors[600], fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    e.status == '' && (e.score2 != '' || e.score1 != '')
                        ? Text(
                            e.time != '' && e.time.split('|').length > 1
                                ? e.time.split('|')[1]
                                : e.time,
                            style: style.textSmallStyle
                                .copyWith(color: colors[500]))
                        : !e.status.contains('progressing'.tr)
                            ? e.status == '' && e.source != ''
                                ? Text(
                                    e.source,
                                    style: style.textSmallStyle
                                        .copyWith(color: colors[200]),
                                  )
                                : Text(
                                    e.status,
                                    style: style.textSmallStyle
                                        .copyWith(color: colors[200]),
                                  )
                            : Center(),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  liveBlinker() {
    return Container(
        margin:
            EdgeInsets.symmetric(horizontal: style.cardMargin / 2),
        child: BlinkAnimation(
            repeat: true,
            child: Container(
              padding: EdgeInsets.all(style.cardMargin / 4),
              decoration:
                  BoxDecoration(color: Colors.green, shape: BoxShape.circle),
            )),
        padding: EdgeInsets.all(1),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.green), shape: BoxShape.circle));
  }

  Map<String, String> createTabDateTime(Map<String, dynamic>? data) {
    if (data == null) return {};
    dateTime = {};
    for (var i = 0; i < data.keys.length; i++) {
      if( data[data.keys.elementAt(i)]==null) continue;
      var el = data[data.keys.elementAt(i)]
          ?[data[data.keys.elementAt(i)]?.keys?.elementAt(0)];
      if(el.length>0)
        el=el[0]['time'];
      el=Helper.toShamsi(el);
      if(el!=null)
       el= el.split('|').first;
      dateTime.addAll({
        data.keys.elementAt(i): el
      });
    }
    return dateTime;
  }
}
