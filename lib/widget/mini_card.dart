import 'package:dabel_adl/helper/styles.dart';
import 'package:dabel_adl/widget/shakeanimation.dart';
import 'package:flutter/material.dart';

class MiniCard extends StatelessWidget {
  Style styleController;
  EdgeInsets? margin;
  EdgeInsets? titlePadding;
  late String title;
  late String desc1;
  late String? desc2;
  late MaterialColor colors;
  late Widget? child;
  late TextStyle titleStyle;
  Function()? onTap;
  bool disabled = false;

  MiniCard({Key? key,
    required String this.title,
    required String this.desc1,
    String? this.desc2,
    Widget? this.child,
    EdgeInsets? this.margin,
    EdgeInsets? this.titlePadding,
    required Style this.styleController,
    MaterialColor? colors,
    bool disabled = false,
    this.onTap})
      : super(key: key) {
    this.colors = colors ?? styleController.primaryMaterial;
    titleStyle =
        styleController.textMediumStyle.copyWith(color: this.colors[900]);
    this.disabled = disabled;
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled? 0.5:1,
      child: AbsorbPointer(
        absorbing: disabled,
        child: ShakeWidget(
          child: Padding(
            padding: margin ??
                EdgeInsets.symmetric(
                    horizontal: styleController.cardMargin,
                    vertical: styleController.cardMargin / 4),
            child: Card(
              margin:
              EdgeInsets.symmetric(vertical: styleController.cardMargin / 4),
              color: colors[50],
              elevation: 10,
              shadowColor: colors[500]?.withOpacity(.5),
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(styleController.cardBorderRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: titlePadding ??
                        EdgeInsets.all(styleController.cardMargin / 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(
                              styleController.cardBorderRadius / 2)),
                      color: colors[500],
                    ),
                    child: Text(
                      "${title}",
                      textAlign: TextAlign.center,
                      style: styleController.textMediumLightStyle
                          .copyWith(
                          color: colors[50], fontWeight: FontWeight.bold),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onTap,
                      child: Container(
                        padding: EdgeInsets.all(styleController.cardMargin / 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(
                                  styleController.cardBorderRadius / 4)),
                          color: colors[50],
                        ),
                        child: child != null
                            ? Material(color: Colors.transparent, child: child)
                            : desc2 != null
                            ? IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                            : Center(
                          child: Text(
                            "${desc1}",
                            style: titleStyle,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
