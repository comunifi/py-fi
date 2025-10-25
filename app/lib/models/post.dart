import 'package:app/services/wallet/models/userop.dart';
import 'package:app/state/feed.dart';
import 'package:json_annotation/json_annotation.dart';

import 'transaction.dart';

part 'post.g.dart';

@JsonSerializable()
class Post {
  final String id;
  final String? replyId;
  final String userName;
  final String userId;
  final String content;
  final String? userAvatarUrl;
  final String? userInitials;
  final int likeCount;
  final int dislikeCount;
  final int commentCount;
  final Transaction? transaction;
  final TxRequest? txRequest;
  final UserOp? userOp;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Post({
    required this.id,
    this.replyId,
    required this.userName,
    required this.userId,
    required this.content,
    this.userAvatarUrl,
    this.userInitials,
    this.likeCount = 0,
    this.dislikeCount = 0,
    this.commentCount = 0,
    this.transaction,
    this.txRequest,
    this.userOp,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);

  Map<String, dynamic> toJson() => _$PostToJson(this);

  Post copyWith({
    String? id,
    String? replyId,
    String? userName,
    String? userId,
    String? content,
    String? userAvatarUrl,
    String? userInitials,
    int? likeCount,
    int? dislikeCount,
    int? commentCount,
    Transaction? transaction,
    TxRequest? txRequest,
    UserOp? userOp,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Post(
      id: id ?? this.id,
      replyId: replyId ?? this.replyId,
      userName: userName ?? this.userName,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      userInitials: userInitials ?? this.userInitials,
      likeCount: likeCount ?? this.likeCount,
      dislikeCount: dislikeCount ?? this.dislikeCount,
      commentCount: commentCount ?? this.commentCount,
      transaction: transaction ?? this.transaction,
      txRequest: txRequest ?? this.txRequest,
      userOp: userOp ?? this.userOp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Post &&
        other.id == id &&
        other.replyId == replyId &&
        other.userName == userName &&
        other.userId == userId &&
        other.content == content &&
        other.userAvatarUrl == userAvatarUrl &&
        other.userInitials == userInitials &&
        other.likeCount == likeCount &&
        other.dislikeCount == dislikeCount &&
        other.commentCount == commentCount &&
        other.transaction == transaction &&
        other.txRequest == txRequest &&
        other.userOp == userOp &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      replyId,
      userName,
      userId,
      content,
      userAvatarUrl,
      userInitials,
      likeCount,
      dislikeCount,
      commentCount,
      transaction,
      txRequest,
      userOp,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'Post(id: $id, replyId: $replyId, userName: $userName, userId: $userId, content: $content, userAvatarUrl: $userAvatarUrl, userInitials: $userInitials, likeCount: $likeCount, dislikeCount: $dislikeCount, commentCount: $commentCount, transaction: $transaction, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
