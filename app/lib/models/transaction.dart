import 'package:json_annotation/json_annotation.dart';

part 'transaction.g.dart';

@JsonSerializable()
class Transaction {
  final String senderName;
  final String amount;
  final String timeAgo;
  final String? senderAvatarUrl;
  final String? senderInitials;

  const Transaction({
    required this.senderName,
    required this.amount,
    required this.timeAgo,
    this.senderAvatarUrl,
    this.senderInitials,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionToJson(this);

  Transaction copyWith({
    String? senderName,
    String? amount,
    String? timeAgo,
    String? senderAvatarUrl,
    String? senderInitials,
  }) {
    return Transaction(
      senderName: senderName ?? this.senderName,
      amount: amount ?? this.amount,
      timeAgo: timeAgo ?? this.timeAgo,
      senderAvatarUrl: senderAvatarUrl ?? this.senderAvatarUrl,
      senderInitials: senderInitials ?? this.senderInitials,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction &&
        other.senderName == senderName &&
        other.amount == amount &&
        other.timeAgo == timeAgo &&
        other.senderAvatarUrl == senderAvatarUrl &&
        other.senderInitials == senderInitials;
  }

  @override
  int get hashCode {
    return Object.hash(
      senderName,
      amount,
      timeAgo,
      senderAvatarUrl,
      senderInitials,
    );
  }

  @override
  String toString() {
    return 'Transaction(senderName: $senderName, amount: $amount, timeAgo: $timeAgo, senderAvatarUrl: $senderAvatarUrl, senderInitials: $senderInitials)';
  }
}
