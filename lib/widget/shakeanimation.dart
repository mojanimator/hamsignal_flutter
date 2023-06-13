import 'dart:math';

import 'package:flutter/material.dart';

class ShakeWidget extends StatefulWidget {
  bool shakeOnRebuild;
  bool repeat = false;

  ShakeWidget({
    Key? key,
    required this.child,
    this.shakeOffset = 5,
    this.shakeCount = 1,
    bool this.shakeOnRebuild = true,
    this.shakeDuration = const Duration(milliseconds: 500),
    bool this.repeat = false,
  }) {
    this.shakeDuration = Duration(milliseconds: Random().nextInt(500) + 200);
  }

  final Widget child;
  double shakeOffset;
  final int shakeCount;
  Duration shakeDuration;

  @override
  ShakeWidgetState createState() => ShakeWidgetState(shakeDuration);
}

class ShakeWidgetState extends AnimationControllerState<ShakeWidget> {
  ShakeWidgetState(Duration duration) : super(duration);

  @override
  void initState() {
    animationController.addStatusListener(_updateStatus);
    shake();
    super.initState();
  }

  @override
  void dispose() {
    animationController.removeStatusListener(_updateStatus);
    super.dispose();
  }

  void _updateStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      animationController.reset();
    }
    if (widget.repeat) animationController.repeat();
  }

  void shake() {
    if (animationController.value == 0 && widget.shakeOnRebuild) {

      animationController.forward( from: .2 );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. return an AnimatedBuilder
    shake();
    return AnimatedBuilder(
      // 2. pass our custom animation as an argument
      animation: animationController,
      // 3. optimization: pass the given child as an argument
      child: widget.child,
      builder: (context, child) {
        final sineValue =
            sin(widget.shakeCount * pi * (animationController.value));
        return Transform.translate(
          // 4. apply a translation as a function of the animation value
          offset: Offset( 0, sineValue * widget.shakeOffset),
          // 5. use the child widget
          child: child,
        );
      },
    );
  }
}

abstract class AnimationControllerState<T extends StatefulWidget>
    extends State<T> with SingleTickerProviderStateMixin {
  AnimationControllerState(this.animationDuration);

  final Duration animationDuration;
  late final animationController =
      AnimationController(vsync: this, duration: animationDuration);

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
