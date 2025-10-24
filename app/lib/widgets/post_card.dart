import 'package:app/state/feed.dart';
import 'package:flutter/material.dart';
import 'package:flywind/flywind.dart';

import '../design/avatar.dart';
import '../design/avatar_blockies.dart';
import '../design/card.dart';
import '../utils/address.dart';
import 'transaction_card.dart';

class PostCard extends FlyCard {
  PostCard({
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
    super.flyStyle,
    required this.userAddress,
    required this.content,
    this.txRequest,
    this.userName,
    this.userAvatarUrl,
    this.userInitials,
    this.likeCount = 0,
    this.dislikeCount = 0,
    this.commentCount = 0,
    this.transaction,
    this.createdAt,
    this.onLike,
    this.onDislike,
    this.onComment,
    this.onShare,
    this.onMore,
  }) : super(variant: CardVariant.outlined, size: CardSize.medium);

  final String userAddress;
  final String content;
  final TxRequest? txRequest;
  final String? userName;
  final String? userAvatarUrl;
  final String? userInitials;
  final int likeCount;
  final int dislikeCount;
  final int commentCount;
  final TransactionCard? transaction;
  final DateTime? createdAt;
  final VoidCallback? onLike;
  final VoidCallback? onDislike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    return FlyCard(
      key: key,
      variant: CardVariant.outlined,
      size: CardSize.medium,
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
      children: [
        // Header
        _buildHeader(),

        // Content
        _buildContent(),

        // Transaction (optional)
        if (transaction != null) FlyBox(children: [transaction!]).mt('s3'),
      ],
    );
  }

  Widget _buildHeader() {
    return FlyBox(
      children: [
        // User avatar with blockies
        FlyAvatar(
          size: AvatarSize.md,
          shape: AvatarShape.circular,
          child: FlyAvatarBlockies(
            address: userAddress,
            size: AvatarSize.md,
            shape: AvatarShape.circular,
            fallbackText:
                userInitials ?? AddressUtils.getAddressInitials(userAddress),
          ),
        ),

        // User name and timestamp
        FlyBox(
          children: [
            FlyText(
              AddressUtils.truncateIfAddress(userName ?? userAddress),
            ).text('base').weight('semibold').color('gray800'),
            if (createdAt != null)
              FlyText(_formatTimestamp(createdAt!)).text('xs').color('gray400'),
          ],
        ).row().items('center').gap('s4').flex(1),
      ],
    ).row().items('center').gap('s3').mb('s2');
  }

  Widget _buildContent() {
    return FlyText(content).text('sm').color('gray700').leading('relaxed');
  }

  Widget _buildTxRequest() {
    return FlyBox(
      children: [
        FlyText(txRequest!.address).text('sm').color('gray700'),
        FlyText(txRequest!.amount.toString()).text('sm').color('gray700'),
      ],
    ).row().items('center').gap('s3').mb('s2');
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }

  @override
  PostCard Function(FlyStyle newStyle) get copyWith => (newStyle) {
    return PostCard(
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
      flyStyle: newStyle,
      userAddress: userAddress,
      content: content,
      userName: userName,
      userAvatarUrl: userAvatarUrl,
      userInitials: userInitials,
      likeCount: likeCount,
      dislikeCount: dislikeCount,
      commentCount: commentCount,
      transaction: transaction,
      createdAt: createdAt,
      onLike: onLike,
      onDislike: onDislike,
      onComment: onComment,
      onShare: onShare,
      onMore: onMore,
      children: children,
    );
  };
}
