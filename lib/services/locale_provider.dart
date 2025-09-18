import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Removed: import 'package:mitti_ai/generated/l10n/app_localizations.dart'; // Unused

class LocaleProvider extends ChangeNotifier {
  final SharedPreferences _prefs;

  // --- Start of language configuration ---
  static const String _defaultLanguageCode = 'en';
  static const String _defaultLanguageName = 'English';

  static final Map<String, String> _codeToDisplayName = {
    'en': 'English',
    'hi': 'Hindi',
    'te': 'Telugu',
  };

  static final Map<String, String> _displayNameToCode = {
    'English': 'en',
    'Hindi': 'hi',
    'Telugu': 'te',
  };

  static final Map<String, Locale> _codeToLocale = {
    'en': const Locale('en'),
    'hi': const Locale('hi'),
    'te': const Locale('te'),
  };
  // --- End of language configuration ---

  late String _languageCode;
  late String _languageName;
  late Locale _locale;

  LocaleProvider(this._prefs) {
    _languageCode = _prefs.getString('language_code') ?? _defaultLanguageCode;
    _locale = _codeToLocale[_languageCode] ?? const Locale(_defaultLanguageCode);
    _languageName = _codeToDisplayName[_languageCode] ?? _defaultLanguageName;
    _ensureValidLocale();
  }

  void _ensureValidLocale() {
    // Ensure the loaded/default language code is actually supported
    if (!_codeToDisplayName.containsKey(_languageCode)) {
      _languageCode = _defaultLanguageCode;
      _locale = _codeToLocale[_defaultLanguageCode]!;
      _languageName = _codeToDisplayName[_defaultLanguageCode]!;
      // Persist this correction
      _prefs.setString('language_code', _languageCode);
    }
  }

  Locale get locale => _locale;
  String get languageName => _languageName; // Used by ProfileScreen dropdown
  String get languageCode => _languageCode; // Can be useful for debugging or other logic

  List<String> get supportedDisplayLanguages => _displayNameToCode.keys.toList();

  Future<void> setLanguage(String newDisplayLanguageName) async {
    final newCode = _displayNameToCode[newDisplayLanguageName];
    if (newCode != null && newCode != _languageCode) {
      if (_codeToLocale.containsKey(newCode)) {
        _languageCode = newCode;
        _locale = _codeToLocale[newCode]!;
        _languageName = _codeToDisplayName[newCode]!;
        await _prefs.setString('language_code', _languageCode);
        notifyListeners();
      } else {
        // This case should ideally not happen if supportedDisplayLanguages is derived correctly
        // Consider logging to a more robust system in production
        // print("Error: Attempted to set an unsupported language code: $newCode");
      }
    }
  }

  // Method to reload locale from SharedPreferences and notify listeners
  Future<void> reloadLocale() async {
    _languageCode = _prefs.getString('language_code') ?? _defaultLanguageCode;
    _locale = _codeToLocale[_languageCode] ?? const Locale(_defaultLanguageCode);
    _languageName = _codeToDisplayName[_languageCode] ?? _defaultLanguageName;
    _ensureValidLocale(); // Make sure it's a valid/supported locale
    notifyListeners(); // Notify listeners of the change
  }


  // Helper to get Locale from code, used by SetupScreen
  static Locale getLocaleFromCode(String code) {
    return _codeToLocale[code] ?? const Locale(_defaultLanguageCode);
  }

  // Helper to get supported language map for SetupScreen
  static Map<String, String> getSupportedLanguagesForSetup() {
    return _codeToDisplayName;
  }
}
