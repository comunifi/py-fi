// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) => Post(
  id: json['id'] as String,
  userName: json['userName'] as String,
  userId: json['userId'] as String,
  content: json['content'] as String,
  userAvatarUrl: json['userAvatarUrl'] as String?,
  userInitials: json['userInitials'] as String?,
  likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
  dislikeCount: (json['dislikeCount'] as num?)?.toInt() ?? 0,
  commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
  transaction: json['transaction'] == null
      ? null
      : Transaction.fromJson(json['transaction'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
  'id': instance.id,
  'userName': instance.userName,
  'userId': instance.userId,
  'content': instance.content,
  'userAvatarUrl': instance.userAvatarUrl,
  'userInitials': instance.userInitials,
  'likeCount': instance.likeCount,
  'dislikeCount': instance.dislikeCount,
  'commentCount': instance.commentCount,
  'transaction': instance.transaction,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
