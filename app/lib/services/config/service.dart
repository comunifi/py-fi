import 'dart:convert';

import 'package:app/services/api/api.dart';
import 'package:app/services/config/config.dart';
import 'package:app/utils/date.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ConfigService {
  static final ConfigService _instance = ConfigService._internal();

  factory ConfigService() {
    return _instance;
  }

  ConfigService._internal();

  static const String communityConfigFileName = kDebugMode
      ? 'communities'
      : 'communities';
  static const String communityConfigListS3FileName = 'communities';
  static const String communityDebugFileName = 'debug';
  static const int version = 5;

  void init(String endpoint) {}

  Future<Config?> getLocalConfig() async {
    try {
      final localConfig = jsonDecode(
        await rootBundle.loadString(
          'assets/config/$communityConfigFileName.json',
        ),
      );

      final config = Config.fromJson(localConfig);

      return config;
    } catch (e, s) {
      debugPrint('Error fetching local config: $e');
      debugPrint('Stack trace: $s');
      return null;
    }
  }

  Future<Config?> getRemoteConfig(String remoteConfigUrl) async {
    if (kDebugMode) {
      final debugConfig = jsonDecode(
        await rootBundle.loadString('assets/config/v$version/debug.json'),
      );

      return Config.fromJson(debugConfig);
    }

    final remote = APIService(baseURL: remoteConfigUrl);

    try {
      final dynamic response = await remote.get(
        url: '?cachebuster=${generateCacheBusterValue()}',
      );

      final config = Config.fromJson(response);

      return config;
    } catch (e, s) {
      debugPrint('Error fetching remote config: $e');
      debugPrint('Stacktrace: $s');

      return null;
    }
  }

  Future<bool> isCommunityOnline(String indexerUrl) async {
    final indexer = APIService(baseURL: indexerUrl, netTimeoutSeconds: 12);

    try {
      await indexer.get(url: '/health');
      return true;
    } catch (e, s) {
      debugPrint('indexerUrl: $indexerUrl');
      debugPrint('Error checking if community is online: $e, $indexerUrl');
      debugPrint('Stacktrace: $s, $indexerUrl');

      return false;
    }
  }
}
