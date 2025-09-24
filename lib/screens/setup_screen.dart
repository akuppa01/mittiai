import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// REMOVED: import 'package:firebase_auth/firebase_auth.dart';
import 'package:mitti_ai/generated/l10n/app_localizations.dart';
import 'package:mitti_ai/screens/landing_screen.dart'; // UPDATED: Import Landing from its new file
import 'package:mitti_ai/services/locale_provider.dart';
import 'package:mitti_ai/services/schemes_provider.dart';
import 'package:mitti_ai/services/login_tracker_service.dart'; // ADDED: For tracking login sessions
import 'package:mitti_ai/services/anonymous_tracker_service.dart';
//import '../services/schemes_service.dart'; // Assuming this was commented out intentionally

class SetupScreen extends StatefulWidget {
  final SharedPreferences prefs;
  final VoidCallback? onProceed;
  final bool isEditing; // Added for edit mode

  const SetupScreen({
    super.key,
    required this.prefs,
    this.onProceed,
    this.isEditing = false, // Default to false
  });

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _villageController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _cropTypeController;
  String? _selectedLanguage; // For the APP's language

  String? _selectedState; // Stores the selected English state name
  final List<String> _indianStates = [ // English state names
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram',
    'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu',
    'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal',
    'Andaman and Nicobar Islands', 'Chandigarh', 'Dadra and Nagar Haveli and Daman and Diu',
    'Delhi', 'Jammu and Kashmir', 'Ladakh', 'Lakshadweep', 'Puducherry'
  ];

  bool _isFormValid = false;

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'hi', 'name': 'हिंदी (Hindi)'},
    {'code': 'te', 'name': 'తెలుగు (Telugu)'},
  ];

  final String _emailSuffix = '@gmail.com';
  
  final LoginTrackerService _loginTrackerService = LoginTrackerService();
  final AnonymousTrackerService _anonymousTrackerService = AnonymousTrackerService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _villageController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _cropTypeController = TextEditingController();

    _loadExistingPreferences();
    _nameController.addListener(_validateForm);
    _villageController.addListener(_validateForm);
    _phoneController.addListener(_validateForm);
    _cropTypeController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nameController.removeListener(_validateForm);
    _villageController.removeListener(_validateForm);
    _phoneController.removeListener(_validateForm);
    _cropTypeController.removeListener(_validateForm);

    _nameController.dispose();
    _villageController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cropTypeController.dispose();
    super.dispose();
  }

  void _validateForm() {
    if (!mounted) return;
    setState(() {
      _isFormValid = _nameController.text.trim().length >= 3 &&
          _villageController.text.trim().length >= 3 &&
          _phoneController.text.trim().length == 10 &&
          _cropTypeController.text.trim().length >= 3 &&
          _selectedLanguage != null &&
          _selectedState != null;
    });
  }

  Future<void> _loadExistingPreferences() async {
    final name = widget.prefs.getString('name');
    final village = widget.prefs.getString('village');
    final email = widget.prefs.getString('email');
    final phone = widget.prefs.getString('phone');
    final cropType = widget.prefs.getString('crop_type');
    final languageCode = widget.prefs.getString('language_code');
    final stateCode = widget.prefs.getString('state_code');
    // REMOVED: Load authUid
    // final authUid = widget.prefs.getString('firebase_auth_uid');


    if (name != null) _nameController.text = name;
    if (village != null) _villageController.text = village;
    if (email != null) {
      if (email.endsWith(_emailSuffix)) {
        _emailController.text = email.substring(0, email.length - _emailSuffix.length);
      } else {
        _emailController.clear(); // If it's not a @gmail.com email, clear the field for new input consistent with UI
      }
    }
    if (phone != null) {
      if (phone.startsWith('+91')) {
        _phoneController.text = phone.substring(3).trim();
      } else {
        _phoneController.text = phone.trim();
      }
    }
    if (cropType != null) _cropTypeController.text = cropType;

    if (languageCode != null && _languages.any((lang) => lang['code'] == languageCode)) {
      _selectedLanguage = languageCode;
    } else {
      _selectedLanguage = 'en'; // Default APP language choice
    }

    if (stateCode != null && _indianStates.contains(stateCode)) {
      _selectedState = stateCode;
    }

    if (mounted) {
      setState(() {});
      _validateForm();
    }
  }

  Future<void> _saveAndContinue() async {
    if (_formKey.currentState!.validate() && _selectedLanguage != null && _selectedState != null) {
      // REMOVED: Firebase User authentication logic
      // User? user = FirebaseAuth.instance.currentUser;
      // if (user == null) { ... }
      // if (user == null) { ... }

      // final String authUid = user.uid; // Get the Firebase Auth UID
      final String fullPhoneNumber = '+91${_phoneController.text.trim()}'; // The phone number from the form

      // Save all profile data to SharedPreferences
      // REMOVED: await widget.prefs.setString('firebase_auth_uid', authUid); // Store auth UID
      await widget.prefs.setString('name', _nameController.text.trim());
      await widget.prefs.setString('village', _villageController.text.trim());
      final String emailToSave = _emailController.text.trim().isNotEmpty
          ? '${_emailController.text.trim()}$_emailSuffix'
          : '';
      await widget.prefs.setString('email', emailToSave);
      await widget.prefs.setString('phone', fullPhoneNumber); // Store the full phone number as a field
      await widget.prefs.setString('crop_type', _cropTypeController.text.trim());
      await widget.prefs.setString('language_code', _selectedLanguage!);
      await widget.prefs.setString('state_code', _selectedState!);
      await widget.prefs.setString('user_state_name', _selectedState!);

      if (!widget.isEditing) {
        await widget.prefs.setBool('setup_done', true);
      }

      final String? selectedLanguageName = _languages
          .firstWhere((lang) => lang['code'] == _selectedLanguage, orElse: () => {})['name'];

      // REVERTED: Track login session with phone number as userId
      await _loginTrackerService.trackLoginSession(
        fullPhoneNumber, // Pass the full phone number as userId
        name: _nameController.text.trim(),
        village: _villageController.text.trim(),
        state: _selectedState!,
        email: emailToSave,
        phoneNumber: fullPhoneNumber, // Pass the full phone number as phoneNumber field
        cropType: _cropTypeController.text.trim(),
        languageName: selectedLanguageName,
      );

      if (!mounted) return;
      final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
      await localeProvider.reloadLocale();

      widget.onProceed?.call();

      if (!mounted) return;
      try {
        final schemesProv = Provider.of<SchemesProvider>(context, listen: false);
        schemesProv.refresh(userStateName: _selectedState, runBlocking: false);
      } catch (e) {
        debugPrint('Error launching schemes refresh: $e');
      }

      if (!mounted) return;
      if (widget.isEditing) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Landing(prefs: widget.prefs)),
        );
      }
    } else {
      _validateForm();
      if (mounted && !_isFormValid) {
        final errorMessage = AppLocalizations.of(context)?.formValidationError ?? 'Please fill all required fields and make selections.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  Future<void> _skipSetup() async {
    await _anonymousTrackerService.trackAnonymousSession();
    // Clear user profile keys
    await widget.prefs.remove('name');
    await widget.prefs.remove('village');
    await widget.prefs.remove('email');
    await widget.prefs.remove('phone');
    await widget.prefs.remove('crop_type');
    await widget.prefs.remove('state_code');
    await widget.prefs.remove('user_state_name');
    // REMOVED: await widget.prefs.remove('firebase_auth_uid');

    await widget.prefs.setString('language_code', _selectedLanguage!); // Changed for consistency

    if (!mounted) return;
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    await localeProvider.reloadLocale();

    widget.onProceed?.call();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Landing(prefs: widget.prefs)),
    );
  }

  Widget _buildMandatoryLabel(String labelText) {
    return RichText(
      text: TextSpan(
        text: labelText,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
        children: const <TextSpan>[
          TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizedStrings = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Image.asset('assets/mitti_ai_logo.png', height: 100),
                const SizedBox(height: 24),
                Text(
                  localizedStrings.setupScreenTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  localizedStrings.setupScreenSubtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 32),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    label: _buildMandatoryLabel(localizedStrings.languageLabel),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.language_outlined),
                  ),
                  value: _selectedLanguage,
                  hint: Text(localizedStrings.languageHint),
                  isExpanded: true,
                  items: _languages.map((Map<String, String> lang) {
                    return DropdownMenuItem<String>(
                      value: lang['code'],
                      child: Text(lang['name']!),
                    );
                  }).toList(),
                  onChanged: (String? newValue) async {
                    if (newValue != null) {
                      await widget.prefs.setString('language_code', newValue);
                      if (!mounted) return;
                      final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
                      await localeProvider.reloadLocale();

                      setState(() {
                        _selectedLanguage = newValue;
                        _validateForm();
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null) {
                      return localizedStrings.languageValidationError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    label: _buildMandatoryLabel(localizedStrings.nameLabel),
                    hintText: localizedStrings.nameHint,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 3) {
                      return localizedStrings.nameValidationError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _villageController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    label: _buildMandatoryLabel(localizedStrings.villageLabel),
                    hintText: localizedStrings.villageHint,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.location_city_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 3) {
                      return localizedStrings.villageValidationError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                 TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: localizedStrings.emailOptionalLabel, // Using localized string
                    hintText: localizedStrings.emailHint,          // Using localized string
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.email_outlined),
                    suffixText: _emailSuffix, // Static suffix for @gmail.com
                    suffixStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color?.withAlpha((255 * 0.6).round())), // Style the suffix
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      // Email is optional, so an empty field is valid.
                      return null;
                    }
                    // If something is typed, assume it's a username and validate the full email format.
                    final fullEmail = value.trim() + _emailSuffix;
                    if (!fullEmail.contains('@') || fullEmail.startsWith('@')) {
                        return localizedStrings.emailInvalidError; // e.g., "Please enter a valid email address"
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    label: _buildMandatoryLabel(localizedStrings.phoneLabel),
                    hintText: localizedStrings.phoneHint,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.phone_outlined),
                    prefixText: '+91 ',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return localizedStrings.phoneValidationError;
                    }
                    if (value.length != 10) {
                      return localizedStrings.phoneInvalidError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cropTypeController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    label: _buildMandatoryLabel(localizedStrings.cropTypeLabel),
                    hintText: localizedStrings.cropTypeHint,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.eco_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 3) {
                      return localizedStrings.cropTypeValidationError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    label: _buildMandatoryLabel(localizedStrings.stateLabel),
                    hintText: localizedStrings.stateHint,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.map_outlined),
                  ),
                  value: _selectedState,
                  isExpanded: true,
                  items: _indianStates.map((String stateName) {
                    return DropdownMenuItem<String>(
                      value: stateName,
                      child: Text(stateName),
                    );
                  }).toList(),
                  onChanged: (String? newValue) async {
                    if (newValue != null) {
                      await widget.prefs.setString('state_code', newValue);
                      if (!mounted) return;
                      final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
                      await localeProvider.reloadLocale();
                      setState(() {
                        _selectedState = newValue;
                        _validateForm();
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null) {
                      return localizedStrings.stateValidationError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text(localizedStrings.saveAndContinueButton),
                      onPressed: _isFormValid ? _saveAndContinue : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (!widget.isEditing)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _skipSetup,
                          child: Text(localizedStrings.skipButton),
                        ),
                      )
                    else
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(localizedStrings.cancelButtonLabel),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
