import 'package:flutter/material.dart';
import 'package:flywind/flywind.dart';

class FlySpinner extends FlyBox {
  FlySpinner(
    this.child, {
    super.key,
    super.children,
    super.alignment,
    super.padding,
    super.margin,
    super.decoration,
    super.foregroundDecoration,
    super.width,
    super.height,
    super.constraints,
    super.transform,
    super.transformAlignment,
    super.clipBehavior,
    this.durationMs = 1000,
    this.direction = 1,
    this.repeat = true,
    super.flyStyle,
  });

  @override
  final Widget child;
  final int durationMs;
  final int direction; // 1 for clockwise, -1 for counterclockwise
  final bool repeat;

  @override
  FlyStyle getDefaultStyle(FlyStyle incomingStyle) {
    return incomingStyle;
  }

  @override
  FlySpinner Function(FlyStyle newStyle) get copyWith => (newStyle) {
    return FlySpinner(
      child,
      key: key,
      alignment: alignment,
      padding: padding,
      margin: margin,
      decoration: decoration,
      foregroundDecoration: foregroundDecoration,
      width: width,
      height: height,
      constraints: constraints,
      transform: transform,
      transformAlignment: transformAlignment,
      clipBehavior: clipBehavior,
      durationMs: durationMs,
      direction: direction,
      repeat: repeat,
      flyStyle: newStyle,
      children: children,
    );
  };

  @override
  Widget build(BuildContext context) {
    final mergedStyle = getDefaultStyle(flyStyle);

    // Create the animated content (just the child, not the container)
    final animatedContent = _FlySpinnerWrapper(
      durationMs: durationMs,
      direction: direction,
      repeat: repeat,
      child: child,
    );

    // Apply all FlyBox utilities to the container (not the animated content)
    return FlyBox(
      key: key,
      child: animatedContent,
      children: children,
      alignment: alignment,
      padding: padding,
      margin: margin,
      decoration: decoration,
      foregroundDecoration: foregroundDecoration,
      width: width,
      height: height,
      constraints: constraints,
      transform: transform,
      transformAlignment: transformAlignment,
      clipBehavior: clipBehavior,
      flyStyle: mergedStyle,
    ).build(context);
  }
}

class _FlySpinnerWrapper extends StatefulWidget {
  const _FlySpinnerWrapper({
    required this.child,
    required this.durationMs,
    required this.direction,
    required this.repeat,
  });

  final Widget child;
  final int durationMs;
  final int direction;
  final bool repeat;

  @override
  State<_FlySpinnerWrapper> createState() => _FlySpinnerWrapperState();
}

class _FlySpinnerWrapperState extends State<_FlySpinnerWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.durationMs),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: 2 * 3.14159 * widget.direction, // Full rotation
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    if (widget.repeat) {
      _controller.repeat();
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(angle: _animation.value, child: widget.child);
      },
    );
  }
}
