import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mitti_ai/generated/l10n/app_localizations.dart';
import 'package:mitti_ai/screens/landing_screen.dart';
import 'package:mitti_ai/services/locale_provider.dart';
import 'package:mitti_ai/services/schemes_provider.dart';
import 'package:mitti_ai/services/login_tracker_service.dart';
import 'package:mitti_ai/services/anonymous_tracker_service.dart';
import 'package:country_code_picker/country_code_picker.dart'; // Added by Agent

class SetupScreen extends StatefulWidget {
  final SharedPreferences prefs;
  final VoidCallback? onProceed;
  final bool isEditing;

  const SetupScreen({
    super.key,
    required this.prefs,
    this.onProceed,
    this.isEditing = false,
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
  String? _selectedLanguage;

  String? _selectedState;
  final List<String> _indianStates = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram',
    'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu',
    'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal',
    'Andaman and Nicobar Islands', 'Chandigarh', 'Dadra and Nagar Haveli and Daman and Diu',
    'Delhi', 'Jammu and Kashmir', 'Ladakh', 'Lakshadweep', 'Puducherry'
  ];

  bool _isFormValid = false;
  String? _selectedCountryCode = '+91'; // Added by Agent

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'hi', 'name': 'हिंदी (Hindi)'},
    {'code': 'te', 'name': 'తెలుగు (Telugu)'},
  ];

  // final String _emailSuffix = ''; // Removed by Agent
  
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
          _phoneController.text.trim().isNotEmpty && // Modified by Agent
          _selectedCountryCode != null &&
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


    if (name != null) _nameController.text = name;
    if (village != null) _villageController.text = village;
    if (email != null) {
      // if (email.endsWith(_emailSuffix)) { // Removed by Agent
      //   _emailController.text = email.substring(0, email.length - _emailSuffix.length); // Removed by Agent
      // } else { // Removed by Agent
        _emailController.clear();
      // } // Removed by Agent
    }
    if (phone != null) { // Modified by Agent
      if (phone.startsWith('+')) {
        final countryCodeMatch = RegExp(r'^\+(\d+)').firstMatch(phone);
        if (countryCodeMatch != null) {
          _selectedCountryCode = countryCodeMatch.group(0);
          _phoneController.text = phone.substring(_selectedCountryCode!.length).trim();
        } else {
          _phoneController.text = phone.trim();
        }
      } else {
        _phoneController.text = phone.trim();
      }
    }
    if (cropType != null) _cropTypeController.text = cropType;

    if (languageCode != null && _languages.any((lang) => lang['code'] == languageCode)) {
      _selectedLanguage = languageCode;
    } else {
      _selectedLanguage = 'en';
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
      final String fullPhoneNumber = '$_selectedCountryCode${_phoneController.text.trim()}'; // Modified by Agent

      await widget.prefs.setString('name', _nameController.text.trim());
      await widget.prefs.setString('village', _villageController.text.trim());
      final String emailToSave = _emailController.text.trim(); // Modified by Agent
      await widget.prefs.setString('email', emailToSave);
      await widget.prefs.setString('phone', fullPhoneNumber);
      await widget.prefs.setString('crop_type', _cropTypeController.text.trim());
      await widget.prefs.setString('language_code', _selectedLanguage!);
      await widget.prefs.setString('state_code', _selectedState!);
      await widget.prefs.setString('user_state_name', _selectedState!);

      if (!widget.isEditing) {
        await widget.prefs.setBool('setup_done', true);
      }

      final String? selectedLanguageName = _languages
          .firstWhere((lang) => lang['code'] == _selectedLanguage, orElse: () => {})['name'];

      await _loginTrackerService.trackLoginSession(
        fullPhoneNumber,
        name: _nameController.text.trim(),
        village: _villageController.text.trim(),
        state: _selectedState!,
        email: emailToSave,
        phoneNumber: fullPhoneNumber,
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
    await widget.prefs.remove('name');
    await widget.prefs.remove('village');
    await widget.prefs.remove('email');
    await widget.prefs.remove('phone');
    await widget.prefs.remove('crop_type');
    await widget.prefs.remove('state_code');
    await widget.prefs.remove('user_state_name');

    await widget.prefs.setString('language_code', _selectedLanguage!); 

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
                    labelText: localizedStrings.emailOptionalLabel,
                    hintText: localizedStrings.emailHint,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.email_outlined),
                    // suffixText: _emailSuffix, // Removed by Agent
                    // suffixStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color?.withAlpha((255 * 0.6).round())),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return null;
                    }
                    // final fullEmail = value.trim() + _emailSuffix; // Removed by Agent
                    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'); // Added by Agent
                    if (!emailRegex.hasMatch(value.trim())) { // Modified by Agent
                        return localizedStrings.emailInvalidError; // Modified by Agent
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row( // Added by Agent
                  children: [ // Added by Agent
                    CountryCodePicker( // Added by Agent
                      onChanged: (CountryCode countryCode) { // Added by Agent
                        setState(() { // Added by Agent
                          _selectedCountryCode = countryCode.dialCode; // Added by Agent
                          _validateForm(); // Added by Agent
                        }); // Added by Agent
                      }, // Added by Agent
                      initialSelection: _selectedCountryCode, // Added by Agent
                      favorite: ['IN', 'US'], // Added by Agent
                      showCountryOnly: false, // Added by Agent
                      showOnlyCountryWhenClosed: false, // Added by Agent
                      alignLeft: false, // Added by Agent
                      dialogTextStyle: Theme.of(context).textTheme.bodyMedium, // Added by Agent
                      searchStyle: Theme.of(context).textTheme.bodyMedium, // Added by Agent
                      dialogSize: Size(MediaQuery.of(context).size.width * 0.8, MediaQuery.of(context).size.height * 0.6), // Added by Agent
                      builder: (countryCode) { // Added by Agent
                        return Container( // Added by Agent
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15), // Modified by Agent: Adjusted vertical padding
                          decoration: BoxDecoration( // Added by Agent
                            border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38)), // Modified by Agent: Used Theme's outline color
                            borderRadius: BorderRadius.circular(8), // Added by Agent
                          ), // Added by Agent
                          child: Row( // Added by Agent
                            mainAxisSize: MainAxisSize.min, // Added by Agent
                            children: [ // Added by Agent
                              Text(countryCode?.dialCode ?? '', style: Theme.of(context).textTheme.bodyLarge), // Added by Agent
                              const Icon(Icons.arrow_drop_down), // Added by Agent
                            ], // Added by Agent
                          ), // Added by Agent
                        ); // Added by Agent
                      }, // Added by Agent
                    ), // Added by Agent
                    const SizedBox(width: 8), // Spacing between picker and text field // Added by Agent
                    Expanded( // Added by Agent
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          label: _buildMandatoryLabel(localizedStrings.phoneLabel),
                          hintText: localizedStrings.phoneHint,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.phone_outlined),
                          // Removed prefixText: ' ',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return localizedStrings.phoneValidationError;
                          }
                          return null;
                        },
                      ), // Added by Agent
                    ), // Added by Agent
                  ],
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