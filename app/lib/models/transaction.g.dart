// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) => Transaction(
  senderName: json['senderName'] as String,
  amount: json['amount'] as String,
  timeAgo: json['timeAgo'] as String,
  senderAvatarUrl: json['senderAvatarUrl'] as String?,
  senderInitials: json['senderInitials'] as String?,
);

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'senderName': instance.senderName,
      'amount': instance.amount,
      'timeAgo': instance.timeAgo,
      'senderAvatarUrl': instance.senderAvatarUrl,
      'senderInitials': instance.senderInitials,
    };
