import 'package:flutter/material.dart';

class BlinkAnimation extends StatefulWidget {
  final Widget? child;
  final bool repeat;

  BlinkAnimation({Key? key, this.child, this.repeat = false});

  @override
  _BlinkAnimationState createState() => _BlinkAnimationState();
}

class _BlinkAnimationState extends State<BlinkAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation_rotation;
  late Animation<double> animation_radius_in;
  late Animation<double> animation_radius_out;

  final double initialRadius = 1;
  double radius = 0.0;

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 3500));

    animation_rotation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
        parent: controller, curve: Interval(0.0, 1.0, curve: Curves.linear)));

    animation_radius_in = Tween<double>(
      begin: 1.1,
      end: 0.9,
    ).animate(CurvedAnimation(
        parent: controller,
        curve: Interval(0.5, 1.0, curve: Curves.elasticIn)));

    animation_radius_out = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 0.5, curve: Curves.elasticOut)));

    controller.addListener(() {
      setState(() {
        if (controller.value >= 0.75 && controller.value <= 1.0) {
          radius = animation_radius_in.value * initialRadius;
        } else if (controller.value >= 0.0 && controller.value <= 0.25) {
          radius = animation_radius_out.value * initialRadius;
        }
      });
    });
    if(widget.repeat)
    controller.repeat();
else
  controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        // width: 100.0,
        // height: 100.0,
        child: Center(
//          child: Transform.scale(
//            scale: radius,
//            child: Stack(children: <Widget>[
//              widget.floatingActionButton,
//            ]),
//          ),
      child: Stack(
        children: <Widget>[
          Transform.scale(
            scale: radius,
            child: Stack(children: <Widget>[
              widget.child!,
            ]),
          ),
        ],
      ),
    ));
  }
}

class Dot extends StatelessWidget {
  final Color? color;
  final double? radius;

  Dot({this.color, this.radius});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: this.radius,
        height: this.radius,
        decoration: BoxDecoration(
          color: this.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
