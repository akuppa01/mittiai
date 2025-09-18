import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mitti_ai/generated/l10n/app_localizations.dart';
import 'package:mitti_ai/main.dart'; // Import Landing to navigate
import 'package:mitti_ai/services/locale_provider.dart';
import 'package:mitti_ai/services/schemes_provider.dart';
//import '../services/schemes_service.dart'; // Assuming this was commented out intentionally

class SetupScreen extends StatefulWidget {
  final SharedPreferences prefs;
  final VoidCallback? onProceed;

  const SetupScreen({
    super.key,
    required this.prefs,
    this.onProceed,
  });

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _villageController;
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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _villageController = TextEditingController();
    _loadExistingPreferences();
    _nameController.addListener(_validateForm);
    _villageController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nameController.removeListener(_validateForm);
    _villageController.removeListener(_validateForm);
    _nameController.dispose();
    _villageController.dispose();
    super.dispose();
  }

  void _validateForm() {
    if (!mounted) return;
    setState(() {
      _isFormValid = _nameController.text.trim().isNotEmpty &&
          _villageController.text.trim().isNotEmpty &&
          _selectedLanguage != null &&
          _selectedState != null;
    });
  }

  Future<void> _loadExistingPreferences() async {
    final name = widget.prefs.getString('name');
    final village = widget.prefs.getString('village');
    final languageCode = widget.prefs.getString('language_code');
    final stateCode = widget.prefs.getString('state_code');

    if (name != null) _nameController.text = name;
    if (village != null) _villageController.text = village;

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
      await widget.prefs.setString('name', _nameController.text.trim());
      await widget.prefs.setString('village', _villageController.text.trim());
      await widget.prefs.setString('language_code', _selectedLanguage!);
      await widget.prefs.setString('state_code', _selectedState!);
      await widget.prefs.setString('user_state_name', _selectedState!);
      await widget.prefs.setBool('setup_done', true);

      if (mounted) {
        // Ensure LocaleProvider reflects the final saved language
        // This might be redundant if onChanged already updated it, but ensures consistency.
        await Provider.of<LocaleProvider>(context, listen: false).reloadLocale();
      }

      widget.onProceed?.call();

      try {
        final schemesProv = Provider.of<SchemesProvider>(context, listen: false);
        schemesProv.refresh(userStateName: _selectedState, runBlocking: false);
      } catch (e) {
        debugPrint('Error launching schemes refresh: $e');
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Landing(prefs: widget.prefs)),
      );
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
    await widget.prefs.remove('name');
    await widget.prefs.remove('village');
    await widget.prefs.remove('state_code');
    await widget.prefs.remove('user_state_name');
    // Use the current _selectedLanguage, which is updated by dropdown and guaranteed to be non-null
    await widget.prefs.setString('language_code', _selectedLanguage!); 

    if (mounted) {
      await Provider.of<LocaleProvider>(context, listen: false).reloadLocale();
    }
    widget.onProceed?.call();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Landing(prefs: widget.prefs)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // AppLocalizations will now use the locale from LocaleProvider
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
                    labelText: localizedStrings.languageLabel,
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
                      if (mounted) {
                        await Provider.of<LocaleProvider>(context, listen: false).reloadLocale();
                      }
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
                  decoration: InputDecoration(
                    labelText: localizedStrings.nameLabel,
                    hintText: localizedStrings.nameHint,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return localizedStrings.nameValidationError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _villageController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: localizedStrings.villageLabel,
                    hintText: localizedStrings.villageHint,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.location_city_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return localizedStrings.villageValidationError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: localizedStrings.stateLabel, // Ensure 'stateLabel' exists in ARB files
                    hintText: localizedStrings.stateHint, // Ensure 'stateHint' exists in ARB files
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
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedState = newValue;
                      _validateForm();
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return localizedStrings.stateValidationError; // Ensure 'stateValidationError' exists in ARB files
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
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _skipSetup,
                        child: Text(localizedStrings.skipButton),
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
