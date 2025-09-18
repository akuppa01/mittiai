import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mitti_ai/main.dart'; // To navigate to Landing (and then SetupScreen via MyApp logic)
import 'package:mitti_ai/screens/setup_screen.dart'; // To navigate directly to SetupScreen
import 'package:mitti_ai/generated/l10n/app_localizations.dart';
import 'package:mitti_ai/services/locale_provider.dart';
import 'package:mitti_ai/services/schemes_provider.dart';
import 'package:mitti_ai/theme.dart'; // Added for primaryGreen
//import '../services/schemes_service.dart'; // Import LocaleProvider

class ProfileScreen extends StatefulWidget {
  final SharedPreferences prefs;
  // Add this callback
  final VoidCallback? onGoToVoiceAssistantTab; 

  const ProfileScreen({super.key, required this.prefs, this.onGoToVoiceAssistantTab});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _updateLoginState() {
    if (mounted) {
      setState(() {});
    }
  }
  Future<void> _logout() async {
    // Clear user profile keys
    await widget.prefs.remove('name');
    await widget.prefs.remove('village');
    await widget.prefs.remove('state_code');        // existing
    await widget.prefs.remove('user_state_name');   // ensure we remove the human-readable key too
    await widget.prefs.setBool('setup_done', false);

    // Clear chat history
    await widget.prefs.remove('voice_chat_history'); // Added this line

    // Reset app language to English (optional)
    if (mounted) {
      await Provider.of<LocaleProvider>(context, listen: false).setLanguage('English');
    }

    // Refresh schemes to repopulate central schemes (non-blocking)
    // We try/catch to avoid UI crash if network/db fails
    try {
      // Check if context is still valid before using it.
      if (!mounted) return;
      final schemesProv = Provider.of<SchemesProvider>(context, listen: false);
      // Refresh for no-state -> central schemes
      schemesProv.refresh(userStateName: null, runBlocking: false);
    } catch (e) {
      debugPrint('Schemes refresh on logout failed: $e');
    }

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Landing(prefs: widget.prefs)),
          (Route<dynamic> route) => false,
    );
  }

  Future<void> _navigateToLogin() async {
    // final result = // Result not used, so can be removed
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SetupScreen(prefs: widget.prefs, onProceed: _updateLoginState,)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentDisplayLanguage = localeProvider.languageName;

    final bool isUserLoggedIn = widget.prefs.getBool('setup_done') ?? false;
    final String? userName = widget.prefs.getString('name');
    final String? userVillage = widget.prefs.getString('village');
    // Using user_state_name for display as per previous update, assuming it's preferred.
    final String? userStateDisplay = widget.prefs.getString('user_state_name'); 

    final padding = MediaQuery.of(context).size.width * 0.06;

    // Define the style for section headers
    final TextStyle sectionHeaderStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.bold,
      color: Colors.black, // Explicitly black as requested
    ) ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black); // Fallback

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (widget.onGoToVoiceAssistantTab != null) {
              widget.onGoToVoiceAssistantTab!();
            } else {
              Navigator.of(context).pushReplacementNamed('/voice_assistant');
            }
          },
        ),
        backgroundColor: primaryGreen,
        toolbarHeight: 80.0,
        centerTitle: true,
        elevation: 1.0,
        automaticallyImplyLeading: false, 
        iconTheme: const IconThemeData(color: Colors.white), 
        title: Text(l.profileTitle, style: const TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 20),
          child: ListView(
            children: [
              if (isUserLoggedIn) ...[
                Text(l.profileUserDetailsLabel, style: sectionHeaderStyle),
                const SizedBox(height: 16),
                if (userName != null && userName.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.person, size: 28.0, color: Colors.blue), // Icon color changed
                    horizontalTitleGap: 8.0, // Reduced gap
                    title: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.titleMedium, 
                        children: <TextSpan>[
                          TextSpan(text: '${l.profileNameLabel}: ', style: const TextStyle(fontWeight: FontWeight.bold)), // Label bold
                          TextSpan(text: userName), // Value normal
                        ],
                      ),
                    ),
                  ),
                if (userVillage != null && userVillage.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.location_city, size: 28.0, color: Colors.orange), // Icon color changed
                    horizontalTitleGap: 8.0, // Reduced gap
                    title: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.titleMedium,
                        children: <TextSpan>[
                          TextSpan(text: '${l.profileVillageLabel}: ', style: const TextStyle(fontWeight: FontWeight.bold)), // Label bold
                          TextSpan(text: userVillage), // Value normal
                        ],
                      ),
                    ),
                  ),
                if (userStateDisplay != null && userStateDisplay.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.map_outlined, size: 28.0, color: Colors.green), // Icon color changed
                    horizontalTitleGap: 8.0, // Reduced gap
                    title: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.titleMedium,
                        children: <TextSpan>[
                          TextSpan(text: '${l.stateLabel}: ', style: const TextStyle(fontWeight: FontWeight.bold)), // Label bold
                          TextSpan(text: userStateDisplay), // Value normal
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
              ],
              Text(l.languageSettingsLabel, style: sectionHeaderStyle),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: currentDisplayLanguage,
                items: localeProvider.supportedDisplayLanguages.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    localeProvider.setLanguage(newValue);
                  }
                },
                decoration: InputDecoration(
                  labelText: l.languageDropdownLabel,
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder( // Keep focused border green from previous update
                    borderSide: BorderSide(color: primaryGreen, width: 2.0),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              if (isUserLoggedIn)
                ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: Text(l.logoutButton),
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white
                  ),
                )
              else
                ElevatedButton.icon(
                  icon: const Icon(Icons.login),
                  label: Text(l.loginButtonLabel),
                  onPressed: _navigateToLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
