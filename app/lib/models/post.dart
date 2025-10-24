import 'package:app/state/feed.dart';
import 'package:json_annotation/json_annotation.dart';

import 'transaction.dart';

part 'post.g.dart';

@JsonSerializable()
class Post {
  final String id;
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
  final DateTime createdAt;
  final DateTime updatedAt;

  const Post({
    required this.id,
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
    required this.createdAt,
    required this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);

  Map<String, dynamic> toJson() => _$PostToJson(this);

  Post copyWith({
    String? id,
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
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Post(
      id: id ?? this.id,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Post &&
        other.id == id &&
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
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
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
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'Post(id: $id, userName: $userName, userId: $userId, content: $content, userAvatarUrl: $userAvatarUrl, userInitials: $userInitials, likeCount: $likeCount, dislikeCount: $dislikeCount, commentCount: $commentCount, transaction: $transaction, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
