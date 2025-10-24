import 'dart:async';

import 'package:app/design/avatar.dart';
import 'package:app/design/avatar_blockies.dart';
import 'package:app/design/button.dart';
import 'package:app/models/post.dart';
import 'package:app/screens/feed/new_post.dart';
import 'package:app/state/feed.dart';
import 'package:app/state/state.dart';
import 'package:app/state/wallet.dart';
import 'package:app/utils/address.dart';
import 'package:app/widgets/post_card.dart';
import 'package:app/widgets/transaction_card.dart';
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
      builder: (context) => provideAccountState(
        context,
        config,
        SimpleNewPostScreen(
          onSendBack: handleSendBack,
          onRequest: handleRequest,
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

  @override
  Widget build(BuildContext context) {
    final feedState = context.watch<FeedState>();
    final posts = feedState.posts;
    final isLoadingMore = feedState.isLoadingMore;

    final profile = context.watch<WalletState>().profile;

    final balance = context.watch<WalletState>().balance;

    Map<String, String> sendingRequests = context
        .watch<WalletState>()
        .sendingRequests;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground,
        border: const Border(
          bottom: BorderSide(color: CupertinoColors.separator, width: 0.5),
        ),
        leading: null,
        middle: null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // User avatar
            FlyText(
              '@${profile?.username ?? ''}',
            ).text('xs').color('gray600').mr('s1'),
            FlyAvatar(
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
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
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
                      child: Center(
                        child: Text(
                          'No posts found',
                          style: TextStyle(
                            color: CupertinoColors.systemGrey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Fixed footer with balance and add button
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: CupertinoColors.separator, width: 0.5),
                ),
              ),
              child: FlyBox(
                children: [
                  // Balance card
                  FlyBox(
                    children: [
                      FlyText('balance').text('xs').color('gray600'),
                      FlyText(
                        '${balance ?? '0.00'} EURe',
                      ).text('lg').weight('bold').color('gray900'),
                    ],
                  ).col().gap('s1').px('s3').py('s2').bg('white').rounded('lg'),

                  // Add button
                  FlyButton(
                    onTap: handleCreatePost,
                    buttonColor: ButtonColor.primary,
                    variant: ButtonVariant.solid,
                    child: FlyIcon(LucideIcons.plus).color('white'),
                  ),
                ],
              ).row().items('center').justify('between').px('s4').py('s3'),
            ),
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
      transaction: post.txRequest != null
          ? TransactionCard(
              senderName: post.txRequest!.username,
              senderAddress: post
                  .txRequest!
                  .address, // Use the post author's address as sender address
              amount: post.txRequest!.amount.toString(),
              // timeAgo: post.transaction!.timeAgo,
              // senderInitials: post.transaction!.senderInitials,
              // status: post.transaction!.timeAgo == 'Pending'
              //     ? 'Request Pending'
              //     : post.transaction!.timeAgo == 'Complete'
              //     ? 'Request Complete'
              //     : 'Completed',
              timeAgo: '1 hour ago',
              senderInitials: 'hello',
              status: sendingRequests[post.id] ?? 'Request Pending',
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
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(child: CupertinoActivityIndicator()),
    );
  }
}
