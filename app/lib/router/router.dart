import 'package:app/screens/feed/screen.dart';
import 'package:app/state/state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// import '../design/examples.dart';
Future<String?> redirectHandler(
  BuildContext context,
  GoRouterState state,
) async {
  final url = state.uri.toString();
  // override redirection if needed

  // final deeplinkDomains = dotenv.get('DEEPLINK_DOMAINS').split(',');

  // final connectedAccountAddress =
  //     context.read<OnboardingState>().connectedAccountAddress;

  // for (final deeplinkDomain in deeplinkDomains) {
  //   if (url.contains(deeplinkDomain) && !url.contains('?deepLink=')) {
  //     if (connectedAccountAddress == null) {
  //       return '/';
  //     }

  //     // add timestamp to url to make it unique
  //     final uniqueUrl = addTimestampToUrl(url);
  //     return '/${connectedAccountAddress.hexEip55}?deepLink=${Uri.encodeComponent(uniqueUrl)}';
  //   }
  // }

  return url;
}

GoRouter createRouter(
  GlobalKey<NavigatorState> rootNavigatorKey,
  GlobalKey<NavigatorState>
  appShellNavigatorKey, // TODO: for later, normally you add a shell navigator with tabs here
  List<NavigatorObserver> observers, {
  String? userId,
}) => GoRouter(
  initialLocation: userId != null ? '/$userId/posts' : '/',
  debugLogDiagnostics: kDebugMode,
  navigatorKey: rootNavigatorKey,
  observers: observers,
  redirect: redirectHandler,
  routes: [
    ShellRoute(
      navigatorKey: appShellNavigatorKey,
      builder: (context, state, child) {
        final userId = state.pathParameters['userId'];

        if (userId == null) {
          return const SizedBox.shrink();
        }

        return provideAppState(userId, child);
      },
      routes: [
        GoRoute(
          name: 'Posts',
          path: '/:userId/posts',
          builder: (context, state) {
            // return const DesignSystemScreen();
            return const SocialFeedScreen();
          },
        ),
      ],
    ),
  ],
);
