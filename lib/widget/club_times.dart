import 'package:dabel_sport/controller/SettingController.dart';
import 'package:dabel_sport/helper/helpers.dart';
import 'package:dabel_sport/helper/styles.dart';
import 'package:dabel_sport/widget/shakeanimation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClubTimes extends StatelessWidget {
  late Rx<List<  dynamic> > times;
  final SettingController settingController = Get.find<SettingController>();
  final Style styleController = Get.find<Style>();
  bool editable;
  MaterialColor colors;

  Function(dynamic times)? onChange;

  ClubTimes(
      {Key? key,
      List<dynamic> times = const [],
      required this.colors,
      this.editable = false, Function(dynamic times)? this.onChange})
      : super(key: key) {
    this.times = Rx<List<  dynamic >>(this.editable
        ? times
        : [
            ...times,
            // {'id': -1, 'g': -1, 'fm': -1, 'fh': -1, 'tm': -1, 'th': -1, 'd': -1}
          ]);
  }

  void changed(){
    if (onChange!=null)
      onChange!(times.value);
    times.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        int idx = 0;
        return Container(
          child: Column(
              children: times.value.map((e) {
                    int index = idx++;
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.5),
                          borderRadius: BorderRadius.circular(
                              styleController.cardBorderRadius / 2)),
                      padding: EdgeInsets.all(styleController.cardMargin / 2),
                      child: ShakeWidget(
                        shakeOnRebuild: true,
                        child: Row(
                          children: [
                            if (editable)
                              Column(
                                children: [
                                  InkWell(
                                      onTap: () {
                                        if (index == 0) return;
                                        times.value.insert(index - 1,
                                            times.value.removeAt(index));
                                        changed();
                                      },
                                      child: Container(
                                          padding: EdgeInsets.all(
                                              styleController.cardMargin / 4),
                                          decoration: BoxDecoration(
                                              color: colors[700],
                                              borderRadius: BorderRadius.vertical(
                                                  top: Radius.circular(
                                                      styleController
                                                          .cardBorderRadius))),
                                          child: Icon(
                                            Icons.arrow_upward,
                                            color: colors[50],
                                          ))),
                                  InkWell(
                                      onTap: () {
                                        times.value.removeAt(index);
                                        changed();
                                      },
                                      child: Container(
                                          padding: EdgeInsets.all(
                                              styleController.cardMargin / 4),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                          ),
                                          child: Icon(
                                            Icons.remove,
                                            color: colors[50],
                                          ))),
                                  InkWell(
                                      onTap: () {
                                        if (index == times.value.length - 1)
                                          return;
                                        times.value.insert(index + 1,
                                            times.value.removeAt(index));
                                        changed();
                                      },
                                      child: Container(
                                          padding: EdgeInsets.all(
                                              styleController.cardMargin / 4),
                                          decoration: BoxDecoration(
                                              color: colors[700],
                                              borderRadius: BorderRadius.vertical(
                                                  bottom: Radius.circular(
                                                      styleController
                                                          .cardBorderRadius))),
                                          child: Icon(
                                            Icons.arrow_downward,
                                            color: colors[50],
                                          ))),
                                ],
                              ),
                            Expanded(
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                          child: TimesCell(
                                              index: index,
                                              dropdowns: {
                                                'sport':
                                                    settingController.sports
                                              },
                                              text: settingController
                                                  .sport("${e['id']}"),
                                              color: colors[900])),
                                      Expanded(
                                        child: TimesCell(
                                            index: index,
                                            dropdowns: {
                                              'd': settingController.days
                                                  .asMap()
                                                  .keys
                                                  .map((key) => {
                                                        'id': key,
                                                        'name':
                                                            settingController
                                                                .days[key]
                                                      })
                                                  .toList()
                                            },
                                            text: settingController.day(e['d']),
                                            color: colors[800],
                                            side: 'rtl'),
                                      ),
                                      Expanded(
                                          child: TimesCell(
                                              index: index,
                                              dropdowns: {
                                                'gender': [
                                                  {'id': 0, 'name': 'men'.tr},
                                                  {'id': 1, 'name': 'women'.tr},
                                                ]
                                              },
                                              text: e['g'] == -1
                                                  ? 'gender'.tr
                                                  : e['g'] == 0
                                                      ? 'men'.tr
                                                      : 'women'.tr,
                                              color: colors[900],
                                              side: 'ltr')),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Row(
                                        children: [
                                          Expanded(
                                              child: TimesCell(
                                                  index: index,
                                                  text: "start_time".tr,
                                                  color: colors[700],
                                                  side: 'rtl')),
                                          Expanded(
                                              child: TimesCell(
                                                  index: index,
                                                  dropdowns: {
                                                    'fm': 0
                                                        .to(46, step: 15)
                                                        .map((e) => {
                                                              'id': e,
                                                              'name': e
                                                            })
                                                        .toList(),
                                                    'fh': 1
                                                        .to(24)
                                                        .map((e) => {
                                                              'id': e,
                                                              'name': e
                                                            })
                                                        .toList(),
                                                  },
                                                  text: e['fh'] == -1 ||
                                                          e['fm'] == -1
                                                      ? '...'
                                                      : "${'${e['fh']}'.padLeft(2, '0')}:${'${e['fm']}'.padLeft(2, '0')}",
                                                  color: colors[600],
                                                  side: 'ltr')),
                                        ],
                                      )),
                                      Expanded(
                                          child: Row(
                                        children: [
                                          Expanded(
                                              child: TimesCell(
                                                  index: index,
                                                  text: "end_time".tr,
                                                  color: colors[700],
                                                  side: 'rtl')),
                                          Expanded(
                                              child: TimesCell(
                                                  index: index,
                                                  dropdowns: {
                                                    'tm': 0
                                                        .to(46, step: 15)
                                                        .map((e) => {
                                                              'id': e,
                                                              'name': e
                                                            })
                                                        .toList(),
                                                    'th': 1
                                                        .to(24)
                                                        .map((e) => {
                                                              'id': e,
                                                              'name': e
                                                            })
                                                        .toList()
                                                  },
                                                  text: e['th'] == -1 ||
                                                          e['tm'] == -1
                                                      ? '...'
                                                      : "${'${e['th']}'.padLeft(2, '0')}:${'${e['tm']}'.padLeft(2, '0')}",
                                                  color: colors[600],
                                                  side: 'ltr')),
                                        ],
                                      )),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList() +
                  [ editable?
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 1),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              style: ButtonStyle(
                                  padding: MaterialStateProperty.all(
                                      EdgeInsets.all(
                                          styleController.cardMargin/2)),
                                  overlayColor:
                                      MaterialStateProperty.resolveWith(
                                    (states) {
                                      return states
                                              .contains(MaterialState.pressed)
                                          ? styleController.secondaryColor
                                          : null;
                                    },
                                  ),
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.green),
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(
                                          styleController.cardBorderRadius / 2),
                                    ),
                                  ))),
                              onPressed: () async {
                                times.value.add({
                                  'id': '',
                                  'g': -1,
                                  'fm': -1,
                                  'fh': -1,
                                  'tm': -1,
                                  'th': -1,
                                  'd': -1
                                });
                                changed();
                              },
                              child: Icon(Icons.add, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ):Container()
                  ]),
        );
      },
    );
  }

  Widget TimesCell(
      {required String text,
      Color? color,
      String side = 'center',
      Map<String, List<dynamic>> dropdowns = const {},
      required int index}) {
    EdgeInsets padding = EdgeInsets.all(styleController.cardMargin / 4);
    EdgeInsets margin = EdgeInsets.all(styleController.cardMargin / 4);
    BorderRadius radius =
        BorderRadius.all(Radius.circular(styleController.cardBorderRadius / 4));
    if (side == 'rtl') {
      radius = radius.copyWith(topLeft: Radius.zero, bottomLeft: Radius.zero);
      margin = margin.copyWith(left: 0);
    }
    if (side == 'ltr') {
      radius = radius.copyWith(topRight: Radius.zero, bottomRight: Radius.zero);
      margin = margin.copyWith(right: 0);
    }

    if(!editable)
      return Container(
        decoration: BoxDecoration(borderRadius: radius,  color: color ,),
        margin: margin,
        padding: padding,

        child: Center(child:FittedBox(
            fit: BoxFit.scaleDown,child: Text(text,style: styleController.textMediumLightStyle,))),
      );


    List<Widget> widgets = [];
    for (var key in dropdowns.keys) {
      List<DropdownMenuItem> items =
          dropdowns[key]!.map<DropdownMenuItem>((item) {
        return DropdownMenuItem(
          child: Container(
            child: Center(child: Text("${item['name']}")),
          ),
          value: item['id'],
        );
      }).toList();

      widgets.add(
        Obx(
          () => Padding(
            padding: EdgeInsets.all(styleController.cardMargin / 2),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: colors[500]!, width: 1),
                borderRadius: BorderRadius.circular(
                    styleController.cardBorderRadius /
                        2), //border raiuds of dropdown button
              ),
              child: DropdownButton<dynamic>(
                elevation: 10,

                borderRadius:
                    BorderRadius.circular(styleController.cardBorderRadius),
                dropdownColor: Colors.white,
                underline: Container(),
                items: items,
                isExpanded: true,
                value:
                        ![-1,''].contains(times.value[index][key == 'sport'
                            ? 'id'
                            : key == 'gender'
                            ? 'g'
                            : key])?
                        key == 'sport'? "${times.value[index]['id']}": key == 'gender'?
                        times.value[index]['g']: times.value[index][key]
                    : null,
                icon: Center(),
                // underline: Container(),
                hint: Center(
                    child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    key.tr + '...',
                    style: TextStyle(color: colors[500]),
                  ),
                )),

                onChanged: (idx) {
                  // data[key].value = dropdowns[key].where((e)=>e['id']);

                  times.value[index][key == 'sport'
                      ? 'id'
                      : key == 'gender'
                          ? 'g'
                          : key] = idx;

                  changed();
                },
                selectedItemBuilder: (BuildContext context) => dropdowns[key]!
                    .map<Widget>((el) => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                styleController.cardBorderRadius / 2),
                            color: colors[500],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              IconButton(
                                onPressed: () {
                                  times.value[index][key == 'sport'
                                      ? 'id'
                                      : key == 'gender'
                                          ? 'g'
                                          : key] = -1;

                                  changed();
                                },
                                icon: Icon(Icons.close),
                                color: Colors.white,
                              ),
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Center(
                                      child: Text(
                                    "${el['name']}",
                                    style: styleController.textSmallLightStyle,
                                  )),
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
        ),
      );
    }

    if (widgets.length == 1)
      return widgets[0];
    else
      return Container(
        padding: EdgeInsets.symmetric(vertical: styleController.cardMargin / 2),
        margin: margin,
        child: InkWell(
          onTap: () => widgets.length > 1
              ? Get.dialog(
                  Center(
                      child: Padding(
                    padding: EdgeInsets.all(styleController.cardMargin),
                    child: Material(
                        borderRadius: BorderRadius.circular(
                            styleController.cardBorderRadius),
                        child: Padding(
                          padding: EdgeInsets.all(styleController.cardMargin),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IntrinsicHeight(
                                  child: Row(
                                children: widgets
                                    .map((e) => Expanded(child: e))
                                    .toList(),
                              )),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                        style: ButtonStyle(
                                            padding: MaterialStateProperty.all(
                                                EdgeInsets.all(styleController
                                                    .cardMargin)),
                                            overlayColor: MaterialStateProperty
                                                .resolveWith(
                                              (states) {
                                                return states.contains(
                                                        MaterialState.pressed)
                                                    ? styleController
                                                        .secondaryColor
                                                    : null;
                                              },
                                            ),
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    colors[800]),
                                            shape: MaterialStateProperty.all(
                                                RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(styleController
                                                        .cardBorderRadius /
                                                    2),
                                              ),
                                            ))),
                                        onPressed: () async {
                                          Get.back();
                                        },
                                        child: Text(
                                          "${'close'.tr}",
                                          style: styleController
                                              .textMediumLightStyle
                                              .copyWith(
                                                  fontWeight: FontWeight.bold),
                                        )),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )),
                  )),
                )
              : null,
          child: Text(
            text,
            style: styleController.textMediumStyle.copyWith(
                color: text.contains('...') ? colors[500] : Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
        decoration: BoxDecoration(
          color: text.contains('...')
              ? Colors.white
              : text.contains('start_time'.tr) | text.contains('end_time'.tr)
                  ? colors[500]
                  : colors[800],
          borderRadius: radius,
          border: Border.all(
            color: colors[500]!,
            width: 1,
          ),
        ),
      );
  }
}
