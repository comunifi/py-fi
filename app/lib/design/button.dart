import 'package:flutter/material.dart';
import 'package:flywind/flywind.dart';

import 'spinner.dart';

enum ButtonColor {
  primary, // Purple primary buttons - purple500 bg, white text
  secondary, // Gray secondary buttons - gray100 bg, gray800 text
  error,
  success,
  warning,
  none, // No background color - transparent bg, black text
}

enum ButtonVariant {
  solid, // Solid background with no border
  soft, // Light background with no border
  outlined, // Transparent background with solid border
  dashed, // Transparent background with dashed border
  ghost, // Transparent background, no border, subtle styling
  none, // No background, no border, plain text
}

enum ButtonSize { small, medium, large }

class FlyButton extends FlyGestureDetector {
  FlyButton({
    super.key,
    super.child,
    this.buttonColor = ButtonColor.none,
    this.variant = ButtonVariant.none,
    this.size = ButtonSize.medium,
    this.isLoading = false,
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
    super.flyStyle,
    super.onTapDown,
    super.onTapUp,
    super.onTapCancel,
    super.onTap,
    super.onDoubleTap,
    super.onLongPress,
    super.onLongPressStart,
    super.onLongPressEnd,
    super.onLongPressMoveUpdate,
    super.onLongPressUp,
    super.onLongPressCancel,
  });

  final ButtonColor buttonColor;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;

  @override
  bool get hasDefaultStyle => true;

  @override
  FlyStyle getDefaultStyle(FlyStyle incomingStyle) {
    String bgColor = 'purple500';
    String textColor = 'white';
    String? borderColor;
    String? borderStyle;

    // Determine base colors based on buttonColor
    switch (buttonColor) {
      case ButtonColor.primary:
        bgColor = 'teal500';
        textColor = 'white';
        borderColor = 'teal500';
        break;
      case ButtonColor.secondary:
        bgColor = 'gray100';
        textColor = 'gray800';
        borderColor = 'gray300';
        break;
      case ButtonColor.success:
        bgColor = 'green500';
        textColor = 'white';
        borderColor = 'green500';
        break;
      case ButtonColor.error:
        bgColor = 'red500';
        textColor = 'white';
        borderColor = 'red500';
        break;
      case ButtonColor.warning:
        bgColor = 'yellow500';
        textColor = 'black';
        borderColor = 'yellow500';
        break;
      case ButtonColor.none:
        textColor = 'black';
        break;
    }

    // Apply variant styling
    switch (variant) {
      case ButtonVariant.solid:
        // Keep solid background, no border
        break;
      case ButtonVariant.soft:
        // Light background, no border
        if (buttonColor == ButtonColor.primary) {
          bgColor = 'purple100';
          textColor = 'purple700';
        } else if (buttonColor == ButtonColor.secondary) {
          bgColor = 'gray50';
          textColor = 'gray700';
        } else if (buttonColor == ButtonColor.success) {
          bgColor = 'green100';
          textColor = 'green700';
        } else if (buttonColor == ButtonColor.error) {
          bgColor = 'red100';
          textColor = 'red700';
        } else if (buttonColor == ButtonColor.warning) {
          bgColor = 'yellow100';
          textColor = 'yellow700';
        }
        break;
      case ButtonVariant.outlined:
        // Transparent background, solid border, colored text
        bgColor = 'transparent';
        if (buttonColor == ButtonColor.secondary) {
          textColor = 'gray700'; // Darker text for secondary outlined
        } else {
          textColor = borderColor ?? 'black';
        }
        break;
      case ButtonVariant.dashed:
        // Transparent background, dashed border, colored text
        bgColor = 'transparent';
        borderStyle = 'dashed';
        if (buttonColor == ButtonColor.secondary) {
          textColor = 'gray700'; // Darker text for secondary dashed
        } else {
          textColor = borderColor ?? 'black';
        }
        break;
      case ButtonVariant.ghost:
        // Transparent background, no border, subtle text
        bgColor = 'transparent';
        borderColor = null;
        if (buttonColor == ButtonColor.primary) {
          textColor = 'purple600';
        } else if (buttonColor == ButtonColor.secondary) {
          textColor = 'gray600';
        } else if (buttonColor == ButtonColor.success) {
          textColor = 'green600';
        } else if (buttonColor == ButtonColor.error) {
          textColor = 'red600';
        } else if (buttonColor == ButtonColor.warning) {
          textColor = 'yellow600';
        }
        break;
      case ButtonVariant.none:
        // No background, no border, plain text
        bgColor = 'transparent';
        borderColor = null;
        textColor = 'black';
        break;
    }

    String padding = 's3';
    switch (size) {
      case ButtonSize.small:
        padding = 's1';
        break;
      case ButtonSize.medium:
        padding = 's2';
        break;
      case ButtonSize.large:
        padding = 's3';
        break;
    }

    return incomingStyle.copyWith(
      color: incomingStyle.color ?? textColor,
      p: incomingStyle.p ?? padding,
      rounded: incomingStyle.rounded ?? 'md',
      bg: bgColor == 'transparent' ? null : (incomingStyle.bg ?? bgColor),
      border: borderColor != null ? 1 : null,
      borderColor: borderColor,
      borderStyle: borderStyle,
      layoutType: incomingStyle.layoutType ?? 'row',
      justify: incomingStyle.justify ?? 'center',
      items: incomingStyle.items ?? 'center',
      gap: incomingStyle.gap ?? 's2',
      w: incomingStyle.w ?? 'min',
    );
  }

  @override
  Widget build(BuildContext context) {
    final mergedStyle = getDefaultStyle(flyStyle);

    return FlyGestureDetector(
      key: key,
      onTap: isLoading ? null : onTap,
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
      children: children,
      child: isLoading
          ? FlyBox(
              children: [
                FlySpinner(FlyIcon(Icons.refresh), durationMs: 1000),
                FlyText('Loading...')
                    .color(mergedStyle.color ?? 'white')
                    .text('sm')
                    .weight('medium'),
              ],
            ).row().items('center').gap('s2')
          : child,
    );
  }

  @override
  FlyButton Function(FlyStyle newStyle) get copyWith => (newStyle) {
    return FlyButton(
      key: key,
      buttonColor: buttonColor,
      variant: variant,
      size: size,
      isLoading: isLoading,
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
      flyStyle: newStyle,
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onTapCancel: onTapCancel,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      onLongPressStart: onLongPressStart,
      onLongPressEnd: onLongPressEnd,
      onLongPressMoveUpdate: onLongPressMoveUpdate,
      onLongPressUp: onLongPressUp,
      onLongPressCancel: onLongPressCancel,
      children: children,
      child: child,
    );
  };
}
