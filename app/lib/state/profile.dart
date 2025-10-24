import 'dart:async';

import 'package:app/services/config/config.dart';
import 'package:app/services/wallet/contracts/profile.dart';
import 'package:app/services/wallet/wallet.dart';
import 'package:flutter/cupertino.dart';

class ProfileState extends ChangeNotifier {
  final Config _config;

  ProfileState(this._config);

  // Debounce timer for profile search
  Timer? _searchDebounceTimer;

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
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  ProfileV1? fromProfile;
  bool loadingFromProfile = false;

  void clearFromProfile() {
    fromProfile = null;
    loadingFromProfile = false;
    safeNotifyListeners();
  }

  void searchFromProfile(String username) {
    debugPrint('Searching for profile: $username');
    // Cancel any existing timer
    _searchDebounceTimer?.cancel();

    if (!loadingFromProfile) {
      loadingFromProfile = true;
      safeNotifyListeners();
    }

    // Set a new timer with 500ms delay
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      debugPrint('Searching for profile: $username');
      _performSearch(username);
    });
  }

  void _performSearch(String username) async {
    try {
      final profile = await getProfileByUsername(_config, username);
      if (profile == null) {
        return;
      }

      debugPrint('Profile found: ${profile.username}');

      fromProfile = profile;

      safeNotifyListeners();
    } catch (e) {
      debugPrint('Error searching from profile: $e');
      fromProfile = null;
    } finally {
      loadingFromProfile = false;
      safeNotifyListeners();
    }
  }
}
