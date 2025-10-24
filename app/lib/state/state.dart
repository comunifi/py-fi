import 'package:app/services/config/config.dart';
import 'package:app/state/feed.dart';
import 'package:app/state/profile.dart';
import 'package:app/state/wallet.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

Widget provideAppState(
  String userId,
  Widget? child, {
  Widget Function(BuildContext, Widget?)? builder,
}) => MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => FeedState()),
    ChangeNotifierProvider(create: (_) => WalletState()),
  ],
  builder: builder,
  child: child,
);

Widget provideAccountState(BuildContext context, Config config, Widget child) {
  return MultiProvider(
    key: Key('profile-provider'),
    providers: [
      ChangeNotifierProvider(
        key: Key('profiles'),
        create: (_) => ProfileState(config),
      ),
    ],
    child: child,
  );
}
