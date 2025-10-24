import 'dart:async';

import 'package:app/services/config/config.dart';
import 'package:app/services/config/service.dart';
import 'package:app/services/photos/photos.dart';
import 'package:app/services/secure/secure.dart';
import 'package:app/services/wallet/contracts/profile.dart';
import 'package:app/services/wallet/utils.dart';
import 'package:app/services/wallet/wallet.dart';
import 'package:app/utils/currency.dart';
import 'package:app/utils/delay.dart';
import 'package:app/utils/random.dart';
import 'package:flutter/cupertino.dart';
import 'package:web3dart/web3dart.dart';

class WalletState extends ChangeNotifier {
  // instantiate services here - local storage, db, api, etc.

  final PhotosService _photosService = PhotosService();
  final SecureService _secureService = SecureService();
  final ConfigService _configService = ConfigService();
  late Config _config;
  Config get config => _config;

  final Completer readyCompleter = Completer<void>();

  bool _creatingProfile = false;

  // constructor here - you could pass a user id to the constructor and use it to trigger all methods with that user id
  WalletState() {
    init();
  }

  Future<void> init() async {
    final config = await _configService.getLocalConfig();
    if (config == null) {
      throw Exception('Community not found in local asset');
    }

    await config.initContracts();

    _config = config;

    readyCompleter.complete();
  }

  Future<void> ready() async {
    await readyCompleter.future;
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
    super.dispose();
  }

  // state variables here - things that are observable by the UI
  bool isLoading = false;
  EthereumAddress? account;
  String? balance;
  ProfileV1? profile;

  bool sending = false;

  Map<String, String> sendingRequests = {};

  Future<void> loadAccount() async {
    try {
      isLoading = true;
      safeNotifyListeners();

      final credentials = _secureService.getCredentials();
      if (credentials == null) {
        throw Exception('No credentials found');
      }

      final privateKey = EthPrivateKey.fromHex(credentials.$2);
      final EthereumAddress owner = privateKey.address;

      final account = await _config.accountFactoryContract.getAddress(
        owner.hexEip55,
      );

      debugPrint('Account: ${account.hexEip55}');

      this.account = account;

      final rawBalance = await getBalance(_config, account);

      final token = _config.getPrimaryToken();

      balance = formatCurrency(rawBalance.toString(), token.decimals);
      safeNotifyListeners();

      final nonce = await _config.getNonce(account.hexEip55);
      if (nonce == BigInt.zero) {
        if (_creatingProfile) {
          return;
        }

        _creatingProfile = true;

        final created = await createAccount(_config, account, privateKey);
        if (!created) {
          throw Exception('Failed to create account');
        }

        // set up profile
        final username = await _generateProfileUsername();
        if (username == null) {
          return;
        }

        profile = ProfileV1(account: account.hexEip55, username: username);

        final url = await setProfile(
          _config,
          account,
          privateKey,
          ProfileRequest.fromProfileV1(profile!),
          image: await _photosService.photoFromBundle(
            'assets/icons/profile.png',
          ),
          fileType: '.png',
        );
        if (url == null) {
          throw Exception('Failed to create profile url');
        }

        final newProfile = await getProfileFromUrl(_config, url);
        if (newProfile == null) {
          throw Exception('Failed to get profile from url $url');
        }

        profile = newProfile;
        safeNotifyListeners();
      } else {
        final profile = await getProfile(_config, account.hexEip55);
        if (profile == null) {
          throw Exception('Failed to get profile');
        }

        debugPrint('Profile found: ${profile.username}');

        this.profile = profile;
        safeNotifyListeners();
      }

      Timer.periodic(const Duration(seconds: 1), (timer) {
        getAccountBalance();
        debugPrint('Balance: $balance');
      });
    } catch (e, s) {
      debugPrint('Error loading account: $e');
      debugPrint('Stack trace: $s');
    } finally {
      _creatingProfile = false;
      isLoading = false;
      safeNotifyListeners();
    }
  }

  Future<String?> _generateProfileUsername() async {
    String username = await getRandomUsername();

    const maxTries = 3;
    const baseDelay = Duration(milliseconds: 100);

    for (int tries = 1; tries <= maxTries; tries++) {
      final exists = await profileExists(_config, username);

      if (!exists) {
        return username;
      }

      if (tries > maxTries) break;

      username = await getRandomUsername();
      await delay(baseDelay * tries);
    }

    return null;
  }

  Future<void> getAccountBalance() async {
    try {
      isLoading = true;
      safeNotifyListeners();

      final credentials = _secureService.getCredentials();
      if (credentials == null) {
        throw Exception('No credentials found');
      }

      final privateKey = EthPrivateKey.fromHex(credentials.$2);
      final EthereumAddress owner = privateKey.address;

      final account = await _config.accountFactoryContract.getAddress(
        owner.hexEip55,
      );

      this.account = account;

      final rawBalance = await getBalance(_config, account);

      final token = _config.getPrimaryToken();

      balance = formatCurrency(rawBalance.toString(), token.decimals);
      safeNotifyListeners();
    } catch (e) {
      debugPrint('Error getting balance: $e');
    } finally {
      isLoading = false;
      safeNotifyListeners();
    }
  }

  Future<void> sendBack(double amount) async {
    try {
      sending = true;
      safeNotifyListeners();

      final to = '0xe150f7736BFa6BFce8895F963b3AE72f9e329740';

      final token = _config.getPrimaryToken();

      final parsedAmount = toUnit(amount.toString(), decimals: token.decimals);

      if (parsedAmount == BigInt.zero) {
        return;
      }

      final credentials = _secureService.getCredentials();
      if (credentials == null) {
        throw Exception('Credentials not found');
      }

      final (_, key) = credentials;

      final privateKey = EthPrivateKey.fromHex(key);

      final account = await _config.accountFactoryContract.getAddress(
        privateKey.address.hexEip55,
      );

      final calldata = tokenTransferCallData(
        _config,
        account,
        to,
        parsedAmount,
      );

      final (_, userop) = await prepareUserop(
        _config,
        account,
        privateKey,
        [token.address],
        [calldata],
      );

      final txHash = await submitUserop(_config, userop);

      if (txHash == null) {
        throw Exception('Failed to submit user op');
      }

      final success = await waitForTxSuccess(_config, txHash);
      if (!success) {
        throw Exception('Failed to wait for tx success');
      }

      getAccountBalance();
    } catch (e, s) {
      debugPrint('Error sending back: $e');
      debugPrint('Stack trace: $s');
    } finally {
      sending = false;
      safeNotifyListeners();
    }
  }

  Future<void> send(String id, String to, double amount) async {
    try {
      debugPrint('Sending request: $id');
      sendingRequests[id] = 'In Progress';
      sending = true;
      safeNotifyListeners();

      final token = _config.getPrimaryToken();

      final parsedAmount = toUnit(amount.toString(), decimals: token.decimals);

      if (parsedAmount == BigInt.zero) {
        return;
      }

      final credentials = _secureService.getCredentials();
      if (credentials == null) {
        throw Exception('Credentials not found');
      }

      final (_, key) = credentials;

      final privateKey = EthPrivateKey.fromHex(key);

      final account = await _config.accountFactoryContract.getAddress(
        privateKey.address.hexEip55,
      );

      final calldata = tokenTransferCallData(
        _config,
        account,
        to,
        parsedAmount,
      );

      final (_, userop) = await prepareUserop(
        _config,
        account,
        privateKey,
        [token.address],
        [calldata],
      );

      final txHash = await submitUserop(_config, userop);

      if (txHash == null) {
        throw Exception('Failed to submit user op');
      }

      final success = await waitForTxSuccess(_config, txHash);
      if (!success) {
        throw Exception('Failed to wait for tx success');
      }

      sendingRequests[id] = 'Request Complete';
      safeNotifyListeners();

      getAccountBalance();
    } catch (e, s) {
      debugPrint('Error sending back: $e');
      debugPrint('Stack trace: $s');
    } finally {
      sending = false;
      sendingRequests[id] = 'Request Complete';
      safeNotifyListeners();
    }
  }
}
