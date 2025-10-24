import 'package:app/design/button.dart';
import 'package:app/widgets/balance.dart';
import 'package:flutter/material.dart';
import 'package:flywind/flywind.dart';
import 'package:lucide_icons/lucide_icons.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({
    super.key,
    required this.balance,
    required this.onCreatePost,
  });

  final String? balance;
  final VoidCallback onCreatePost;

  @override
  Widget build(BuildContext context) {
    return FlyBox(
      child: FlyBox(
        children: [
          // Balance card
          Balance(balance: balance),

          // Add button
          FlyButton(
            onTap: onCreatePost,
            buttonColor: ButtonColor.primary,
            variant: ButtonVariant.solid,
            child: FlyIcon(LucideIcons.plus).color('white'),
          ),
        ],
      ).row().items('center').justify('between').px('s4').py('s3'),
    ).bg('white').borderT(1).borderColor('gray200');
  }
}
