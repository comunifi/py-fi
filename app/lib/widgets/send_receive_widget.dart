import 'package:app/design/avatar.dart';
import 'package:app/design/avatar_blockies.dart';
import 'package:app/services/wallet/contracts/profile.dart';
import 'package:app/state/profile.dart';
import 'package:app/utils/address.dart';
import 'package:flutter/cupertino.dart';
import 'package:flywind/flywind.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../design/button.dart';
import '../design/card.dart';

class SendReceiveWidget extends StatefulWidget {
  final Function() onPost;
  final Function(String, String, double) onRequest;
  final Function() onSendBack;

  const SendReceiveWidget({
    super.key,
    required this.onPost,
    required this.onRequest,
    required this.onSendBack,
  });

  @override
  State<SendReceiveWidget> createState() => _SendReceiveWidgetState();
}

class _SendReceiveWidgetState extends State<SendReceiveWidget> {
  TransactionEntry? _transaction;
  final TextEditingController _amountController = TextEditingController();
  String _mode = 'none'; // 'send', 'receive', or 'none'

  late ProfileState _profileState;

  @override
  void initState() {
    super.initState();

    _profileState = context.read<ProfileState>();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void handleTextInput(String text) {
    _profileState.searchFromProfile(text);
  }

  @override
  Widget build(BuildContext context) {
    final fromProfile = context.watch<ProfileState>().fromProfile;
    final loadingFromProfile = context.watch<ProfileState>().loadingFromProfile;

    return FlyBox(
      children: [
        // Transaction entry (only show if not 'none')
        if (_mode != 'none')
          _buildTransactionEntry(
            _transaction!,
            _mode == 'send',
            fromProfile,
            loadingFromProfile,
          ),

        // Action buttons
        _buildActionButtons(fromProfile),
      ],
    ).col().gap('s3');
  }

  Widget _buildTransactionEntry(
    TransactionEntry transaction,
    bool isSend,
    fromProfile,
    bool loadingFromProfile,
  ) {
    return FlyCardWithHeader(
      title: isSend ? 'Send Tokens' : 'Request Tokens',
      headerIcon: isSend ? LucideIcons.arrowUpRight : LucideIcons.arrowDownLeft,
      headerActionIcon: LucideIcons.trash2,
      onHeaderActionTap: () {
        setState(() {
          _mode = 'none';
          _transaction = null;
        });
      },
      headerBackgroundColor: 'gray100',
      cardBackgroundColor: 'gray50',
      children: [
        // Main content (two rows)
        FlyBox(
          children: [
            // First row: Recipient dropdown
            FlyBox(
              children: [
                FlyText(isSend ? 'to' : 'from').text('sm').color('gray600'),
                // FlyButton(
                //   onTap: () => _showRecipientSelection(transaction),
                //   variant: ButtonVariant.outlined,
                //   buttonColor: ButtonColor.secondary,
                //   child: FlyBox(
                //     children: [
                //       FlyText(
                //         AddressUtils.truncateAddress(transaction.recipient),
                //       ).text('sm').weight('medium').color('gray900'),
                //       FlyIcon(
                //         LucideIcons.chevronDown,
                //       ).color('gray600').w('s3').h('s3'),
                //     ],
                //   ).row().items('center').gap('s1'),
                // ),
                if (loadingFromProfile) CupertinoActivityIndicator(),
                Expanded(
                  child: FlyBox(
                    children: [
                      CupertinoTextField(
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 14),
                        onChanged: (value) {
                          handleTextInput(value);
                        },
                      ),
                    ],
                  ),
                ),
                if (fromProfile != null)
                  FlyBox(
                    child: Image.network(
                      fromProfile.image,
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
                  ).h('s8').w('s8'),

                if (fromProfile != null)
                  FlyText(
                    '@${fromProfile.username}',
                  ).text('sm').weight('medium').color('gray900'),
              ],
            ).row().items('center').gap('s2').justify('between'),

            // Second row: Amount input with currency display
            FlyBox(
              children: [
                FlyText('amount').text('sm').color('gray600'),
                FlyBox(
                  children: [
                    // Amount input
                    FlyBox(
                          child: CupertinoTextField(
                            controller: TextEditingController(
                              text: transaction.amount.toString(),
                            ),
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 14),
                            decoration: const BoxDecoration(),
                            onChanged: (value) {
                              final amount = double.tryParse(value) ?? 0;
                              setState(() {
                                transaction.amount = amount;
                              });
                            },
                          ),
                        )
                        .w('s16')
                        .h('s8')
                        .bg('white')
                        .rounded('sm')
                        .px('s2')
                        .border(1)
                        .borderColor('gray200'),

                    // Currency display (non-interactive)
                    FlyBox(
                      child: FlyText(
                        transaction.currency,
                      ).text('sm').weight('medium').color('gray900'),
                    ).px('s3').py('s2').bg('gray100').rounded('sm'),
                  ],
                ).row().items('center').gap('s2'),
              ],
            ).row().items('center').gap('s2').justify('between'),
          ],
        ).col().gap('s3'),
      ],
    );
  }

  Widget _buildActionButtons(ProfileV1? fromProfile) {
    return FlyBox(
      children: [
        // Send button (toggles send mode)
        // FlyBox(
        //   children: [
        //   FlyButton(
        //     onTap: _toggleSend,
        //     buttonColor: _mode == 'send'
        //         ? ButtonColor.primary
        //         : ButtonColor.secondary,
        //     variant: ButtonVariant.outlined,
        //     children: [
        //       FlyIcon(LucideIcons.arrowUpRight).w('s4').h('s4'),
        //       FlyText('Send').text('sm').weight('medium'),
        //     ],
        //   ),

        // Receive button (toggles receive mode)
        FlyButton(
          onTap: _toggleReceive,
          buttonColor: _mode == 'receive'
              ? ButtonColor.primary
              : ButtonColor.secondary,
          variant: ButtonVariant.outlined,
          children: [
            FlyIcon(LucideIcons.arrowDownLeft).w('s4').h('s4'),
            FlyText('Receive').text('sm').weight('medium'),
          ],
        ),
        // ],
        // ).row().gap('s3'),

        // Post button (final action)
        FlyButton(
          onTap: () => _handlePost(fromProfile),
          variant: ButtonVariant.solid,
          buttonColor: ButtonColor.primary,
          size: ButtonSize.large,
          child: FlyIcon(LucideIcons.send).w('s4').h('s4'),
        ),
        FlyButton(
          onTap: widget.onSendBack,
          variant: ButtonVariant.solid,
          buttonColor: ButtonColor.primary,
          size: ButtonSize.large,
          child: FlyText('send back'),
        ).row().items('center').gap('s2'),
      ],
    ).row().items('center').gap('s3').justify('between');
  }

  void _toggleSend() {
    setState(() {
      if (_mode == 'send') {
        _mode = 'none';
        _transaction = null;
      } else {
        _mode = 'send';
        _transaction = TransactionEntry(
          recipient: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
          amount: 20,
          currency: 'EURe',
        );
      }
    });
  }

  void _toggleReceive() {
    setState(() {
      if (_mode == 'receive') {
        _mode = 'none';
        _transaction = null;
      } else {
        _mode = 'receive';
        _transaction = TransactionEntry(
          recipient: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
          amount: 20,
          currency: 'EURe',
        );
      }
    });
  }

  void _handlePost(ProfileV1? fromProfile) {
    if (_mode == 'none') {
      // _showDialog('Error', 'Please select Send or Receive first');
      widget.onPost();
      return;
    }

    if (_mode == 'send') {
      print(
        'Sending: ${_transaction!.amount} ${_transaction!.currency} to ${_transaction!.recipient}',
      );
    } else if (_mode == 'receive') {
      if (fromProfile == null) {
        return;
      }

      widget.onRequest(
        fromProfile.username,
        fromProfile.account,
        _transaction!.amount,
      );
    }

    _showDialog('Success', 'Transaction posted successfully!');

    // Clear transaction after successful post
    setState(() {
      _mode = 'none';
      _transaction = null;
    });
  }

  void _showDialog(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: FlyText(title)
            .text('lg')
            .weight('bold')
            .color(title == 'Error' ? 'red600' : 'green600'),
        content: FlyText(message).color('gray700'),
        actions: [
          CupertinoDialogAction(
            child: FlyText('OK').color('purple600'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class TransactionEntry {
  String recipient;
  double amount;
  String currency;

  TransactionEntry({
    required this.recipient,
    required this.amount,
    required this.currency,
  });
}
