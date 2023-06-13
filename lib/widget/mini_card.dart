import 'package:hamsignal/helper/styles.dart';
import 'package:hamsignal/widget/shakeanimation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class MiniCard extends StatelessWidget {
  Style style;
  EdgeInsets? margin;
  EdgeInsets? titlePadding;
  late String title;
  late String desc1;
  late String? desc2;
  late MaterialColor colors;
  late Widget? child;
  late TextStyle titleStyle;
  Function()? onTap;
  bool disabled = true;
  bool shrink = true;
  bool scrollable = false;
  late RxBool? loading = false.obs;

  MiniCard(
      {Key? key,
      required String this.title,
      required String this.desc1,
      String? this.desc2,
      Widget? this.child,
      EdgeInsets? this.margin,
      EdgeInsets? this.titlePadding,
      required Style this.style,
      MaterialColor? colors,
      bool disabled = false,
      this.onTap,
      this.shrink = true,    this.scrollable = false,  this.loading   })
      : super(key: key) {
    this.colors = colors ?? style.primaryMaterial;
    titleStyle =
        style.textMediumStyle.copyWith(color: this.colors[900]);
    this.disabled = disabled;
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: AbsorbPointer(
        absorbing: disabled,
        child: ShakeWidget(
          child: Padding(
            padding: margin ??
                EdgeInsets.all(
                  style.cardMargin,
                ),
            child: Card(
              margin: EdgeInsets.zero,
              color: Colors.white,
              elevation: 10,
              shadowColor: colors[500]?.withOpacity(.5),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(style.cardBorderRadius),
              ),
              child: ListView(
                shrinkWrap: shrink,
physics:scrollable?AlwaysScrollableScrollPhysics(): NeverScrollableScrollPhysics(),
                children: [
                  Container(
                    padding: titlePadding ??
                        EdgeInsets.all(style.cardMargin / 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(
                              style.cardBorderRadius / 2)),
                      color: colors[50],
                    ),
                    child: Text(
                      "${title}",
                      textAlign: TextAlign.center,
                      style: style.textMediumLightStyle.copyWith(
                          color: colors[500], fontWeight: FontWeight.bold),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onTap,
                      child: Container(
                        padding:
                            EdgeInsets.all(style.cardMargin * 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(
                                  style.cardBorderRadius / 4)),
                          color: Colors.white,
                        ),
                        child: child != null
                            ? Material(
                                color: Colors.transparent, child: child)
                            : desc2 != null
                                ? IntrinsicHeight(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "${desc1}",
                                          style: titleStyle,
                                        ),
                                        VerticalDivider(),
                                        Text(
                                          "${desc2}",
                                          style: titleStyle,
                                        ),
                                      ],
                                    ),
                                  )
                                : Text(
                                  "${desc1}",
                                  style: titleStyle,
                                  textAlign: TextAlign.center,
                                ),
                      ),
                    ),
                  ),
                  if(loading !=null)
                  Obx(()=>  Padding(
                    padding:   EdgeInsets.all(style.cardMargin).copyWith(top:style.cardMargin/4,bottom:style.cardMargin*2  ),
                    child: Visibility(visible: loading!.value,child: Material(child: LinearProgressIndicator(),)),
                  ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
