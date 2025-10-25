import 'package:app/design/avatar.dart';
import 'package:app/design/avatar_blockies.dart';
import 'package:app/utils/address.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flywind/flywind.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key, this.profile, this.accountAddress});

  final dynamic profile;
  final String? accountAddress;

  void _copyAddressToClipboard(BuildContext context) {
    if (accountAddress != null) {
      Clipboard.setData(ClipboardData(text: accountAddress!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Address copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlyBox(
      children: [
        // Centered title
        FlyBox(
          child: FlyText('Comunifi Team').text('lg').color('white'),
        ).justify('center').items('center'),

        // Copy address button (center-right)
        if (accountAddress != null)
          FlyBox(
            child: GestureDetector(
              onTap: () => _copyAddressToClipboard(context),
              child: FlyBox(
                children: [
                  const Icon(Icons.copy, color: Colors.white, size: 18),
                ],
              ).px('s2').py('s1').bg('teal600').rounded('md'),
            ),
          ).justify('center').items('center').right('s12'),

        // Right side avatar
        FlyBox(
          child: FlyAvatar(
            size: AvatarSize.sm,
            shape: AvatarShape.circular,
            child: profile == null
                ? FlyAvatarBlockies(
                    address:
                        '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6', // Current user's address
                    size: AvatarSize.sm,
                    shape: AvatarShape.circular,
                    fallbackText: AddressUtils.getAddressInitials(
                      '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
                    ),
                  )
                : Image.network(
                    profile.image,
                    errorBuilder: (_, __, ___) => FlyAvatarBlockies(
                      address:
                          '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6', // Current user's address
                      size: AvatarSize.sm,
                      shape: AvatarShape.circular,
                      fallbackText: AddressUtils.getAddressInitials(
                        '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
                      ),
                    ),
                  ),
          ),
        ).justify('center').items('center').right('s4'),
      ],
    ).stack().px('s4').py('s3').bg('teal500');
  }
}
