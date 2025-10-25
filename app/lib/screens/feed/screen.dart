import 'dart:async';

import 'package:app/models/post.dart';
import 'package:app/services/wallet/utils.dart';
import 'package:app/utils/calldata.dart';
import 'package:app/utils/currency.dart';
import 'package:app/widgets/new_post.dart';
import 'package:app/state/feed.dart';
import 'package:app/state/state.dart';
import 'package:app/state/wallet.dart';
import 'package:app/widgets/bottombar.dart';
import 'package:app/widgets/topbar.dart';
import 'package:app/widgets/post_card.dart';
import 'package:app/widgets/send_card.dart';
import 'package:app/widgets/request_card.dart';
import 'package:app/widgets/crowdfund_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flywind/flywind.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/crypto.dart';

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
            onCrowdfund: handleCrowdfund,
          ),
        ),
      ),
    );

    if (content == null || content.isEmpty) {
      return;
    }

    await _feedState.createPost(content);
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

  void handleContributeOnCrowdfund(
    String id,
    String content,
    String to,
    double amount,
  ) async {
    final userop = await _walletState.signUserOp(id, to, amount);
    if (userop == null) {
      return;
    }
    await _feedState.contributeToCrowdfund(id, content, to, amount, userop);
  }

  void handleCrowdfund(
    String content,
    String username,
    String address,
    double amount,
  ) async {
    await _feedState.createRequest(
      content,
      username,
      address,
      amount,
      type: TransactionType.crowdfund,
    );
  }

  Future<void> handleClaim(String postId) async {
    final contributions = _feedState.contributions[postId] ?? [];

    // Collect all UserOps from contributions
    final userOps = contributions
        .where((contribution) => contribution.userOp != null)
        .map((contribution) => contribution.userOp!)
        .toList();

    if (userOps.isEmpty) {
      debugPrint('No user ops to claim');
      return;
    }
    await _walletState.submitUserOps(userOps);

    // Mark the crowdfund as claimed after successful submission
    // This will publish a Nostr event so all clients can see it's claimed
    await _feedState.markCrowdfundAsClaimed(postId);
  }

  Future<void> handleContribute(
    String id,
    String username,
    String address,
  ) async {
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
            onContribute: (content, username, address, amount) {
              handleContributeOnCrowdfund(id, content, address, amount);
            },
            contributeToUsername: username,
            contributeToAddress: address,
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
    final walletState = context.watch<WalletState>();
    final balance = walletState.balance;
    final sendingRequests = walletState.sendingRequests;
    final currentUserAddress = walletState.account?.hexEip55.toLowerCase();
    final contributions = feedState.contributions;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Custom header
            TopBar(
              accountAddress: walletState.account?.hexEip55,
              profile: walletState.profile,
            ),
            // Scrollable content area
            Expanded(
              child: CustomScrollView(
                controller: _scrollController,
                scrollBehavior: const CupertinoScrollBehavior(),
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  CupertinoSliverRefreshControl(onRefresh: handleRefresh),
                  SliverToBoxAdapter(
                    child: FlyBox(
                      children: [
                        // Build all post cards
                        ...posts.map(
                          (post) => _buildPostCard(
                            post,
                            contributions,
                            sendingRequests,
                            currentUserAddress,
                          ),
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
                        child: FlyText(
                          'No posts found',
                        ).text('sm').color('gray500'),
                      ).justify('center').items('center'),
                    ),
                ],
              ),
            ),
            // Fixed footer with balance and add button
            BottomBar(balance: balance, onCreatePost: handleCreatePost),
            // Progress bar for submitting user ops
            if (walletState.submittingUserOps) _buildProgressBar(walletState),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(WalletState walletState) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: FlyBox(
        children: [
          FlyBox(
            children: [
              FlyText(
                'Claiming contributions ${walletState.submittingUserOpsCompleted}/${walletState.submittingUserOpsTotal}',
              ).text('xs').color('gray700'),
            ],
          ).row().items('center').justify('between').mb('s2'),
          FlyBox(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: walletState.submittingUserOpsProgress,
                child: Container(
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBlue,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ).col().px('s4').py('s3'),
    );
  }

  Widget _buildPostCard(
    Post post,
    Map<String, List<Post>> contributions,
    Map<String, String> sendingRequests,
    String? currentUserAddress,
  ) {
    final relatedContributions = contributions[post.id] ?? [];
    final totalAmount = relatedContributions.fold(0.0, (sum, contribution) {
      final userop = contribution.userOp;
      if (userop == null) {
        return sum;
      }
      final transfer = parseNestedERC20Transfer(bytesToHex(userop.callData));
      if (transfer == null) {
        return sum;
      }
      return sum + double.parse(formatCurrency(transfer.amount.toString(), 6));
    });
    final totalAmountString = totalAmount.toStringAsFixed(2);

    bool wasCrowdfundSuccessful = false;
    bool isCurrentUserRecipient = false;
    bool isClaiming = false;
    bool isClaimed = false;
    if (post.txRequest?.type == TransactionType.crowdfund) {
      wasCrowdfundSuccessful = totalAmount >= post.txRequest!.amount;
      isCurrentUserRecipient =
          currentUserAddress != null &&
          currentUserAddress == '0x46547cc4216beF639bA9744E7719684971d7911d' &&
          post.txRequest!.address.toLowerCase() ==
              '0x6306a2414CA7A0F1Deca4F954F881b597E54878B';
      isClaiming = _walletState.submittingUserOps;
      isClaimed = _feedState.claimedCrowdfunds.contains(post.id);
    }

    return PostCard(
      key: Key(post.id),
      userAddress: post.userId,
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
              onBackTap: () {},
              onDeleteTap: () {},
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
              status:
                  sendingRequests[post.id] ??
                  post.txRequest!.status ??
                  'Request Pending',
              onBackTap: () {},
              onDeleteTap: () {},
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
              currentAmount: totalAmountString,
              status: isClaimed
                  ? 'Crowdfund Claimed'
                  : wasCrowdfundSuccessful
                  ? (isCurrentUserRecipient
                        ? 'Crowdfund Successful'
                        : 'Crowdfund Complete')
                  : post.txRequest!.status ?? 'Crowdfund In Progress',
              isClaiming: isClaiming,
              onBackTap: () {},
              onDeleteTap: () {},
              onContribute: () {
                handleContribute(
                  post.id,
                  post.txRequest!.username,
                  post.txRequest!.address,
                );
              },
              onClaim: () {
                handleClaim(post.id);
              },
            )
          : null,
      createdAt: post.createdAt,
      onLike: () {},
      onDislike: () {},
      onComment: () {
        context.push('/user123/posts/${post.id}');
      },
      onShare: () {},
      onMore: () {},
    );
  }

  Widget _buildLoadingIndicator() {
    return FlyBox(
      child: CupertinoActivityIndicator(),
    ).p('s4').justify('center').items('center');
  }
}
