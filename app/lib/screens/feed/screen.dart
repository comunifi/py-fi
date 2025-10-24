import 'dart:async';

import 'package:app/design/button.dart';
import 'package:app/models/post.dart';
import 'package:app/widgets/new_post.dart';
import 'package:app/state/feed.dart';
import 'package:app/state/state.dart';
import 'package:app/state/wallet.dart';
import 'package:app/widgets/balance.dart';
import 'package:app/widgets/topbar.dart';
import 'package:app/widgets/post_card.dart';
import 'package:app/widgets/send_card.dart';
import 'package:app/widgets/request_card.dart';
import 'package:app/widgets/crowdfund_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flywind/flywind.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class SocialFeedScreen extends StatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen> {
  late FeedState _feedState;
  late WalletState _walletState;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _feedState = context.read<FeedState>();
    _walletState = context.read<WalletState>();
    _scrollController = ScrollController();

    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      onLoad();
    });
  }

  Future<void> onLoad() async {
    _feedState.init();

    await _walletState.ready();

    _walletState.loadAccount();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Check if we've scrolled to the bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more posts when near the bottom
      _feedState.loadMorePosts();
    }
  }

  Future<void> handleRefresh() async {
    await _feedState.refreshPosts();
  }

  Future<void> handleCreatePost() async {
    // modals and navigation in general can be awaited and return a value
    // when inside SimpleNewPostScreen and navigator.pop(value) is called, value is returned
    final config = context.read<WalletState>().config;

    final content = await showCupertinoModalPopup<String?>(
      context: context,
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: _walletState),
          ChangeNotifierProvider.value(value: _feedState),
        ],
        child: provideAccountState(
          context,
          config,
          SimpleNewPostScreen(
            onSendBack: handleSendBack,
            onRequest: handleRequest,
          ),
        ),
      ),
    );

    if (content == null || content.isEmpty) {
      return;
    }

    await _feedState.createPost(content);
  }


  void handleDesignSystem() {
    // TODO: Implement design system navigation
  }

  void handleSendBack() async {
    await _walletState.sendBack(1);
  }

  void handleRequest(
    String content,
    String username,
    String address,
    double amount,
  ) async {
    await _feedState.createRequest(content, username, address, amount);
  }

  void handleSend(String id, String to, double amount) async {
    await _walletState.send(id, to, amount);
  }

  Future<void> handleContribute(String username, String address, double amount) async {
    final config = context.read<WalletState>().config;

    await showCupertinoModalPopup<String?>(
      context: context,
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: _walletState),
          ChangeNotifierProvider.value(value: _feedState),
        ],
        child: provideAccountState(
          context,
          config,
          SimpleNewPostScreen(
            onSendBack: handleSendBack,
            onRequest: handleRequest,
            onContribute: (content, username, address, amount) async {
              // Handle contribute logic here
              print('Contribute: $content to $username ($address) amount: $amount');
            },
            contributeToUsername: username,
            contributeToAddress: address,
            contributeAmount: amount,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final feedState = context.watch<FeedState>();
    final posts = feedState.posts;
    final isLoadingMore = feedState.isLoadingMore;

    // final profile = context.watch<WalletState>().profile;

    final balance = context.watch<WalletState>().balance;

    Map<String, String> sendingRequests = context
        .watch<WalletState>()
        .sendingRequests;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Custom header
            const TopBar(),
            // Scrollable content area
            Expanded(
              child: CustomScrollView(
                controller: _scrollController,
                scrollBehavior: const CupertinoScrollBehavior(),
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  CupertinoSliverRefreshControl(
                    onRefresh: handleRefresh,
                  ), // the Future returned by the function is what makes the spinner go away
                  SliverToBoxAdapter(
                    child: FlyBox(
                      children: [
                        // Build all post cards
                        ...posts.map(
                          (post) => _buildPostCard(post, sendingRequests),
                        ),
                        // Show loading indicator at the bottom if loading more
                        if (isLoadingMore) _buildLoadingIndicator(),
                      ],
                    ).col().gap('s4').px('s4').py('s4'),
                  ),
                  // Show "no posts posted" message if there are no posts at all
                  if (posts.isEmpty)
                    SliverFillRemaining(
                      child: FlyBox(
                        child: FlyText('No posts found').text('sm').color('gray500'),
                      ).justify('center').items('center'),
                    ),
                ],
              ),
            ),
            // Fixed footer with balance and add button
            FlyBox(
              child: FlyBox(
                children: [
                  // Balance card
                  Balance(balance: balance),

                  // Add button
                  FlyButton(
                    onTap: handleCreatePost,
                    buttonColor: ButtonColor.primary,
                    variant: ButtonVariant.solid,
                    child: FlyIcon(LucideIcons.plus).color('white'),
                  ),
                ],
              ).row().items('center').justify('between').px('s4').py('s3'),
            ).bg('white').borderT(1).borderColor('gray200'),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(Post post, Map<String, String> sendingRequests) {
    return PostCard(
      key: Key(post.id),
      userAddress: post.userId, // Using userId as the user's public key/address
      userName: post.userName,
      content: post.content,
      userInitials: post.userInitials,
      likeCount: post.likeCount,
      dislikeCount: post.dislikeCount,
      commentCount: post.commentCount,
      sendTransaction: post.txRequest?.type == TransactionType.send
          ? SendTransactionCard(
              recipientName: post.txRequest!.username,
              recipientAddress: post.txRequest!.address,
              amount: post.txRequest!.amount.toString(),
              timeAgo: '1 hour ago',
              recipientInitials: post.userInitials,
              status: post.txRequest!.status ?? 'Send Complete',
              onBackTap: () {
                // Handle back navigation
              },
              onDeleteTap: () {
                // Handle delete action
              },
            )
          : null,
      requestTransaction: post.txRequest?.type == TransactionType.request
          ? RequestTransactionCard(
              senderName: post.txRequest!.username,
              senderAddress: post.txRequest!.address,
              recipientName: post.txRequest!.username,
              recipientAddress: post.txRequest!.address,
              amount: post.txRequest!.amount.toString(),
              timeAgo: '1 hour ago',
              senderInitials: post.userInitials,
              status: sendingRequests[post.id] ?? post.txRequest!.status ?? 'Request Pending',
              onBackTap: () {
                // Handle back navigation
              },
              onDeleteTap: () {
                // Handle delete action
              },
              onFulfillRequest: () {
                handleSend(
                  post.id,
                  post.txRequest!.address,
                  post.txRequest!.amount,
                );
              },
            )
          : null,
      crowdfundTransaction: post.txRequest?.type == TransactionType.crowdfund
          ? CrowdfundTransactionCard(
              recipientName: post.txRequest!.username,
              recipientAddress: post.txRequest!.address,
              goalAmount: post.txRequest!.amount.toString(),
              timeAgo: '1 hour ago',
              recipientInitials: post.userInitials,
              currentAmount: post.txRequest!.currentAmount?.toString() ?? '0',
              status: post.txRequest!.status ?? 'Crowdfund In Progress',
              onBackTap: () {
                // Handle back navigation
              },
              onDeleteTap: () {
                // Handle delete action
              },
              onContribute: () {
                handleContribute(post.txRequest!.username, post.txRequest!.address, post.txRequest!.amount);
              },
              onClaim: () {
                print('Claim crowdfund');
              },
            )
          : null,
      createdAt: post.createdAt,
      onLike: () {
        // TODO: Implement like functionality
      },
      onDislike: () {
        // TODO: Implement dislike functionality
      },
      onComment: () {
        // Navigate to post details page
        context.push('/user123/posts/${post.id}');
      },
      onShare: () {
        // TODO: Implement share functionality
      },
      onMore: () {
        // TODO: Implement more options functionality
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return FlyBox(
      child: CupertinoActivityIndicator(),
    ).p('s4').justify('center').items('center');
  }
}
