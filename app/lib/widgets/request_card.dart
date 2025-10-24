import 'package:flutter/cupertino.dart';
import 'package:flywind/flywind.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../design/avatar.dart';
import '../design/avatar_blockies.dart';
import '../design/button.dart';
import '../design/card.dart';
import '../utils/address.dart';
import 'amount.dart';

class RequestTransactionCard extends StatelessWidget {
  const RequestTransactionCard({
    super.key,
    required this.senderName,
    required this.senderAddress,
    required this.recipientName,
    required this.recipientAddress,
    required this.amount,
    required this.timeAgo,
    this.senderAvatarUrl,
    this.senderInitials,
    this.recipientAvatarUrl,
    this.recipientInitials,
    this.status = 'Request Pending',
    this.onBackTap,
    this.onDeleteTap,
    this.onFulfillRequest,
  });

  final String senderName;
  final String senderAddress;
  final String recipientName;
  final String recipientAddress;
  final String amount;
  final String timeAgo;
  final String? senderAvatarUrl;
  final String? senderInitials;
  final String? recipientAvatarUrl;
  final String? recipientInitials;
  final String status;
  final VoidCallback? onBackTap;
  final VoidCallback? onDeleteTap;
  final VoidCallback? onFulfillRequest;

  @override
  Widget build(BuildContext context) {
    return FlyCardWithHeader(
      title: 'Request Pending',
      showBackButton: false,
      headerIcon: LucideIcons.arrowDownLeft,
      headerActionIcon: null,
      onBackTap: onBackTap,
      onHeaderActionTap: null,
      headerBackgroundColor: 'gray100',
      cardBackgroundColor: 'white',
      children: [
        // From and To info in a row
        FlyBox(
          children: [
            // From info
            FlyBox(
              children: [
                FlyAvatar(
                  size: AvatarSize.sm,
                  shape: AvatarShape.circular,
                  child: senderAvatarUrl != null
                      ? Image.network(
                          senderAvatarUrl!,
                          errorBuilder: (_, __, ___) => FlyAvatarBlockies(
                            address: senderAddress,
                            size: AvatarSize.sm,
                            shape: AvatarShape.circular,
                            fallbackText: senderInitials ??
                                AddressUtils.getAddressInitials(senderAddress),
                          ),
                        )
                      : FlyAvatarBlockies(
                          address: senderAddress,
                          size: AvatarSize.sm,
                          shape: AvatarShape.circular,
                          fallbackText: senderInitials ??
                              AddressUtils.getAddressInitials(senderAddress),
                        ),
                ),
                FlyBox(
                  children: [
                    FlyText('from').text('xs').color('gray500'),
                    FlyText(
                      AddressUtils.truncateIfAddress(senderName),
                    ).text('sm').weight('medium').color('gray800'),
                  ],
                ).col().gap('s1'),
              ],
            ).row().items('center').gap('s2'),
            
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
          ],
        ).row().items('center').gap('s6').mb('s3'),

        // Amount info with PayPal image
        Amount(
          amount: amount,
          currency: 'PYUSD',
          label: 'amount',
        ),

        // Status and buttons
        if (status == 'Request Pending') ...[
          FlyButton(
            onTap: () {
              _showFulfillConfirmation(context);
            },
            variant: ButtonVariant.solid,
            buttonColor: ButtonColor.primary,
            child: FlyText(
              'Fulfill Request',
            ).text('sm').weight('bold').color('white'),
          ).w('auto').py('s3').rounded('md').mt('s4'),
        ],
        if (status == 'In Progress') ...[CupertinoActivityIndicator()],
        if (status == 'Request Complete') ...[
          FlyText(
            'Request Complete',
          ).text('sm').weight('medium').color('green600'),
        ],
      ],
    );
  }

  void _showFulfillConfirmation(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: FlyText(
          'Confirm Transfer',
        ).text('lg').weight('bold').color('gray900'),
        content: FlyText(
          'Are you sure you want to transfer $amount PYUSD to $senderName?',
        ).color('gray700'),
        actions: [
          CupertinoDialogAction(
            child: FlyText('Cancel').color('gray600'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: FlyText('Transfer').color('purple600'),
            onPressed: () {
              Navigator.pop(context);
              print('Transfer confirmed: $amount PYUSD to $senderName');
              // Call the original callback if provided
              if (onFulfillRequest != null) {
                onFulfillRequest!();
              }
            },
          ),
        ],
      ),
    );
  }
}
