// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';

class HeartAnimationWidget extends StatefulWidget {
  final Widget child;
  final bool isAnimating;
  final bool alwaysAnimate;
  final Duration duration;
  final VoidCallback? onEnd;

  const HeartAnimationWidget(
      {Key? key,
      required this.child,
      required this.isAnimating,
      this.alwaysAnimate = false,
      this.duration = const Duration(microseconds: 150),
      this.onEnd})
      : super(key: key);
  @override
  _HeartAnimationWidget createState() => _HeartAnimationWidget();
}

class _HeartAnimationWidget extends State<HeartAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scale;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    final halfDuration = widget.duration.inMicroseconds;
    controller = AnimationController(
        vsync: this, duration: Duration(microseconds: halfDuration));

    scale = Tween<double>(begin: 1, end: 1.2).animate(controller);
  }

  @override
  void didUpdateWidget(covariant HeartAnimationWidget oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);

    if (widget.isAnimating != oldWidget.isAnimating) {
      doAnimation();
    }
  }

  Future doAnimation() async {
    if (widget.isAnimating || widget.alwaysAnimate) {
      await controller.forward();
      await controller.reverse();
      await Future.delayed(Duration(milliseconds: 400));
      if (widget.onEnd != null) {
        widget.onEnd!();
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    super.dispose();
  }

  @override // แสดง UI
  Widget build(BuildContext context) => ScaleTransition(
        scale: scale,
        child: widget.child,
      );
}
