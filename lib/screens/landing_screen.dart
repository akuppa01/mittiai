import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemSound
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mitti_ai/generated/l10n/app_localizations.dart';
import 'package:mitti_ai/screens/voice_assistant_screen.dart';
import 'package:mitti_ai/screens/profile_screen.dart';
import 'package:mitti_ai/screens/reminders_screen.dart';
import 'package:mitti_ai/screens/info_library_screen.dart';
import 'package:mitti_ai/screens/schemes_screen.dart';
import 'package:mitti_ai/theme.dart'; // Assuming primaryGreen comes from here

/// Landing (tabbed) screen — same as yours with minor cosmetic changes kept intact.
class Landing extends StatefulWidget {
  final SharedPreferences prefs;
  const Landing({super.key, required this.prefs});

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
      VoiceAssistantScreen(),
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
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: Container(
          key: ValueKey<int>(_selectedIndex),
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
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