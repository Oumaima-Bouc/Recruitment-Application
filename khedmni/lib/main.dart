import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khedmni/screens/job_feed_screen.dart';
import 'core/routes/route_names.dart';
import 'core/routes/app_router.dart';
import 'core/utils/database_init.dart';
import 'logic/cubits/auth_cubit.dart';
import 'logic/cubits/job_cubit.dart';
import 'logic/cubits/company_cubit.dart';
import 'logic/cubits/notification_cubit.dart';
import 'logic/cubits/application_cubit.dart';
import 'logic/cubits/companies_cubit.dart';
import 'data/repositories/auth_repository.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'logic/cubits/language_cubit.dart';
import 'logic/cubits/language_state.dart';
import 'logic/cubits/theme_cubit.dart';
import 'logic/cubits/theme_state.dart';
import 'data/local/database_helper.dart';
import 'core/utils/deep_links.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // If running on desktop, initialize sqflite_common_ffi so the global databaseFactory is available.
  // This prevents the "databaseFactory not initialized" error when using `openDatabase`.
  if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Prevent google_fonts from attempting runtime network font fetching on desktop/test environments
  // This avoids runtime exceptions when network access is restricted.
  GoogleFonts.config.allowRuntimeFetching = false;
  
  // Initialize and seed database on first launch — start it asynchronously so it doesn't block startup and cause ANR.
  // The initialization will still run, but app UI comes up immediately.
  runApp(const KhedmniApp());

  // Fire-and-forget DB initialization to avoid blocking the UI thread during app startup.
  unawaited(initializeDatabase());
  
  // Cleanup stuck user (Temporary fix for specific user)
  Future.delayed(const Duration(seconds: 1), () async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete('users', where: 'email = ?', whereArgs: ['leena.ikhlef@ensia.edu.dz']);
      // Removed debug prints to avoid noisy output on hot reload
    } catch(e) { /* noop: ignore cleanup errors */ }
  });
}

const Color kPrimaryDarkBlue = Color(0xFF1D3557);

final GlobalKey<NavigatorState> _appNavKey = GlobalKey<NavigatorState>();

class KhedmniApp extends StatefulWidget {
  const KhedmniApp({super.key});

  @override
  State<KhedmniApp> createState() => _KhedmniAppState();
}

class _KhedmniAppState extends State<KhedmniApp> {
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    // Initialize deep link support and subscribe to events
    DeepLinks.init();
    _sub = DeepLinks.uriLinkStream.listen((uri) {
      _processUri(uri);
    }, onError: (_) {});
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  // We no longer use uni_links directly; DeepLinks.init() will attempt to query initial links.
  Future<void> _handleInitialUri() async {
    // Keep for compatibility but delegate to DeepLinks.init
    await DeepLinks.init();
  }

  void _processUri(Uri? uri) {
    if (uri == null) return;
    // Support khedmni://verify?code=1234 and https://.../verify?code=1234
    final code = uri.queryParameters['code'];
    if (code != null && _appNavKey.currentState != null) {
      _appNavKey.currentState!.pushNamed(RouteNames.emailVerificationInterstitial, arguments: {'code': code});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<AuthCubit>(create: (_) => AuthCubit(AuthRepository())),
        BlocProvider<JobCubit>(create: (_) => JobCubit()),
        BlocProvider<CompanyCubit>(create: (_) => CompanyCubit()),
        BlocProvider<NotificationCubit>(create: (_) => NotificationCubit()),
        BlocProvider<ApplicationCubit>(create: (_) => ApplicationCubit()),
        BlocProvider<CompaniesCubit>(create: (_) => CompaniesCubit()..loadCompanies()),
        BlocProvider<LanguageCubit>(create: (_) => LanguageCubit()),
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()..loadTheme()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<LanguageCubit, LanguageState>(
            builder: (context, state) {
              return MaterialApp(
                title: 'Khedmni App',
                debugShowCheckedModeBanner: false,
                navigatorKey: _appNavKey,
                locale: state is LanguageLoaded ? state.locale : null,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                themeMode: themeState.mode,
                theme: ThemeData(
                  textTheme: GoogleFonts.latoTextTheme(),
                  scaffoldBackgroundColor: const Color(0xFFEBEDF0),
                  useMaterial3: true,
                  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1D3557)),
                  appBarTheme: const AppBarTheme(
                    backgroundColor: Colors.white,
                    elevation: 3,
                    foregroundColor: Colors.black,
                  ),
                ),
                darkTheme: ThemeData.dark().copyWith(
                  textTheme: GoogleFonts.latoTextTheme(ThemeData.dark().textTheme),
                  scaffoldBackgroundColor: const Color(0xFF0B0F12),
                  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1D3557), brightness: Brightness.dark),
                  appBarTheme: const AppBarTheme(
                    backgroundColor: Color(0xFF0F1720),
                    elevation: 3,
                    foregroundColor: Colors.white,
                  ),
                ),
                initialRoute: RouteNames.welcome,
                onGenerateRoute: AppRouter.onGenerateRoute,
              );
            },
          );
        },
      ),
    );
  }
}

// 👇 Keep your HomePage class unchanged (still accessible after login/signup)
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  final List<Widget> _widgetOptions = const [
    JobFeedScreen(),
    Center(child: Text('Messages Screen - Placeholder')),
    Center(child: Text('Profile Screen - Placeholder')),
  ];



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions[_selectedIndex]),
      /*
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 10,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, _) => CustomNavBar(
            icons: _navIcons,
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
            animationValue: _animation.value,
          ),
        ),
      ),
      */
    );
  }
}
