import 'package:flutter/cupertino.dart';
import 'package:flywind/flywind.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../design/sheet.dart';
import '../design/button.dart';
import '../design/card.dart';
import '../design/avatar.dart';
import '../design/avatar_blockies.dart';
import '../state/wallet.dart';
import '../state/profile.dart';
import '../services/wallet/contracts/profile.dart';
import '../utils/address.dart';
import 'balance.dart';

class SimpleNewPostScreen extends StatefulWidget {
  final Function() onSendBack;
  final Function(String, String, String, double) onRequest;
  final Function(String, String, String, double)? onContribute;
  final Function(String, String, String, double)? onCrowdfund;
  final String? contributeToUsername;
  final String? contributeToAddress;
  final double? contributeAmount;

  const SimpleNewPostScreen({
    super.key,
    required this.onSendBack,
    required this.onRequest,
    this.onContribute,
    this.onCrowdfund,
    this.contributeToUsername,
    this.contributeToAddress,
    this.contributeAmount,
  });

  @override
  State<SimpleNewPostScreen> createState() => _SimpleNewPostScreenState();
}

class _SimpleNewPostScreenState extends State<SimpleNewPostScreen> {
  final TextEditingController _postController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // Transaction state for request functionality
  TransactionEntry? _transaction;
  final TextEditingController _amountController = TextEditingController();
  String _mode =
      'none'; // 'send', 'request', 'crowdfund', 'contribute', or 'none'

  @override
  void initState() {
    super.initState();

    // Initialize contribute mode if contribute data is provided
    if (widget.onContribute != null &&
        widget.contributeToUsername != null &&
        widget.contributeToAddress != null) {
      _mode = 'contribute';
      _transaction = TransactionEntry(
        recipient: widget.contributeToAddress!,
        username: widget.contributeToUsername,
        amount: 0.0,
        currency: 'PYUSD',
      );
    }

    // Auto-focus the text input when the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _postController.dispose();
    _focusNode.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _handlePost() {
    // Handle different modes
    if (_mode == 'send' && _transaction != null) {
      handleSendBack();
    } else if (_mode == 'request' && _transaction != null) {
      handleRequest(
        _transaction!.recipient,
        _transaction!.recipient,
        _transaction!.amount,
      );
    } else if (_mode == 'contribute' && _transaction != null) {
      handleContribute(
        widget.contributeToUsername ?? _transaction!.username ?? '',
        widget.contributeToAddress ?? _transaction!.recipient,
        _transaction!.amount,
      );
    } else if (_mode == 'crowdfund' && _transaction != null) {
      final fromProfile = context.read<ProfileState>().fromProfile;

      debugPrint('Crowdfund validation:');
      debugPrint('  fromProfile: $fromProfile');
      debugPrint('  fromProfile?.username: ${fromProfile?.username}');
      debugPrint('  fromProfile?.account: ${fromProfile?.account}');
      debugPrint('  _transaction.recipient: ${_transaction!.recipient}');
      debugPrint('  _transaction.amount: ${_transaction!.amount}');

      if (fromProfile == null) {
        debugPrint('Error: Please select a recipient');
        // TODO: Show error to user
        return;
      }

      if (_transaction!.amount <= 0) {
        debugPrint('Error: Please enter a goal amount');
        // TODO: Show error to user
        return;
      }

      widget.onCrowdfund!(
        _postController.text,
        fromProfile.username,
        fromProfile.account,
        _transaction!.amount,
      );
      GoRouter.of(context).pop();
    } else {
      // Regular post
      GoRouter.of(context).pop(_postController.text);
    }
  }

  void handleSendBack() {
    widget.onSendBack();
    GoRouter.of(
      context,
    ).pop(); // here, when pop is called, the value is returned
  }

  void handleRequest(String username, String address, double amount) {
    widget.onRequest(_postController.text, username, address, amount);
    GoRouter.of(context).pop();
  }

  void handleContribute(String username, String address, double amount) {
    if (widget.onContribute != null) {
      widget.onContribute!(_postController.text, username, address, amount);
      GoRouter.of(context).pop();
    }
  }

  void _toggleRequest() {
    setState(() {
      if (_mode == 'request') {
        _mode = 'none';
        _transaction = null;
      } else {
        _mode = 'request';
        _transaction = TransactionEntry(
          recipient: '',
          amount: 0.0,
          currency: 'PYUSD',
        );
      }
    });
  }

  void _toggleSend() {
    setState(() {
      if (_mode == 'send') {
        _mode = 'none';
        _transaction = null;
      } else {
        _mode = 'send';
        _transaction = TransactionEntry(
          recipient: '',
          amount: 0.0,
          currency: 'PYUSD',
        );
      }
    });
  }

  void _toggleCrowdfund() {
    setState(() {
      if (_mode == 'crowdfund') {
        _mode = 'none';
        _transaction = null;
      } else {
        _mode = 'crowdfund';
        _transaction = TransactionEntry(
          recipient: '',
          amount: 0.0,
          currency: 'PYUSD',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get balance from WalletState like in screen.dart
    final balance = context.watch<WalletState>().balance;
    final fromProfile = context.watch<ProfileState>().fromProfile;
    final loadingFromProfile = context.watch<ProfileState>().loadingFromProfile;

    return FlySheet(
      title: 'New Post',
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      showCloseButton: false,
      showBackButton: true,
      showDragHandle: true,
      child: FlyBox(
        children: [
          // Balance widget at the top - now using dynamic balance
          Balance(balance: balance),

          // Action buttons row (hide in contribute mode)
          if (_mode != 'contribute')
            FlyBox(
              children: [
                // Send button
                FlyButton(
                  onTap: _toggleSend,
                  buttonColor: _mode == 'send'
                      ? ButtonColor.primary
                      : ButtonColor.secondary,
                  variant: ButtonVariant.solid,
                  children: [FlyText('Send').text('sm').weight('medium')],
                ),

                // Request button
                FlyButton(
                  onTap: _toggleRequest,
                  buttonColor: _mode == 'request'
                      ? ButtonColor.primary
                      : ButtonColor.secondary,
                  variant: ButtonVariant.solid,
                  children: [FlyText('Request').text('sm').weight('medium')],
                ),

                // Crowdfund button
                FlyButton(
                  onTap: _toggleCrowdfund,
                  buttonColor: _mode == 'crowdfund'
                      ? ButtonColor.primary
                      : ButtonColor.secondary,
                  variant: ButtonVariant.solid,
                  children: [FlyText('Crowdfund').text('sm').weight('medium')],
                ),
              ],
            ).row().gap('s3').mb('s4'),

          // Transaction entry (only show if not 'none')
          if (_mode != 'none' && _transaction != null)
            _buildTransactionEntry(
              _transaction!,
              _mode == 'send',
              fromProfile,
              loadingFromProfile,
            ),

          // Text input area
          FlyBox(
            child: CupertinoTextField(
              controller: _postController,
              focusNode: _focusNode,
              maxLines: 5,
              textAlignVertical: TextAlignVertical.top,
              placeholder: 'message...',
              style: const TextStyle(fontSize: 16, height: 1.5),
              padding: const EdgeInsets.all(16),
            ),
          ).mb('s4'),

          // Post button
          FlyBox(
            children: [
              FlyButton(
                onTap: _handlePost,
                variant: ButtonVariant.solid,
                buttonColor: ButtonColor.primary,
                size: ButtonSize.large,
                child: FlyText(
                  _mode == 'crowdfund' ? 'Crowdfund' : 'Post',
                ).text('sm').weight('medium'),
              ),
            ],
          ).row().justify('end'),
        ],
      ).col().px('s4'),
    );
  }

  Widget _buildTransactionEntry(
    TransactionEntry transaction,
    bool isSend,
    ProfileV1? fromProfile,
    bool loadingFromProfile,
  ) {
    // Check if this is crowdfund or contribute mode
    final isCrowdfund = _mode == 'crowdfund';
    final isContribute = _mode == 'contribute';

    return FlyCardWithHeader(
      title: isContribute
          ? 'Contribute to Crowdfund'
          : (isCrowdfund
                ? 'Crowdfund'
                : (isSend ? 'Send Tokens' : 'Request Tokens')),
      headerIcon: isContribute || isCrowdfund
          ? LucideIcons.target
          : (isSend ? LucideIcons.arrowUpRight : LucideIcons.arrowDownLeft),
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
            // First row: Recipient input (hide in contribute mode)
            if (!isContribute)
              FlyBox(
                children: [
                  FlyText(
                    isSend || isCrowdfund ? 'to' : 'from',
                  ).text('sm').color('gray600'),
                  if (loadingFromProfile) CupertinoActivityIndicator(),
                  Expanded(
                    child: FlyBox(
                      children: [
                        CupertinoTextField(
                          keyboardType: TextInputType.text,
                          style: const TextStyle(fontSize: 14),
                          placeholder: isCrowdfund
                              ? 'user name'
                              : 'address or username',
                          onChanged: (value) {
                            context.read<ProfileState>().searchFromProfile(
                              value,
                            );
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
                          address: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
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
              ).row().items('center').gap('s2').mb('s3'),

            // Second row: Amount/Goal input
            FlyBox(
              children: [
                FlyText(
                  isCrowdfund ? 'goal' : 'amount',
                ).text('sm').color('gray600'),
                Expanded(
                  child: CupertinoTextField(
                    controller: _amountController,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(fontSize: 14),
                    placeholder: isCrowdfund
                        ? '# PYUSD'
                        : (isContribute ? '0.00' : '0.00'),
                    onChanged: (value) {
                      final amount = double.tryParse(value) ?? 0.0;
                      final recipientValue = isContribute
                          ? (widget.contributeToAddress ?? '')
                          : (fromProfile?.account ?? '');
                      final usernameValue = isContribute
                          ? widget.contributeToUsername
                          : fromProfile?.username;
                      setState(() {
                        _transaction = TransactionEntry(
                          recipient: recipientValue,
                          username: usernameValue,
                          amount: amount,
                          currency: 'PYUSD',
                        );
                      });
                    },
                  ),
                ),
                FlyText('PYUSD').text('sm').color('gray600'),
              ],
            ).row().items('center').gap('s2'),
          ],
        ).col().gap('s2'),
      ],
    ).mb('s4');
  }
}

class TransactionEntry {
  String recipient;
  String? username;
  double amount;
  String currency;

  TransactionEntry({
    required this.recipient,
    this.username,
    required this.amount,
    required this.currency,
  });
}
