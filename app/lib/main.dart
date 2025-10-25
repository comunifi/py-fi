import 'package:app/router/router.dart';
import 'package:app/services/config/service.dart';
import 'package:app/services/preferences/preferences.dart';
import 'package:app/services/secure/secure.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flywind/flywind.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  await SecureService().init(await SharedPreferences.getInstance());
  await PreferencesService().init(await SharedPreferences.getInstance());

  final ConfigService configService = ConfigService();

  final config = await configService.getLocalConfig();
  if (config == null) {
    throw Exception('Community not found in local asset');
  }

  await config.initContracts();

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final _rootNavigatorKey = GlobalKey<NavigatorState>();
  final _appShellNavigatorKey = GlobalKey<NavigatorState>();
  final observers = <NavigatorObserver>[];

  late GoRouter router;

  @override
  void initState() {
    super.initState();

    String publicKey = '';
    if (!SecureService().hasCredentials()) {
      (publicKey, _) = SecureService().createCredentials();
    } else {
      (publicKey, _) = SecureService().getCredentials()!;
    }

    router = createRouter(
      _rootNavigatorKey,
      _appShellNavigatorKey,
      observers,
      userId: publicKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Flywind(
      themeMode: ThemeMode.system, // shouldn't mix material and cupertino
      themeData: FlyThemeData.withDefaults(),
      appBuilder: (context) {
        return ScaffoldMessenger(
          child: CupertinoApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Comunifi',
            theme: CupertinoThemeData(
              primaryColor: const Color(0xFF009686), // Purple theme
              brightness: Brightness.light,
            ),
            routerConfig: router,
          ),
        );
      },
    );
  }
}
