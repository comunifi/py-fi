import 'dart:async';
import 'dart:convert';

import 'package:app/models/nostr_event.dart';
import 'package:app/models/post.dart';
import 'package:app/services/nostr/nostr.dart';
import 'package:app/services/wallet/models/userop.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FeedState extends ChangeNotifier {
  // instantiate services here - local storage, db, api, etc.
  NostrService _nostrService;

  // constructor here - you could pass a user id to the constructor and use it to trigger all methods with that user id
  FeedState() : _nostrService = NostrService(dotenv.get('RELAY_URL'));

  void init() {
    if (!isConnected) {
      _nostrService.connect((isConnected) async {
        if (!this.isConnected && isConnected) {
          _lastLoadedAt = DateTime.now();
          await startListening();
          loadPosts();
        }

        this.isConnected = isConnected;
        safeNotifyListeners();
      });
    }
  }

  // life cycle methods here
  bool _mounted = true;
  void safeNotifyListeners() {
    if (_mounted) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _mounted = false;
    _messageSubscription?.cancel();
    _nostrService.disconnect();
    super.dispose();
  }

  // state variables here - things that are observable by the UI
  final List<Post> posts = [];
  final Map<String, List<Post>> contributions = {}; // keyed by reply id
  final Set<String> claimedCrowdfunds =
      {}; // Track which crowdfunds have been claimed
  bool isLoading = false;
  bool isLoadingMore = false;
  bool isConnected = false;
  bool hasMorePosts = true;
  StreamSubscription<NostrEventModel>? _messageSubscription;

  DateTime? _lastLoadedAt;

  TxRequest? parseTxRequest(List<List<String>> tags) {
    try {
      for (var tag in tags) {
        if (tag[0] == 'tx-request') {
          return TxRequest.fromJson(json.decode(tag[1]));
        }
      }
      return null;
    } catch (e, s) {
      debugPrint('Error parsing tx request: $e');
      debugPrint('Error parsing tx request: $s');
      return null;
    }
  }

  UserOp? parseUserOp(List<List<String>> tags) {
    try {
      for (var tag in tags) {
        if (tag[0] == 'tx-intent') {
          return UserOp.fromJson(json.decode(tag[1]));
        }
      }
    } catch (e) {
      debugPrint('Error parsing user op: $e');
    }

    return null;
  }

  List<UserOp> parseUserOps(List<Post> posts) {
    return posts.map((post) => post.userOp).whereType<UserOp>().toList();
  }

  Future<void> startListening() async {
    if (_messageSubscription != null) {
      await _messageSubscription!.cancel();
    }

    try {
      _messageSubscription = _nostrService
          .listenToEvents(kind: 1, since: _lastLoadedAt)
          .listen(
            (event) {
              if (event.tags.any((tag) => tag[0] == 'e')) {
                // Handle contribution (reply)
                final replyId = event.tags.firstWhere(
                  (tag) => tag[0] == 'e',
                )[1];
                final contribution = Post(
                  id: event.id,
                  replyId: replyId,
                  userName: event.pubkey,
                  userId: event.pubkey,
                  content: event.content,
                  txRequest: parseTxRequest(event.tags),
                  userOp: parseUserOp(event.tags),
                  createdAt: event.createdAt,
                  updatedAt: event.createdAt,
                );

                // Initialize list if replyId doesn't exist
                if (!contributions.containsKey(replyId)) {
                  contributions[replyId] = [];
                }

                // Check if contribution already exists
                final existingIndex = contributions[replyId]!.indexWhere(
                  (c) => c.id == event.id,
                );

                if (existingIndex == -1) {
                  // Add new contribution
                  contributions[replyId]!.insert(0, contribution);
                } else {
                  // Update existing contribution
                  contributions[replyId]![existingIndex] = contribution;
                }
                safeNotifyListeners();
              } else {
                // Handle regular post
                final existingPostIndex = posts.indexWhere(
                  (existingPost) => existingPost.id == event.id,
                );

                final post = Post(
                  id: event.id,
                  userName: event.pubkey,
                  userId: event.pubkey,
                  content: event.content,
                  txRequest: parseTxRequest(event.tags),
                  createdAt: event.createdAt,
                  updatedAt: event.createdAt,
                );

                if (existingPostIndex == -1) {
                  // Add new post
                  posts.insert(0, post);
                } else {
                  // Update existing post
                  posts[existingPostIndex] = post;
                }
                safeNotifyListeners();
              }
            },
            onError: (error) {
              debugPrint('Error listening to messages: $error');
            },
          );
    } catch (e) {
      debugPrint('Failed to start listening: $e');
      rethrow;
    }
  }

  Future<void> loadPosts() async {
    isLoading = true;
    hasMorePosts = true;
    safeNotifyListeners(); // call this to tell the UI to update

    try {
      final limit = 10;

      // Load initial limit posts from Nostr (most recent posts)
      final historicalEvents = await _nostrService.requestPastEvents(
        kind: 1,
        limit: limit,
        until: _lastLoadedAt,
      );
      final historicalContributions = historicalEvents
          .where((event) => event.tags.any((tag) => tag[0] == 'e'))
          .map(
            (event) => Post(
              id: event.id,
              replyId: event.tags.firstWhere((tag) => tag[0] == 'e')[1],
              userName: event.pubkey,
              userId: event.pubkey,
              content: event.content,
              txRequest: parseTxRequest(event.tags),
              userOp: parseUserOp(event.tags),
              createdAt: event.createdAt,
              updatedAt: event.createdAt,
            ),
          )
          .toList();

      final historicalPosts = historicalEvents
          .where((event) => !event.tags.any((tag) => tag[0] == 'e'))
          .map(
            (event) => Post(
              id: event.id,
              userName: event.pubkey,
              userId: event.pubkey,
              content: event.content,
              txRequest: parseTxRequest(event.tags),
              createdAt: event.createdAt,
              updatedAt: event.createdAt,
            ),
          )
          .toList();

      posts.clear();
      contributions.clear();
      upsertPosts(historicalPosts);
      upsertContributions(historicalContributions);

      // Add some mock posts with transactions for testing
      // _addMockPostsWithTransactions();

      // If we got less than 20 posts, we've reached the end
      if (historicalPosts.length + historicalContributions.length < limit) {
        hasMorePosts = false;
      }

      safeNotifyListeners(); // call this to tell the UI to update
    } catch (e) {
      debugPrint('Error loading posts: $e');
      // Fallback to mock posts for development
      posts.clear();
      // _addMockPostsWithTransactions();
      safeNotifyListeners();
    }

    isLoading = false;
    safeNotifyListeners(); // call this to tell the UI to update
  }

  Future<void> refreshPosts() async {
    // Clear existing posts and reset pagination state
    posts.clear();
    contributions.clear();
    hasMorePosts = true;
    safeNotifyListeners();

    // Cancel existing message subscription to restart fresh
    if (_messageSubscription != null) {
      await _messageSubscription!.cancel();
      _messageSubscription = null;
    }

    final limit = 10;
    _lastLoadedAt = DateTime.now();

    try {
      // Load the latest 20 posts from Nostr (most recent posts)
      final historicalEvents = await _nostrService.requestPastEvents(
        kind: 1,
        limit: limit,
        until: _lastLoadedAt,
      );

      final historicalContributions = historicalEvents
          .where((event) => event.tags.any((tag) => tag[0] == 'e'))
          .map(
            (event) => Post(
              id: event.id,
              replyId: event.tags.firstWhere((tag) => tag[0] == 'e')[1],
              userName: event.pubkey,
              userId: event.pubkey,
              content: event.content,
              txRequest: parseTxRequest(event.tags),
              userOp: parseUserOp(event.tags),
              createdAt: event.createdAt,
              updatedAt: event.createdAt,
            ),
          )
          .toList();

      final historicalPosts = historicalEvents
          .where((event) => !event.tags.any((tag) => tag[0] == 'e'))
          .map(
            (event) => Post(
              id: event.id,
              userName: event.pubkey,
              userId: event.pubkey,
              content: event.content,
              txRequest: parseTxRequest(event.tags),
              createdAt: event.createdAt,
              updatedAt: event.createdAt,
            ),
          )
          .toList();

      upsertPosts(historicalPosts);
      upsertContributions(historicalContributions);

      // Add some mock posts with transactions for testing
      // _addMockPostsWithTransactions();

      // If we got less than limit posts, we've reached the end
      if (historicalPosts.length + historicalContributions.length < limit) {
        hasMorePosts = false;
      }

      safeNotifyListeners();

      // Start listening for new messages after loading historical posts
      if (isConnected) {
        startListening();
      }
    } catch (e) {
      debugPrint('Error refreshing posts: $e');
      // Fallback to mock posts for development
      // _addMockPostsWithTransactions();
      safeNotifyListeners();
    }
  }

  Future<void> loadMorePosts() async {
    if (isLoadingMore || !hasMorePosts || posts.isEmpty) {
      return;
    }

    final limit = 10;

    isLoadingMore = true;
    safeNotifyListeners();

    try {
      // Get the timestamp of the oldest post to load messages before it
      final oldestPost = posts.last;
      final until = oldestPost.createdAt;

      // Load next 20 posts (excluding contributions/replies which have 'e' tags)
      final moreEvents = await _nostrService.requestPastEvents(
        kind: 1,
        limit: limit,
        until: until,
      );

      if (moreEvents.isNotEmpty) {
        final moreContributions = moreEvents
            .where((event) => event.tags.any((tag) => tag[0] == 'e'))
            .map(
              (event) => Post(
                id: event.id,
                replyId: event.tags.firstWhere((tag) => tag[0] == 'e')[1],
                userName: event.pubkey,
                userId: event.pubkey,
                content: event.content,
                txRequest: parseTxRequest(event.tags),
                userOp: parseUserOp(event.tags),
                createdAt: event.createdAt,
                updatedAt: event.createdAt,
              ),
            )
            .toList();

        final morePosts = moreEvents
            .where((event) => !event.tags.any((tag) => tag[0] == 'e'))
            .map(
              (event) => Post(
                id: event.id,
                userName: event.pubkey,
                userId: event.pubkey,
                content: event.content,
                txRequest: parseTxRequest(event.tags),
                createdAt: event.createdAt,
                updatedAt: event.createdAt,
              ),
            )
            .toList();

        upsertPosts(morePosts);
        upsertContributions(moreContributions);
      }

      safeNotifyListeners();
    } catch (e) {
      debugPrint('Error loading more posts: $e');
      safeNotifyListeners();
      rethrow;
    }

    isLoadingMore = false;
    safeNotifyListeners();
  }

  Future<void> createPost(String content) async {
    isLoading = true;
    safeNotifyListeners();

    final event = await _nostrService.publishEvent(
      NostrEventModel.fromPartialData(kind: 1, content: content),
    );

    final post = Post(
      id: event.id,
      userName: event.pubkey,
      userId: event.pubkey,
      content: event.content,
      createdAt: event.createdAt,
      updatedAt: event.createdAt,
    );

    posts.insert(0, post);

    isLoading = false;
    safeNotifyListeners();
  }

  Future<void> createRequest(
    String content,
    String username,
    String address,
    double amount, {
    TransactionType type = TransactionType.request,
  }) async {
    try {
      isLoading = true;
      safeNotifyListeners();

      final txRequest = TxRequest(
        username: username,
        address: address,
        amount: amount,
        type: type,
      );

      debugPrint('txRequest: ${jsonEncode(txRequest.toJson())}');

      List<List<String>> tags = [
        ['tx-request', jsonEncode(txRequest.toJson())],
      ];

      final event = await _nostrService.publishEvent(
        NostrEventModel.fromPartialData(kind: 1, content: content, tags: tags),
      );

      final post = Post(
        id: event.id,
        userName: event.pubkey,
        userId: event.pubkey,
        content: event.content,
        txRequest: txRequest,
        createdAt: event.createdAt,
        updatedAt: event.createdAt,
      );

      posts.insert(0, post);

      isLoading = false;
      safeNotifyListeners();
    } catch (e, s) {
      debugPrint('Error creating request: $e');
      debugPrint('Error creating request: $s');
      isLoading = false;
      safeNotifyListeners();
    }
  }

  Future<void> contributeToCrowdfund(
    String id,
    String content,
    String address,
    double amount,
    UserOp userop,
  ) async {
    try {
      isLoading = true;
      safeNotifyListeners();

      debugPrint('userOpRequest: ${jsonEncode(userop.toJson())}');

      final txRequest = TxRequest(
        username: 'hello',
        address: address,
        amount: amount,
        type: TransactionType.send,
      );

      List<List<String>> tags = [
        ['e', id],
        ['tx-request', jsonEncode(txRequest.toJson())],
        ['tx-intent', jsonEncode(userop.toJson())],
      ];

      final event = await _nostrService.publishEvent(
        NostrEventModel.fromPartialData(kind: 1, content: content, tags: tags),
      );

      final contribution = Post(
        id: event.id,
        replyId: id,
        userName: event.pubkey,
        userId: event.pubkey,
        content: event.content,
        txRequest: txRequest,
        userOp: userop,
        createdAt: event.createdAt,
        updatedAt: event.createdAt,
      );

      // Add contribution to the map under the reply id
      if (!contributions.containsKey(id)) {
        contributions[id] = [];
      }
      contributions[id]!.insert(0, contribution);

      isLoading = false;
      safeNotifyListeners();
    } catch (e, s) {
      debugPrint('Error creating request: $e');
      debugPrint('Error creating request: $s');
      isLoading = false;
      safeNotifyListeners();
    }
  }

  void upsertPosts(List<Post> posts) {
    for (var post in posts) {
      final existingPostIndex = this.posts.indexWhere((p) => p.id == post.id);
      if (existingPostIndex != -1) {
        this.posts[existingPostIndex] = post;
      } else {
        this.posts.add(post);
      }
    }

    // Sort posts by creation date (most recent first)
    this.posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void markCrowdfundAsClaimed(String postId) {
    claimedCrowdfunds.add(postId);
    safeNotifyListeners();
  }

  void upsertContributions(List<Post> contributionsList) {
    for (var contribution in contributionsList) {
      if (contribution.replyId == null) continue;

      final replyId = contribution.replyId!;

      // Initialize list if replyId doesn't exist
      if (!contributions.containsKey(replyId)) {
        contributions[replyId] = [];
      }

      // Check if contribution already exists
      final existingIndex = contributions[replyId]!.indexWhere(
        (c) => c.id == contribution.id,
      );

      if (existingIndex == -1) {
        // Add new contribution
        contributions[replyId]!.add(contribution);
      } else {
        // Update existing contribution
        contributions[replyId]![existingIndex] = contribution;
      }
    }

    // Sort contributions by creation date (most recent first) for each post
    for (var replyId in contributions.keys) {
      contributions[replyId]!.sort(
        (a, b) => b.createdAt.compareTo(a.createdAt),
      );
    }
  }

  /// Reconnect with new settings
  Future<void> reconnect() async {
    try {
      // Cancel existing subscription before disconnecting
      if (_messageSubscription != null) {
        try {
          if (_nostrService.isConnected) {
            await _messageSubscription!.cancel();
          }
        } catch (e) {
          debugPrint('Error cancelling subscription: $e');
        }
        _messageSubscription = null;
      }

      // Disconnect current connection
      await _nostrService.disconnect();

      // Create new service
      final relayUrl = dotenv.get('RELAY_URL');
      _nostrService = NostrService(relayUrl);

      // Wait for connection to complete
      final completer = Completer<void>();

      // Reconnect
      try {
        await _nostrService.connect((isConnected) async {
          this.isConnected = isConnected;
          safeNotifyListeners();

          if (isConnected && !completer.isCompleted) {
            completer.complete();
          } else if (!isConnected && !completer.isCompleted) {
            completer.completeError(Exception('Connection failed'));
          }
        });
      } catch (e) {
        debugPrint('Exception during connect(): $e');
        if (!completer.isCompleted) {
          completer.completeError(e);
        }
        rethrow;
      }

      // Wait for connection to be established with timeout
      await completer.future.timeout(const Duration(seconds: 5));

      // Start listening and load posts after connection is established
      if (isConnected) {
        _lastLoadedAt = DateTime.now();
        await startListening();
      }
    } catch (e) {
      debugPrint('Error reconnecting: $e');
      safeNotifyListeners();
      rethrow;
    }
  }
}

enum TransactionType { send, request, crowdfund }

class TxRequest {
  String username;
  String address;
  double amount;
  TransactionType type;
  String? status; // For tracking transaction state
  double? currentAmount; // For crowdfund progress

  TxRequest({
    required this.username,
    required this.address,
    required this.amount,
    required this.type,
    this.status,
    this.currentAmount,
  });

  factory TxRequest.fromJson(Map<String, dynamic> json) {
    return TxRequest(
      username: json['username'],
      address: json['address'],
      amount: json['amount'],
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.request, // Default to request
      ),
      status: json['status'],
      currentAmount: json['currentAmount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'address': address,
      'amount': amount,
      'type': type.name,
      'status': status,
      'currentAmount': currentAmount,
    };
  }
}
