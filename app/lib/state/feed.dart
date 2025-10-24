import 'dart:async';
import 'dart:convert';

import 'package:app/models/nostr_event.dart';
import 'package:app/models/post.dart';
import 'package:app/services/nostr/nostr.dart';
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

  Future<void> startListening() async {
    if (_messageSubscription != null) {
      await _messageSubscription!.cancel();
    }

    try {
      _messageSubscription = _nostrService
          .listenToEvents(kind: 1, since: _lastLoadedAt)
          .listen(
            (event) {
              // Check if post already exists to avoid duplicates
              final existingPostIndex = posts.indexWhere(
                (existingPost) => existingPost.id == event.id,
              );

              if (existingPostIndex == -1) {
                // Add new posts to the beginning of the list
                posts.insert(
                  0,
                  Post(
                    id: event.id,
                    userName: event.pubkey,
                    userId: event.pubkey,
                    content: event.content,
                    txRequest: parseTxRequest(event.tags),
                    createdAt: event.createdAt,
                    updatedAt: event.createdAt,
                  ),
                );
                safeNotifyListeners();
              } else {
                posts[existingPostIndex] = Post(
                  id: event.id,
                  userName: event.pubkey,
                  userId: event.pubkey,
                  content: event.content,
                  txRequest: parseTxRequest(event.tags),
                  createdAt: event.createdAt,
                  updatedAt: event.createdAt,
                );
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

      final historicalPosts = historicalEvents
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
      upsertPosts(historicalPosts);

      // Add some mock posts with transactions for testing
      _addMockPostsWithTransactions();

      // If we got less than 20 posts, we've reached the end
      if (historicalPosts.length < limit) {
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

      final historicalPosts = historicalEvents
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

      // Add some mock posts with transactions for testing
      _addMockPostsWithTransactions();

      // If we got less than limit posts, we've reached the end
      if (historicalPosts.length < limit) {
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

      // Load next 20 posts
      final moreEvents = await _nostrService.requestPastEvents(
        kind: 1,
        limit: limit,
        until: until,
      );

      if (moreEvents.isNotEmpty) {
        final morePosts = moreEvents
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

        // If we got less than limit posts, we've reached the end
        if (morePosts.length < limit) {
          hasMorePosts = false;
        }
      } else {
        hasMorePosts = false;
      }

      safeNotifyListeners();
    } catch (e) {
      debugPrint('Error loading more posts: $e');
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

  void _addMockPostsWithTransactions() {
    // Add a mock targeted receive post (targeted to current user - they will see fulfill button)
    final mockTargetedReceivePost = Post(
      id: 'mock-targeted-receive-post-1',
      userName: '0x1234567890abcdef1234567890abcdef12345678',
      userId: '0x1234567890abcdef1234567890abcdef12345678',
      content: 'Hey! Could you help me out with some PYUSD? I need to cover some expenses.',
      userInitials: 'AC',
      likeCount: 2,
      dislikeCount: 0,
      commentCount: 1,
      txRequest: TxRequest(
        username: '0x1234567890abcdef1234567890abcdef12345678',
        address: '0x1234567890abcdef1234567890abcdef12345678', // Alice's address (from)
        amount: 50.0,
        type: TransactionType.request,
        status: 'Request Pending',
      ),
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    );

    // Add a mock send post (completed transaction - no fulfill button)
    final mockSendPost = Post(
      id: 'mock-send-post-1',
      userName: '0x9876543210fedcba9876543210fedcba98765432',
      userId: '0x9876543210fedcba9876543210fedcba98765432',
      content: 'Sending some PYUSD to my friend for lunch! 🍕',
      userInitials: 'BT',
      likeCount: 5,
      dislikeCount: 0,
      commentCount: 3,
      txRequest: TxRequest(
        username: '0x9876543210fedcba9876543210fedcba98765432',
        address: '0x9876543210fedcba9876543210fedcba98765432',
        amount: 25.0,
        type: TransactionType.send,
        status: 'Send Complete',
      ),
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
    );

    // Add a mock crowdfund in progress post
    final mockCrowdfundProgressPost = Post(
      id: 'mock-crowdfund-progress-1',
      userName: '0xabcdef1234567890abcdef1234567890abcdef12',
      userId: '0xabcdef1234567890abcdef1234567890abcdef12',
      content: 'Help me reach my goal for the community garden project! 🌱',
      userInitials: 'SF',
      likeCount: 12,
      dislikeCount: 0,
      commentCount: 8,
      txRequest: TxRequest(
        username: '0xabcdef1234567890abcdef1234567890abcdef12',
        address: '0xabcdef1234567890abcdef1234567890abcdef12',
        amount: 2.0, // Goal amount
        type: TransactionType.crowdfund,
        status: 'Crowdfund In Progress',
        currentAmount: 1.0, // Current progress
      ),
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
    );

    // Add a mock crowdfund successful post
    final mockCrowdfundSuccessPost = Post(
      id: 'mock-crowdfund-success-1',
      userName: '0xfedcba0987654321fedcba0987654321fedcba09',
      userId: '0xfedcba0987654321fedcba0987654321fedcba09',
      content: 'Thank you everyone! We reached our goal for the art exhibition! 🎨',
      userInitials: 'MC',
      likeCount: 25,
      dislikeCount: 0,
      commentCount: 15,
      txRequest: TxRequest(
        username: '0xfedcba0987654321fedcba0987654321fedcba09',
        address: '0xfedcba0987654321fedcba0987654321fedcba09',
        amount: 5.0, // Goal amount
        type: TransactionType.crowdfund,
        status: 'Crowdfund Successful',
        currentAmount: 5.0, // Fully funded
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    );

    // Insert mock posts at the beginning
    posts.insertAll(0, [
      mockTargetedReceivePost, 
      mockSendPost, 
      mockCrowdfundProgressPost, 
      mockCrowdfundSuccessPost
    ]);
  }


}

enum TransactionType {
  send,
  request,
  crowdfund,
}

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
