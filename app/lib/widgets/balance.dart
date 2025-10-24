import 'package:flutter/material.dart';
import 'package:flywind/flywind.dart';

class Balance extends StatelessWidget {
  const Balance({
    super.key,
    required this.balance,
  });

  final String? balance;

  @override
  Widget build(BuildContext context) {
    return FlyBox(
      children: [
        FlyImage(
          assetPath: 'assets/icons/paypal.png',
          width: 42,
          height: 42,
        ),
        FlyBox(
          children: [
            FlyText('balance').text('xs').color('gray600'),
            FlyText(
              '${balance ?? '0.00'} PYUSD',
            ).text('lg').weight('bold').color('gray900'),
          ],
        ),
      ],
    ).row().gap('s2').px('s3').py('s2').bg('white').rounded('lg');
  }
}
