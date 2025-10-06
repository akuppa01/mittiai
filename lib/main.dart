// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemSound
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mitti_ai/generated/l10n/app_localizations.dart'; // Generated file
import 'package:mitti_ai/screens/setup_screen.dart';
import 'package:mitti_ai/screens/landing_screen.dart';
import 'package:mitti_ai/services/locale_provider.dart';
import 'package:mitti_ai/services/reminders_service.dart';
import 'package:mitti_ai/theme.dart';
import 'package:mitti_ai/services/schemes_provider.dart';
import 'package:firebase_core/firebase_core.dart'; // Already imported, ensuring it's there
import 'package:mitti_ai/firebase_options.dart'; // <<< ADDED THIS IMPORT

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase <<< MODIFIED
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // >>> END MODIFICATION

  // Load SharedPreferences
  final prefs = await SharedPreferences.getInstance(); // MODIFIED
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatefulWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Called when setup completes (passed to SetupScreen if needed)
  void _onSetupComplete() {
    if (mounted) {
      setState(() {
        // Causes rebuild if anything depends on prefs.getBool('setup_done')
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool setupDone = widget.prefs.getBool('setup_done') ?? false;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LocaleProvider(widget.prefs)),
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
            // We show a SplashScreen first which will decide where to go.
            home: SplashScreen(
              prefs: widget.prefs,
              setupDone: setupDone,
              onSetupComplete: _onSetupComplete,
            ),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

/// SplashScreen widget that shows an image and then navigates to Setup or Landing.
class SplashScreen extends StatefulWidget {
  final SharedPreferences prefs;
  final bool setupDone;
  final VoidCallback? onSetupComplete;

  const SplashScreen({
    super.key,
    required this.prefs,
    required this.setupDone,
    this.onSetupComplete,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Minimum splash duration
  static const Duration minimumSplashDuration = Duration(milliseconds: 1800);

  @override
  void initState() {
    super.initState();
    _startSplashSequence();
  }

  Future<void> _startSplashSequence() async {
    // Wait at least the minimum duration and allow the app a frame to settle.
    await Future.delayed(const Duration(milliseconds: 200));

    // Ensure minimum display time (use Future.wait if you have other async init)
    await Future.delayed(minimumSplashDuration);

    // After splash, route to Setup or Landing
    if (!mounted) return;

    if (widget.setupDone) {
      // Go to Landing
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => Landing(prefs: widget.prefs)),
      );
    } else {
      // Not setup done: go to SetupScreen. Pass the callback so parent can update if needed.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => SetupScreen(prefs: widget.prefs, onProceed: widget.onSetupComplete)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Splash UI: fullscreen farm photo + app name + subtle progress indicator
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/farm_loadingscreen.png',
            fit: BoxFit.cover,
            // If image might not load instantly, you can include a colored background
            // color: Colors.grey.shade900, colorBlendMode: BlendMode.softLight,
          ),

          // A translucent overlay and content
          Container(
            color: Colors.black.withOpacity(0.22),
          ),

          // Centered content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 60),
                // Optional small logo or app title near top center
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

                // Small caption
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Your farming assistant — tips, schemes, and voice help',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.95), fontSize: 15),
                  ),
                ),

                const SizedBox(height: 22),

                // Progress indicator
                Padding(
                  padding: const EdgeInsets.only(bottom: 36.0),
                  child: Column(
                    children: const [
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(strokeWidth: 2.8, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
