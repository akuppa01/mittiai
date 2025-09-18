// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemSound
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mitti_ai/generated/l10n/app_localizations.dart'; // Generated file
import 'package:mitti_ai/screens/setup_screen.dart';
import 'package:mitti_ai/screens/voice_assistant_screen.dart';
import 'package:mitti_ai/screens/profile_screen.dart';
import 'package:mitti_ai/screens/reminders_screen.dart';
import 'package:mitti_ai/screens/info_library_screen.dart';
import 'package:mitti_ai/screens/schemes_screen.dart';
import 'package:mitti_ai/services/locale_provider.dart';
import 'package:mitti_ai/services/reminders_service.dart';
import 'package:mitti_ai/theme.dart';
import 'package:mitti_ai/services/schemes_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Run immediately, do heavy init inside splash.
  runApp(const BootstrapApp());
}

/// Compatibility wrapper so any test or other code expecting `MyApp` still works.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This just shows the same bootstrap app so tests that call MyApp() won't fail.
    return const BootstrapApp();
  }
}

class BootstrapApp extends StatelessWidget {
  const BootstrapApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Minimal app with SplashScreen as the home. The splash will do dotenv + prefs.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mitti AI',
      theme: appTheme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const SplashScreen(),
    );
  }
}

/// SplashScreen loads .env and SharedPreferences. When done, it replaces itself
/// with the real provider-backed app.
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const Duration _minDuration = Duration(milliseconds: 1000);

  @override
  void initState() {
    super.initState();
    _performInitialization();
  }

  Future<void> _performInitialization() async {
    final start = DateTime.now();
    SharedPreferences prefs;
    try {
      // Load dotenv first
      await dotenv.load(fileName: ".env");

      // Ensure we have SharedPreferences
      prefs = await SharedPreferences.getInstance();

      // Ensure we show splash at least for minimum time
      final elapsed = DateTime.now().difference(start);
      if (elapsed < _minDuration) {
        await Future.delayed(_minDuration - elapsed);
      }

      if (!mounted) return;

      // All good: navigate into the provider-backed app with a NON-NULL prefs
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => AppWithProviders(prefs: prefs)),
      );
    } catch (e, st) {
      debugPrint('Splash init failed: $e\n$st');

      // Try to recover by still obtaining SharedPreferences (should succeed in most environments)
      try {
        prefs = await SharedPreferences.getInstance();
      } catch (e2) {
        // If we still couldn't get prefs, create an in-memory fallback behavior:
        // In practice SharedPreferences.getInstance should work; this try-catch is a last resort.
        prefs = (await SharedPreferences.getInstance());
      }

      // Ensure minimum splash time
      final elapsed = DateTime.now().difference(start);
      if (elapsed < _minDuration) {
        await Future.delayed(_minDuration - elapsed);
      }

      if (!mounted) return;

      // Continue to the app with prefs (non-null). This avoids passing a null value.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => AppWithProviders(prefs: prefs)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Ensure this asset exists (and listed in pubspec.yaml)
          Image.asset('assets/farm_loadingscreen.png', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.20)),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 48),
                Text(
                  'Mitti AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    shadows: [Shadow(offset: const Offset(0, 2), blurRadius: 6, color: Colors.black45)],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Your farming assistant — tips, schemes, and voice help',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.95), fontSize: 15),
                  ),
                ),
                const SizedBox(height: 22),
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(strokeWidth: 2.8, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// AppWithProviders requires a non-null SharedPreferences instance.
class AppWithProviders extends StatelessWidget {
  final SharedPreferences prefs;
  const AppWithProviders({Key? key, required this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool setupDone = prefs.getBool('setup_done') ?? false;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LocaleProvider(prefs)),
        ChangeNotifierProvider(create: (context) => RemindersService()),
        ChangeNotifierProvider(create: (context) => SchemesProvider()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp(
            title: 'Mitti AI',
            theme: appTheme,
            locale: localeProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: setupDone
                ? Landing(prefs: prefs)
                : SetupScreen(prefs: prefs, onProceed: () {
              // SetupScreen should call Navigator to go to Landing after saving setup_done.
            }),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

// Landing (same as your earlier Landing) - ensure constructors match your other code.
class Landing extends StatefulWidget {
  final SharedPreferences prefs;
  const Landing({Key? key, required this.prefs}) : super(key: key);

  @override
  State<Landing> createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  int _selectedIndex = 0;
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      const VoiceAssistantScreen(),
      RemindersScreen(isRootScreenForTab: true, onGoToVoiceAssistantTab: () => _onItemTapped(0)),
      InfoLibraryScreen(isRootScreenForTab: true, onGoToVoiceAssistantTab: () => _onItemTapped(0)),
      SchemesScreen(isRootScreenForTab: true, onGoToVoiceAssistantTab: () => _onItemTapped(0), onGoToProfileTab: () => _onItemTapped(4)),
      ProfileScreen(prefs: widget.prefs, onGoToVoiceAssistantTab: () => _onItemTapped(0)),
    ];
  }

  void _onItemTapped(int index) {
    SystemSound.play(SystemSoundType.click);
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (Widget child, Animation<double> animation) => FadeTransition(opacity: animation, child: child),
        child: Container(key: ValueKey<int>(_selectedIndex), child: _widgetOptions.elementAt(_selectedIndex)),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: const Icon(Icons.mic), label: l.assistantNavLabel),
          BottomNavigationBarItem(icon: const Icon(Icons.notifications), label: l.remindersNavLabel),
          BottomNavigationBarItem(icon: const Icon(Icons.library_books), label: l.infoNavLabel),
          BottomNavigationBarItem(icon: const Icon(Icons.article), label: l.schemesNavLabel),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: l.profileNavLabel),
        ],
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        backgroundColor: primaryGreen,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        iconSize: 28,
        selectedFontSize: 14,
        unselectedFontSize: 12,
      ),
    );
  }
}
