// TODO: implement this with biometrics/secure storage instead
import 'package:dart_nostr/dart_nostr.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureService {
  static final SecureService _instance = SecureService._internal();

  factory SecureService() => _instance;
  SecureService._internal();

  static const String _versionKey = 'secure_version';
  static const int version = 1;

  final nostrInstance = Nostr.instance;
  late SharedPreferences _preferences;

  static const String _privateKeyKey = 'nostr_private_key';

  Future init(SharedPreferences pref) async {
    _preferences = pref;

    final version = _preferences.getInt(_versionKey);
    if (version == null || version < SecureService.version) {
      await migrate(version ?? 0, SecureService.version);
    }
  }

  Future migrate(int oldVersion, int newVersion) async {
    switch (newVersion) {
      case 1:
        // migrate to version 1
        _preferences.setInt(_versionKey, newVersion);
        break;
      default:
    }
  }

  Future clear() async {
    await _preferences.clear();
  }

  (String, String) createCredentials() {
    final pair = nostrInstance.services.keys.generateKeyPair();
    setCredentials(pair.public, pair.private);

    return (pair.public, pair.private);
  }

  // Save private key with account address
  Future setCredentials(String publicKey, String privateKey) async {
    final storedValue = '$publicKey:$privateKey';
    await _preferences.setString(_privateKeyKey, storedValue);
  }

  // Get private key without needing arguments
  (String, String)? getCredentials() {
    final storedValue = _preferences.getString(_privateKeyKey);
    if (storedValue == null) return null;

    try {
      final parts = storedValue.split(':');
      if (parts.length != 2) return null;

      final privateKeyHex = parts[1];
      return (parts[0], privateKeyHex);
    } catch (_) {
      return null;
    }
  }

  // Get account address associated with the stored private key
  String? getAccountAddress() {
    final storedValue = _preferences.getString(_privateKeyKey);
    if (storedValue == null) return null;

    final parts = storedValue.split(':');
    if (parts.length != 2) return null;

    return parts[0];
  }

  // Check if a private key is stored
  bool hasCredentials() {
    return _preferences.containsKey(_privateKeyKey);
  }

  // Delete the stored private key
  Future clearCredentials() async {
    await _preferences.remove(_privateKeyKey);
  }
}
