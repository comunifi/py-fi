import 'package:flutter/cupertino.dart';
import 'package:flywind/flywind.dart';

import '../design/avatar.dart';

class Amount extends StatelessWidget {
  const Amount({
    super.key,
    required this.amount,
    required this.currency,
    this.label = 'amount',
    this.showIcon = true,
  });

  final String amount;
  final String currency;
  final String label;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    return FlyBox(
      children: [
        if (showIcon)
          FlyAvatar(
            size: AvatarSize.sm,
            shape: AvatarShape.circular,
            child: FlyAvatarImage(
              assetPath: 'assets/icons/paypal.png',
            ),
          ),
        FlyBox(
          children: [
            FlyText(label).text('xs').color('gray500'),
            FlyText('$amount $currency').text('sm').weight('medium').color('gray800'),
          ],
        ).col().gap('s1'),
      ],
    ).row().items('center').gap('s2');
  }
}
