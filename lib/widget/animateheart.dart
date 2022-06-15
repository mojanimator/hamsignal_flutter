import 'package:flutter/material.dart';

class AnimateHeart extends StatefulWidget {
  final Widget? child;

  final repeat;

  AnimateHeart({Key? key, this.child, this.repeat = false});

  @override
  _AnimateHeartState createState() => _AnimateHeartState();
}

class _AnimateHeartState extends State<AnimateHeart>
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
        vsync: this, duration: Duration(milliseconds:widget.repeat? 3000:1000));

    // animation_rotation = Tween<double>(
    //   begin: 0.0,
    //   end: 1.0,
    // ).animate(CurvedAnimation(
    //     parent: controller, curve: Interval(0.0, 1.0, curve: Curves.linear)));

    animation_radius_in = Tween<double>(
      begin: .8,
      end: 1,
    ).animate(CurvedAnimation(
        parent: controller, curve: Interval(.5, 1, curve: Curves.elasticIn)));

    animation_radius_out = Tween<double>(
      begin: 1,
      end: .8,
    ).animate(CurvedAnimation(
        parent: controller, curve: Interval(0, .5, curve: Curves.elasticOut)));

    controller.addListener(() {
      setState(() {
        if (controller.value >=  0.5  && controller.value <= 1.0) {
          radius = animation_radius_in.value * initialRadius;
        } else if (controller.value >= 0.0 && controller.value <= 0.5) {
          radius = animation_radius_out.value * initialRadius;
        }
      });
    });

    animate(widget.repeat);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Transform.scale(
      scale: radius,
      child: widget.child!,
    ));
  }

  void animate(repeat) async{
    if(repeat){
      controller.repeat();
    }else{
       await controller.forward();
       // controller.reverse();

    }
  }
}
