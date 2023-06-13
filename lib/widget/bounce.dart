import 'dart:math';

import 'package:flutter/material.dart';

class MyBounce extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  MyBounce({
    required this.child,
    required this.onTap,
  });

  @override
  createState() => _MyBounceState();
}

class _MyBounceState extends State<MyBounce>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    controller = AnimationController(
        vsync: this,
        duration: Duration(
            milliseconds: 200 +
                Random(DateTime.now().microsecondsSinceEpoch).nextInt(100)));
    scaleAnimation =
        CurvedAnimation(parent: controller, curve: Curves.elasticInOut);
    fadeAnimation = Tween<double>(begin: 1, end: .98).animate(scaleAnimation);
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reverse();
      }
//      else if (status == AnimationStatus.dismissed) {
//        controller.forward();
//      }
    });

    controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    controller.forward();
    return ScaleTransition(
      scale: fadeAnimation,
      child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            controller.forward();
            if (widget.onTap != null)
              Future.delayed(Duration(milliseconds: 200), () {
                mounted ? widget.onTap() : null;
              });
          },
          child: widget.child),
    );
  }
}
