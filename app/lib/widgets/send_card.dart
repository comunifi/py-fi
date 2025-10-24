import 'package:flutter/cupertino.dart';
import 'package:flywind/flywind.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../design/avatar.dart';
import '../design/avatar_blockies.dart';
import '../design/card.dart';
import '../utils/address.dart';
import 'amount.dart';

class SendTransactionCard extends StatelessWidget {
  const SendTransactionCard({
    super.key,
    required this.recipientName,
    required this.recipientAddress,
    required this.amount,
    required this.timeAgo,
    this.recipientAvatarUrl,
    this.recipientInitials,
    this.status = 'Send Complete',
    this.onBackTap,
    this.onDeleteTap,
  });

  final String recipientName;
  final String recipientAddress;
  final String amount;
  final String timeAgo;
  final String? recipientAvatarUrl;
  final String? recipientInitials;
  final String status;
  final VoidCallback? onBackTap;
  final VoidCallback? onDeleteTap;

  @override
  Widget build(BuildContext context) {
    return FlyCardWithHeader(
      title: 'Send Complete',
      showBackButton: false,
      headerIcon: LucideIcons.arrowUpRight,
      headerActionIcon: null,
      onBackTap: onBackTap,
      onHeaderActionTap: null,
      headerBackgroundColor: 'gray100',
      cardBackgroundColor: 'white',
      children: [
        // To and Amount info in a row
        FlyBox(
          children: [
            // To info
            FlyBox(
              children: [
                FlyAvatar(
                  size: AvatarSize.sm,
                  shape: AvatarShape.circular,
                  child: recipientAvatarUrl != null
                      ? Image.network(
                          recipientAvatarUrl!,
                          errorBuilder: (_, __, ___) => FlyAvatarBlockies(
                            address: recipientAddress,
                            size: AvatarSize.sm,
                            shape: AvatarShape.circular,
                            fallbackText: recipientInitials ??
                                AddressUtils.getAddressInitials(recipientAddress),
                          ),
                        )
                      : FlyAvatarBlockies(
                          address: recipientAddress,
                          size: AvatarSize.sm,
                          shape: AvatarShape.circular,
                          fallbackText: recipientInitials ??
                              AddressUtils.getAddressInitials(recipientAddress),
                        ),
                ),
                FlyBox(
                  children: [
                    FlyText('to').text('xs').color('gray500'),
                    FlyText(
                      AddressUtils.truncateIfAddress(recipientName),
                    ).text('sm').weight('medium').color('gray800'),
                  ],
                ).col().gap('s1'),
              ],
            ).row().items('center').gap('s2'),
            
            // Amount info with PayPal image
            Amount(
              amount: amount,
              currency: 'PYUSD',
              label: 'amount',
            ),
          ],
        ).row().items('center').gap('s6').mb('s3'),
      ],
    );
  }

}
