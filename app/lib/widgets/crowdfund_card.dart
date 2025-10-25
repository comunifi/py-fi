import 'package:flutter/cupertino.dart';
import 'package:flywind/flywind.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../design/avatar.dart';
import '../design/avatar_blockies.dart';
import '../design/button.dart';
import '../design/card.dart';
import '../utils/address.dart';
import 'amount.dart';

class CrowdfundTransactionCard extends StatelessWidget {
  const CrowdfundTransactionCard({
    super.key,
    required this.recipientName,
    required this.recipientAddress,
    required this.goalAmount,
    required this.timeAgo,
    this.recipientAvatarUrl,
    this.recipientInitials,
    this.currentAmount = '0',
    this.status = 'Crowdfund In Progress',
    this.isClaiming = false,
    this.onBackTap,
    this.onDeleteTap,
    this.onContribute,
    this.onClaim,
  });

  final String recipientName;
  final String recipientAddress;
  final String goalAmount;
  final String timeAgo;
  final String? recipientAvatarUrl;
  final String? recipientInitials;
  final String currentAmount;
  final String status;
  final bool isClaiming;
  final VoidCallback? onBackTap;
  final VoidCallback? onDeleteTap;
  final VoidCallback? onContribute;
  final VoidCallback? onClaim;

  @override
  Widget build(BuildContext context) {
    return FlyCardWithHeader(
      title: 'Crowdfund In Progress',
      showBackButton: false,
      headerIcon: LucideIcons.target,
      headerActionIcon: null,
      onBackTap: onBackTap,
      onHeaderActionTap: null,
      headerBackgroundColor: 'gray100',
      cardBackgroundColor: 'white',
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
                        fallbackText:
                            recipientInitials ??
                            AddressUtils.getAddressInitials(recipientAddress),
                      ),
                    )
                  : FlyAvatarBlockies(
                      address: recipientAddress,
                      size: AvatarSize.sm,
                      shape: AvatarShape.circular,
                      fallbackText:
                          recipientInitials ??
                          AddressUtils.getAddressInitials(recipientAddress),
                    ),
            ),
            FlyBox(
              children: [
                FlyText('to').text('xs').color('gray500'),
                FlyText(
                  '@${AddressUtils.truncateIfAddress(recipientName)}',
                ).text('sm').weight('medium').color('gray800'),
              ],
            ).col().gap('s1'),
          ],
        ).row().items('center').gap('s2').mb('s3'),

        // Goal and Progress info in a row
        FlyBox(
          children: [
            // Goal info with PayPal image
            Amount(amount: goalAmount, currency: 'PYUSD', label: 'goal'),

            // Progress info
            Amount(
              amount: currentAmount,
              currency: 'PYUSD',
              label: 'progress',
              showIcon: false,
            ),
          ],
        ).row().items('center').gap('s6').mb('s3'),

        // Status-specific content
        if (status == 'Crowdfund In Progress') ...[
          // Progress bar showing amount funded
          FlyBox(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _getProgressPercentage(),
                child: Container(
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBlue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ).mt('s4'),
          FlyButton(
            onTap: () {
              print('Contribute to crowdfund');
              if (onContribute != null) onContribute!();
            },
            variant: ButtonVariant.solid,
            buttonColor: ButtonColor.primary,
            child: FlyText(
              'Contribute',
            ).text('sm').weight('bold').color('white'),
          ).w('auto').py('s3').rounded('md').mt('s4'),
        ],
        if (status == 'Crowdfund Successful') ...[
          FlyButton(
            onTap: isClaiming
                ? null
                : () {
                    print('Claim crowdfund');
                    if (onClaim != null) onClaim!();
                  },
            variant: ButtonVariant.solid,
            buttonColor: ButtonColor.primary,
            child: isClaiming
                ? FlyBox(
                    child: CupertinoActivityIndicator(),
                  ).row().items('center').justify('center')
                : FlyText('Claim').text('sm').weight('bold').color('white'),
          ).w('auto').py('s3').rounded('md').mt('s4'),
        ],
        if (status == 'Crowdfund Complete') ...[
          FlyText(
            'Crowdfund Complete',
          ).text('sm').weight('medium').color('green600').mt('s4'),
        ],
        if (status == 'Crowdfund Claimed') ...[
          FlyText(
            'Crowdfund Claimed',
          ).text('sm').weight('medium').color('green600').mt('s4'),
        ],
      ],
    );
  }

  double _getProgressPercentage() {
    final current = double.tryParse(currentAmount) ?? 0.0;
    final goal = double.tryParse(goalAmount) ?? 1.0;
    return (current / goal).clamp(0.0, 1.0);
  }
}
