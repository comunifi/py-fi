import 'package:flutter/material.dart';
import 'package:blockies/blockies.dart';

import 'avatar.dart';

class FlyAvatarBlockies extends StatelessWidget {
  FlyAvatarBlockies({
    super.key,
    required this.address,
    this.size,
    this.shape,
    this.fallbackText,
    this.fallbackIcon,
  });

  final String address;
  final AvatarSize? size;
  final AvatarShape? shape;
  final String? fallbackText;
  final IconData? fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final avatarSize = _getAvatarSize(size ?? AvatarSize.md);
    final borderRadius = _getBorderRadius(shape ?? AvatarShape.circular);

    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: avatarSize,
        height: avatarSize,
        child: Blockies(
          seed: address,
          size: _getBlockiesSize(avatarSize),
        ),
      ),
    );
  }

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

  int _getBlockiesSize(double avatarSize) {
    // Convert avatar size to blockies size (8x8 blocks)
    // Blockies generates 8x8 blocks by default, so we use 8
    return 8;
  }
}
