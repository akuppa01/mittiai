import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mitti_ai/screens/landing_screen.dart'; // UPDATED: To navigate to Landing (from its new file)
import 'package:mitti_ai/screens/setup_screen.dart'; // To navigate directly to SetupScreen
import 'package:mitti_ai/generated/l10n/app_localizations.dart';
import 'package:mitti_ai/services/locale_provider.dart';
import 'package:mitti_ai/services/schemes_provider.dart';
import 'package:mitti_ai/theme.dart'; // Added for primaryGreen
import 'package:mitti_ai/services/login_tracker_service.dart'; // ADDED: For tracking login sessions
import 'package:mitti_ai/services/anonymous_tracker_service.dart';
import 'package:device_info_plus/device_info_plus.dart'; // ADDED: For getting device info
import 'dart:io'; // ADDED: For Platform check
import 'package:url_launcher/url_launcher.dart'; // ADDED: For launching URLs

class ProfileScreen extends StatefulWidget {
  final SharedPreferences prefs;
  // Add this callback
  final VoidCallback? onGoToVoiceAssistantTab;

  const ProfileScreen({
    super.key,
    required this.prefs,
    this.onGoToVoiceAssistantTab,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ADDED: Instantiate LoginTrackerService
  final LoginTrackerService _loginTrackerService = LoginTrackerService();
  final AnonymousTrackerService _anonymousTrackerService = AnonymousTrackerService();

  // Support URL
  static const String _supportUrl = 'https://shared-pyramid-d1e.notion.site/Mitti-Support-27759aec04b08077bf66e328ad3984ac?source=copy_link';

  void _updateLoginState() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _logout() async {
    // REVERTED: Get userId (phone number) for logout
    final String? userId = widget.prefs.getString('phone'); 
    String? deviceId; // Declare deviceId

    if (userId != null) { // Use userId for tracking logout
      try {
        final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
        if (Platform.isAndroid) {
          final AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
          deviceId = androidInfo.id;
        } else if (Platform.isIOS) {
          final IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
          deviceId = iosInfo.identifierForVendor;
        } else {
          deviceId = 'unknown_device';
        }
      } catch (e) {
        debugPrint('Error getting device info for logout: \$e');
      }

      if (deviceId != null) {
        await _loginTrackerService.trackLogoutSession(userId, deviceId); // Pass userId
      }
      // REMOVED: Firebase Auth sign out
      // await FirebaseAuth.instance.signOut();
      // print('Firebase user signed out successfully.');

    } else {
      print('Warning: No phone number found in SharedPreferences for logout. Proceeding with local data clear.'); // REVERTED message
    }

    // Clear user profile keys in SharedPreferences
    await widget.prefs.remove('name');
    await widget.prefs.remove('village');
    await widget.prefs.remove('email');
    await widget.prefs.remove('phone');
    await widget.prefs.remove('crop_type');
    await widget.prefs.remove('state_code'); // existing
    await widget.prefs.remove('user_state_name'); // ensure we remove the human-readable key too
    await widget.prefs.setBool('setup_done', false);
    // REMOVED: Clear auth UID from local prefs
    // await widget.prefs.remove('firebase_auth_uid');

    // Clear chat history
    await widget.prefs.remove('voice_chat_history'); // Added this line

    // Reset app language to English (optional)
    if (mounted) {
      await Provider.of<LocaleProvider>(context, listen: false).setLanguage('English');
    }

    // Refresh schemes to repopulate central schemes (non-blocking)
    try {
      if (!mounted) return;
      final schemesProv = Provider.of<SchemesProvider>(context, listen: false);
      schemesProv.refresh(userStateName: null, runBlocking: false); // Refresh for no-state -> central schemes
    } catch (e) {
      debugPrint('Schemes refresh on logout failed: \$e');
    }

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Landing(prefs: widget.prefs)),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _navigateToLogin() async {
    await _anonymousTrackerService.trackAnonymousLogout();
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SetupScreen(prefs: widget.prefs, onProceed: _updateLoginState)),
    );
  }

  Future<void> _navigateToEditProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SetupScreen(
          prefs: widget.prefs,
          onProceed: () {
            if (mounted) {
              setState(() {});
            }
          },
          isEditing: true, // Pass a flag to indicate editing mode
        ),
      ),
    );
  }

  // Method to launch the support URL
  Future<void> _launchSupportUrl() async {
    final Uri url = Uri.parse(_supportUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)?.urlLaunchError ?? 'Could not open support page.')),
        );
      }
      debugPrint('Could not launch \$_supportUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentDisplayLanguage = localeProvider.languageName;

    final bool isUserLoggedIn = widget.prefs.getBool('setup_done') ?? false;
    final String? userName = widget.prefs.getString('name');
    final String? userVillage = widget.prefs.getString('village');
    final String? userEmail = widget.prefs.getString('email');
    final String? userPhone = widget.prefs.getString('phone');
    final String? userCropType = widget.prefs.getString('crop_type');
    // Using user_state_name for display as per previous update, assuming it's preferred.
    final String? userStateDisplay = widget.prefs.getString('user_state_name');

    final padding = MediaQuery.of(context).size.width * 0.06;

    // Define the style for section headers
    final TextStyle sectionHeaderStyle = Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black, // Explicitly black as requested
            ) ??
        const TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black); // Fallback

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l.profileUserDetailsLabel, style: sectionHeaderStyle),
                    IconButton(
                      icon: const Icon(Icons.edit, color: primaryGreen),
                      onPressed: _navigateToEditProfile,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (userName != null && userName.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.person, size: 28.0, color: Colors.blue), // Icon color changed
                    horizontalTitleGap: 8.0, // Reduced gap
                    title: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.titleMedium,
                        children: <TextSpan>[
                          TextSpan(
                              text: '${l.profileNameLabel}: ',
                              style: const TextStyle(fontWeight: FontWeight.bold)), // Label bold
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
                          TextSpan(
                              text: '${l.profileVillageLabel}: ',
                              style: const TextStyle(fontWeight: FontWeight.bold)), // Label bold
                          TextSpan(text: userVillage), // Value normal
                        ],
                      ),
                    ),
                  ),
                if (userEmail != null && userEmail.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.email_outlined, size: 28.0, color: Colors.redAccent),
                    horizontalTitleGap: 8.0,
                    title: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.titleMedium,
                        children: <TextSpan>[
                          TextSpan(
                              text: '${l.profileEmailLabel}: ',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: userEmail),
                        ],
                      ),
                    ),
                  ),
                if (userPhone != null && userPhone.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.phone_outlined, size: 28.0, color: Colors.purpleAccent),
                    horizontalTitleGap: 8.0,
                    title: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.titleMedium,
                        children: <TextSpan>[
                          TextSpan(
                              text: '${l.profilePhoneLabel}: ',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: userPhone),
                        ],
                      ),
                    ),
                  ),
                if (userCropType != null && userCropType.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.eco_outlined, size: 28.0, color: Colors.teal),
                    horizontalTitleGap: 8.0,
                    title: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.titleMedium,
                        children: <TextSpan>[
                          TextSpan(
                              text: '${l.profileCropTypeLabel}: ',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: userCropType),
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
                          TextSpan(
                              text: '${l.stateLabel}: ',
                              style: const TextStyle(fontWeight: FontWeight.bold)), // Label bold
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
              const SizedBox(height: 24), // Added space
              // REMOVED: Privacy Policy Link ListTile
              const SizedBox(height: 32),
              if (isUserLoggedIn)
                ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: Text(l.logoutButton),
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white),
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
              const SizedBox(height: 48), // Space before support info
              // Support URL Info at the bottom center
              Align(
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      l.supportText ?? 'Support:',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    GestureDetector(
                      onTap: _launchSupportUrl, // MODIFIED: Call the new method to launch URL
                      child: Text(
                        l.mittiAiSupportLink, // MODIFIED: Use new localization key
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).primaryColor,
                              decoration: TextDecoration.underline,
                            ),
                      ),
                    ),
                    const SizedBox(height: 4), // Small space between URL and message
                    Text(
                      l.supportMessage ??
                          'Any queries/support, follow the above link.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20), // Space at the very bottom
            ],
          ),
        ),
      ),
    );
  }
}
