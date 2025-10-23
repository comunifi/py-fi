import 'package:flutter/material.dart';
import 'package:flywind/flywind.dart';

import 'spinner.dart';

enum AvatarSize { xs, sm, md, lg, xl }

enum AvatarShape { circular, square, rounded }

class AvatarContext {
  final AvatarSize size;
  final AvatarShape shape;
  final bool isLoading;

  const AvatarContext({
    required this.size,
    required this.shape,
    this.isLoading = false,
  });
}

class _AvatarInheritedWidget extends InheritedWidget {
  final AvatarContext avatarContext;

  const _AvatarInheritedWidget({
    required this.avatarContext,
    required super.child,
  });

  @override
  bool updateShouldNotify(_AvatarInheritedWidget oldWidget) {
    return avatarContext != oldWidget.avatarContext;
  }

  static AvatarContext? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_AvatarInheritedWidget>()
        ?.avatarContext;
  }
}

class FlyAvatar extends FlyBox {
  FlyAvatar({
    super.key,
    super.child,
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
    required this.size,
    required this.shape,
    this.isLoading = false,
  });

  final AvatarSize size;
  final AvatarShape shape;
  final bool isLoading;

  bool get hasDefaultStyle => true;

  @override
  FlyStyle getDefaultStyle(FlyStyle incomingStyle) {
    return incomingStyle.copyWith(
      w: _getSize(),
      h: _getSize(),
      rounded: _getRounded(),
      bg: 'gray200',
    );
  }

  @override
  Widget build(BuildContext context) {
    final mergedStyle = getDefaultStyle(flyStyle);
    final avatarContext = AvatarContext(
      size: size,
      shape: shape,
      isLoading: isLoading,
    );

    Widget content =
        child ??
        (children != null && children!.isNotEmpty
            ? FlyBox(
                children: children!,
              ).col().items('center').justify('center')
            : const SizedBox.shrink());

    if (isLoading) {
      content = FlySpinner(
        FlyIcon(Icons.person),
        durationMs: 1000,
      ).color('gray500');
    }

    return _AvatarInheritedWidget(
      avatarContext: avatarContext,
      child: FlyBox(
        key: key,
        child: content,
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
      ),
    );
  }

  @override
  FlyAvatar Function(FlyStyle newStyle) get copyWith => (newStyle) {
    return FlyAvatar(
      key: key,
      child: child,
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
      flyStyle: newStyle,
      size: size,
      shape: shape,
      isLoading: isLoading,
    );
  };

  double _getSize() {
    switch (size) {
      case AvatarSize.xs:
        return 24.0;
      case AvatarSize.sm:
        return 32.0;
      case AvatarSize.md:
        return 40.0;
      case AvatarSize.lg:
        return 56.0;
      case AvatarSize.xl:
        return 80.0;
    }
  }

  String _getRounded() {
    switch (shape) {
      case AvatarShape.circular:
        return '999px';
      case AvatarShape.square:
        return '0px';
      case AvatarShape.rounded:
        return 'md';
    }
  }
}

class FlyAvatarImage extends FlyBox {
  FlyAvatarImage({
    super.key,
    super.child,
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
    this.imageUrl,
    this.assetPath,
    this.onLoadingStateChange,
  });

  final String? imageUrl;
  final String? assetPath;
  final ValueChanged<bool>? onLoadingStateChange;

  bool get hasDefaultStyle => false;

  @override
  Widget build(BuildContext context) {
    final avatarContext = _AvatarInheritedWidget.of(context);
    if (avatarContext == null) {
      return const SizedBox.shrink();
    }

    final avatarSize = _getAvatarSize(avatarContext.size);
    final borderRadius = _getBorderRadius(avatarContext.shape);

    return FlyImage(
      key: key,
      imageUrl: imageUrl,
      assetPath: assetPath,
      onLoadingStateChange: onLoadingStateChange,
      fit: BoxFit.cover,
      width: width ?? avatarSize,
      height: height ?? avatarSize,
      alignment: alignment,
      flyStyle: flyStyle.copyWith(
        rounded: borderRadius == BorderRadius.zero
            ? null
            : borderRadius == BorderRadius.circular(999)
            ? '999px'
            : 'md',
      ),
      loadingWidget: FlySpinner(
        FlyIcon(Icons.image),
        durationMs: 1000,
      ).color('gray500'),
      errorWidget: child ?? const SizedBox.shrink(),
    );
  }

  @override
  FlyAvatarImage Function(FlyStyle newStyle) get copyWith => (newStyle) {
    return FlyAvatarImage(
      key: key,
      child: child,
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
      flyStyle: newStyle,
      imageUrl: imageUrl,
      assetPath: assetPath,
      onLoadingStateChange: onLoadingStateChange,
    );
  };

  double _getAvatarSize(AvatarSize size) {
    switch (size) {
      case AvatarSize.xs:
        return 24.0;
      case AvatarSize.sm:
        return 32.0;
      case AvatarSize.md:
        return 40.0;
      case AvatarSize.lg:
        return 56.0;
      case AvatarSize.xl:
        return 80.0;
    }
  }

  BorderRadius _getBorderRadius(AvatarShape shape) {
    switch (shape) {
      case AvatarShape.circular:
        return BorderRadius.circular(999);
      case AvatarShape.square:
        return BorderRadius.zero;
      case AvatarShape.rounded:
        return BorderRadius.circular(8);
    }
  }
}

class FlyAvatarFallback extends FlyBox {
  FlyAvatarFallback({
    super.key,
    super.child,
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
    this.fallbackText,
    this.fallbackIcon,
  });

  final String? fallbackText;
  final IconData? fallbackIcon;

  bool get hasDefaultStyle => false;

  @override
  Widget build(BuildContext context) {
    final avatarContext = _AvatarInheritedWidget.of(context);
    if (avatarContext == null) {
      return const SizedBox.shrink();
    }

    Widget fallbackContent = child ?? const SizedBox.shrink();

    if (fallbackContent is SizedBox && fallbackContent.child == null) {
      if (fallbackText != null) {
        fallbackContent = FlyText(fallbackText!)
            .color('gray600')
            .text(_getTextSize(avatarContext.size))
            .weight('medium');
      } else if (fallbackIcon != null) {
        fallbackContent = FlyIcon(fallbackIcon!).color('gray500');
      }
    }

    return FlyBox(
      key: key,
      child: fallbackContent,
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
      flyStyle: flyStyle,
    );
  }

  @override
  FlyAvatarFallback Function(FlyStyle newStyle) get copyWith => (newStyle) {
    return FlyAvatarFallback(
      key: key,
      child: child,
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
      flyStyle: newStyle,
      fallbackText: fallbackText,
      fallbackIcon: fallbackIcon,
    );
  };

  String _getTextSize(AvatarSize size) {
    switch (size) {
      case AvatarSize.xs:
        return 'xs';
      case AvatarSize.sm:
        return 'sm';
      case AvatarSize.md:
        return 'base';
      case AvatarSize.lg:
        return 'lg';
      case AvatarSize.xl:
        return 'xl';
    }
  }
}

