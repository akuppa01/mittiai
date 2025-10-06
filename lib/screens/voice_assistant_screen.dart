// lib/screens/voice_assistant_screen.dart
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:mitti_ai/generated/l10n/app_localizations.dart';
import 'package:mitti_ai/services/locale_provider.dart';
import 'package:mitti_ai/theme.dart';
import 'package:mitti_ai/screens/info_library_screen.dart';
import 'package:mitti_ai/screens/schemes_screen.dart';
import 'package:mitti_ai/screens/reminders_screen.dart';
import 'package:mitti_ai/services/sarvam_service.dart';
import 'package:mitti_ai/screens/recents_screen.dart';

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen>
    with SingleTickerProviderStateMixin {
  // --- existing fields (kept intact) ---
  // Add this entire method inside the _VoiceAssistantScreenState class
// Add this method to _VoiceAssistantScreenState
  Future<void> _attemptInitialMicPermissionRequest() async {
    if (!mounted) return;

    PermissionStatus status = await Permission.microphone.status;
    // CRITICAL: Check your debug console for this print statement!
    debugPrint("[_attemptInitialMicPermissionRequest] Current microphone permission status: $status. Speech enabled: $_speechEnabled");

    // This is where a session flag would be checked to prevent re-prompting automatically
    // if this screen is revisited in the same app session.
    // Example: if (_initialMicPromptAttemptedThisSession) return;

    if (status.isDenied) {
      debugPrint("[_attemptInitialMicPermissionRequest] Permission is .denied, requesting automatically...");
      PermissionStatus newStatus = await Permission.microphone.request(); // Shows system dialog
      debugPrint("[_attemptInitialMicPermissionRequest] Status after request: $newStatus");

      if (mounted && newStatus.isGranted) {
        debugPrint("[_attemptInitialMicPermissionRequest] Permission granted after request.");
        // If speech wasn't enabled before, try re-initializing or ensuring it's ready.
        if (!_speechEnabled) {
          debugPrint("[_attemptInitialMicPermissionRequest] Speech not enabled, re-initializing speech services.");
          await _initSpeech();
        }
      }
    } else if (status.isGranted && !_speechEnabled) {
      // If already granted but speech isn't enabled (e.g., _initSpeech failed earlier)
      debugPrint("[_attemptInitialMicPermissionRequest] Permission granted but speech not enabled. Initializing speech.");
      await _initSpeech();
    } else {
      debugPrint("[_attemptInitialMicPermissionRequest] Not requesting permission automatically. Status: $status, SpeechEnabled: $_speechEnabled");
    }
  }

  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _speechEnabled = false;
  bool _isListening = false;
  String _recognizedText = "";
  Timer? _listeningTimer;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  String _currentTipOfTheDay = "";
  final List<String> _tipKeys = ["tipOfTheDay1", "tipOfTheDay2", "tipOfTheDay3"];
  Locale? _previousLocale;

  String? _userName;
  final List<Map<String, String>> _chatMessages = []; // persistent chat in-screen
  final SarvamService _sarvamService = SarvamService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingAssistantAudio = false;

  // --- NEW: overlay dialog + input state ---
  bool _overlayVisible = false;
  String _overlayAssistantText = '';
  final TextEditingController _overlayTextController = TextEditingController();
  bool _isProcessingOverlay = false;

  // Storage key for chat history
  final String _historyKey = 'voice_chat_history';

  @override
  void initState() {
    super.initState();
    _loadUserName();
    //_initSpeech(); // requests permission & initializes speech recognition
    _initTts();
    _loadUserNameAndTip(); // loads tip + username
    _loadHistory();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    // scale goes between 1 and 1.12 for heartbeat effect
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // audio complete handler to reset flag
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlayingAssistantAudio = false);
    });
    _initSpeech();
    // Initialize _previousLocale after context is available and initial tip is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _previousLocale = Provider.of<LocaleProvider>(context, listen: false).locale;
        debugPrint("[VoiceAssistantScreen initState] Initial locale set to: $_previousLocale");
      }
    });
  }

  // Called by initState
  Future<void> _loadUserNameAndTip() async {
    await _loadUserName(); // Loads username
    await _loadTipOfTheDay(); // Loads tip
    if (mounted) {
      setState(() {});
    }
  }

  // ------------------------
  // Locale Change Handling for Tip of the Day
  // ------------------------
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!mounted) return;

    final currentLocale = Provider.of<LocaleProvider>(context).locale;

    _previousLocale ??= currentLocale;

    if (_previousLocale != currentLocale) {
      debugPrint("[VoiceAssistantScreen didChangeDependencies] Locale changed from $_previousLocale to $currentLocale. Updating tip.");
      _previousLocale = currentLocale;
      _forceRefreshTipOfTheDay();
    }
  }

  Future<void> _forceRefreshTipOfTheDay() async {
    if (!mounted) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? currentStoredIndex = prefs.getInt('current_tip_index');

    debugPrint("[_forceRefreshTipOfTheDay] Locale changed. Attempting to refresh tip. Today's stored tip index: $currentStoredIndex");

    if (currentStoredIndex != null && currentStoredIndex != -1) {
      final newLocalizedTip = _getLocalizedTipByIndex(context, currentStoredIndex);
      await prefs.setString('current_tip_of_the_day', newLocalizedTip);

      if (mounted) {
        setState(() {
          _currentTipOfTheDay = newLocalizedTip;
        });
      }
    } else {
      debugPrint("[_forceRefreshTipOfTheDay] No current_tip_index found for today. Calling _loadTipOfTheDay.");
      await _loadTipOfTheDay();
    }
  }

  // ------------------------
  // Initialization / speech
  // ------------------------
  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _userName = prefs.getString('name');
    });
  }

  // Initializes SpeechToText, does not ask for permission here anymore.
  Future<void> _initSpeech() async {
    try {
      // Check if permission is already granted, but don't request here.
      // The request will be handled by _handleMicTap or initial app flow.
      var status = await Permission.microphone.status;
      if (!status.isGranted) {
          debugPrint('[_initSpeech] Microphone permission not granted yet. Will be requested on tap.');
          // Optionally, update _speechEnabled based on current status if STT lib requires it for init.
          // However, speech_to_text initialize might still work and _speechEnabled reflects its state.
      }

      _speechEnabled = await _speechToText.initialize(
        onError: (error) => debugPrint('STT Error: $error'),
        onStatus: (status) => _onSpeechStatus(status),
      );

      final locales = await _speechToText.locales();
      final desiredSttLocale = _mapToSttLocale(Provider.of<LocaleProvider>(context, listen: false).locale);
      final hasLocale = locales.any((l) {
        final id = l.localeId ?? '';
        return id == desiredSttLocale || id.startsWith(desiredSttLocale.split('_')[0]);
      });

      debugPrint("[_initSpeech] STT available locales: ${locales.map((e) => e.localeId).toList()}");
      if (!hasLocale) {
        debugPrint('STT: selected locale $desiredSttLocale not available on device.');
      }
    } catch (e) {
      debugPrint('Speech initialize exception: $e');
      _speechEnabled = false;
    }
    if (!mounted) return;
    setState(() {}); // Reflect _speechEnabled state
    debugPrint("[VoiceAssistantScreen _initSpeech] Initialization complete. _speechEnabled: $_speechEnabled. Mounted: $mounted");
  }


  Future<void> _initTts() async {
    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isPlayingAssistantAudio = false);
    });
    _flutterTts.setErrorHandler((msg) {
      if (mounted) setState(() => _isPlayingAssistantAudio = false);
      debugPrint("TTS Error: $msg");
    });
  }

  void _onSpeechStatus(String status) {
    debugPrint("[VoiceAssistantScreen _onSpeechStatus] Raw status received: '$status', Type: ${status.runtimeType}, _isListening before: $_isListening");

    if (!mounted) {
      debugPrint("[VoiceAssistantScreen _onSpeechStatus] Not mounted, exiting.");
      return;
    }

    String currentStatus = status.toString().trim();
    List<int> charCodes = currentStatus.codeUnits;
    debugPrint("[VoiceAssistantScreen _onSpeechStatus] Trimmed status: '$currentStatus', Length: ${currentStatus.length}, CharCodes: $charCodes");

    if (currentStatus.startsWith('listening')) {
      debugPrint("[VoiceAssistantScreen _onSpeechStatus] Entered listening block.");
      bool needsToStartPulse = false;
      if (!_isListening) {
        setState(() => _isListening = true);
        needsToStartPulse = true;
      } else {
        if (!_animationController.isAnimating) {
          needsToStartPulse = true;
        }
      }
      if (needsToStartPulse) _startPulse();
    } else if (currentStatus == 'notListening' || currentStatus == 'done') {
      debugPrint("[VoiceAssistantScreen _onSpeechStatus] Entered notListening/done block.");
      if (_isListening && mounted) {
        _stopListening();
      } else {
        if (_animationController.isAnimating) {
          _stopPulse();
        }
      }
    } else {
      debugPrint("[VoiceAssistantScreen _onSpeechStatus] Unhandled status: '$currentStatus'");
    }
  }

  // ------------------------
  // Tips, chat history
  // ------------------------
  Future<void> _loadTipOfTheDay() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String? lastDate = prefs.getString('tip_last_date');

    int currentTipIndex = prefs.getInt('current_tip_index') ?? -1;

    debugPrint("[_loadTipOfTheDay] Today: $today, Last saved date: $lastDate, Stored current_tip_index: $currentTipIndex");

    if (lastDate == today && currentTipIndex != -1) {
      debugPrint("[_loadTipOfTheDay] Same day. Using stored tip index: $currentTipIndex");
      _currentTipOfTheDay = _getLocalizedTipByIndex(context, currentTipIndex);
      await prefs.setString('current_tip_of_the_day', _currentTipOfTheDay);
    } else {
      debugPrint("[_loadTipOfTheDay] New day or no tip index stored for today. Selecting new tip cyclically.");
      int lastUsedIndex = prefs.getInt('last_tip_index_used') ?? -1;
      currentTipIndex = (lastUsedIndex + 1) % _tipKeys.length;
      _currentTipOfTheDay = _getLocalizedTipByIndex(context, currentTipIndex);
      await prefs.setString('tip_last_date', today);
      await prefs.setInt('current_tip_index', currentTipIndex);
      await prefs.setInt('last_tip_index_used', currentTipIndex);
      await prefs.setString('current_tip_of_the_day', _currentTipOfTheDay);
      debugPrint("[_loadTipOfTheDay] Saved new tip (Index: $currentTipIndex, Text: '$_currentTipOfTheDay') for $today.");
    }
    debugPrint("[_loadTipOfTheDay] Final _currentTipOfTheDay set to: '$_currentTipOfTheDay'");
  }

  String _getLocalizedTipByIndex(BuildContext context, int tipIndex) {
    final l = AppLocalizations.of(context)!;
    switch (tipIndex) {
      case 0:
        return l.tipOfTheDay1;
      case 1:
        return l.tipOfTheDay2;
      case 2:
        return l.tipOfTheDay3;
      default:
        debugPrint("[_getLocalizedTipByIndex] Warning: tipIndex $tipIndex out of range. Defaulting to first tip.");
        return l.tipOfTheDay1;
    }
  }

  // ------------------------
  // Pulse control
  // ------------------------
  void _startPulse() {
    if (_animationController == null) {
      debugPrint("[VoiceAssistantScreen _startPulse] Animation controller is null.");
      return;
    }
    try {
      _animationController.stop();
      _animationController.reset();
      _animationController.repeat(reverse: true);
      if (_animationController.isAnimating) {
        debugPrint("[VoiceAssistantScreen _startPulse] Pulse animating.");
      } else {
        debugPrint("[VoiceAssistantScreen _startPulse] Pulse not animating immediately after repeat(); will start on next frame.");
      }
    } catch (e, s) {
      debugPrint("[VoiceAssistantScreen _startPulse] Error starting pulse: $e\n$s");
    }
  }

  void _stopPulse() {
    debugPrint("[VoiceAssistantScreen _stopPulse] Attempting to stop pulse.");
    try {
      if (_animationController != null) {
        if (_animationController.isAnimating) _animationController.stop();
        _animationController.reset();
        debugPrint("[VoiceAssistantScreen _stopPulse] Pulse stopped and reset.");
      }
    } catch (e, s) {
      debugPrint("[VoiceAssistantScreen _stopPulse] Error stopping/resetting pulse: $e\n$s");
    }
  }

  // ------------------------
  // Microphone Tap Handler & Permission Logic
  // ------------------------
  Future<void> _handleMicTap() async {
    if (!mounted) return;
    final l = AppLocalizations.of(context)!;

    // Check current status
    PermissionStatus status = await Permission.microphone.status;
    debugPrint("[_handleMicTap] Current microphone permission status: $status");

    if (status.isGranted) {
      _actuallyStartListening();
    } else if (status.isDenied) { // Denied previously, but not permanently.
      _showSnackBarWithAction(
        l.microphonePermissionDeniedPreviously, // "Microphone permission was denied. Please grant it to use this feature."
        l.grantPermissionAction, // "Grant"
        () async {
          PermissionStatus newStatus = await Permission.microphone.request();
          if (newStatus.isGranted) {
            _actuallyStartListening();
          } else if (newStatus.isPermanentlyDenied) {
             _showSnackBarWithAction(
                l.microphonePermissionPermanentlyDenied, // "Microphone permission is permanently denied. Please enable it in app settings."
                l.openSettingsAction, // "Open Settings"
                openAppSettings
            );
          } else {
            //_showSnackBar(l.microphonePermissionNeeded); // "Microphone permission is required to use voice input."
          }
        }
      );
    } else if (status.isPermanentlyDenied) {
      _showSnackBarWithAction(
        l.microphonePermissionPermanentlyDenied,
        l.openSettingsAction,
        openAppSettings
      );
    } else if (status.isRestricted) {
      _showSnackBar(l.microphonePermissionRestricted); // "Microphone access is restricted on this device."
    } else { // status is .limited (iOS specific, treat as granted) or some other state
        // For .limited or any other unhandled state, attempt to request.
        PermissionStatus newStatus = await Permission.microphone.request();
        if (newStatus.isGranted) {
            _actuallyStartListening();
        } else {
            _showSnackBar(l.microphonePermissionNeeded);
        }
    }
  }


  // ------------------------
  // Start / stop listening (core logic without permission checks)
  // ------------------------
  void _actuallyStartListening() async {
    if (!mounted) return; // Moved mounted check up

    // ---- ADD THIS BLOCK ----
    PermissionStatus currentStatus = await Permission.microphone.status;
    if (!currentStatus.isGranted) {
      debugPrint("[_actuallyStartListening] Microphone permission not granted. Status: $currentStatus");
      _showSnackBar(AppLocalizations.of(context)!.microphonePermissionNeeded);
      _stopListening(); // Ensure UI resets if we can't start
      return;
    }
    if (!_speechEnabled) {
       debugPrint("[_actuallyStartListening] Aborted: _speechEnabled is false. Attempting to re-initialize.");
      // Try to re-initialize speech, in case it failed earlier or permission was just granted.
      await _initSpeech();
      if (!_speechEnabled) {
          _showSnackBar(AppLocalizations.of(context)!.speechNotAvailable); // "Speech recognition is not available."
          return;
      }
    }

    if (_isListening && _animationController.isAnimating) {
      debugPrint("[_actuallyStartListening] Aborted: already listening and animating.");
      return;
    }

    if (!mounted) {
      debugPrint("[_actuallyStartListening] Not mounted, returning.");
      return;
    }

    setState(() {
      _overlayVisible = true;
      _isListening = true;
      _overlayTextController.clear();
      _overlayAssistantText = '';
      _isProcessingOverlay = false;
    });
    _startPulse();

    try {
      if (_isPlayingAssistantAudio) {
        debugPrint("[_actuallyStartListening] Stopping ongoing TTS/audio before listening.");
        await _flutterTts.stop();
        await _audioPlayer.stop();
        if (mounted) setState(() => _isPlayingAssistantAudio = false);
      }

      final sttLocale = _mapToSttLocale(Provider.of<LocaleProvider>(context, listen: false).locale);
      await _speechToText.listen(
        onResult: _onSpeechResult,
        localeId: sttLocale,
        cancelOnError: true,
        partialResults: true,
        listenFor: const Duration(seconds: 50),
        pauseFor: const Duration(seconds: 15),
        onSoundLevelChange: (level) {},
      );

      _listeningTimer?.cancel();
      _listeningTimer = Timer(const Duration(seconds: 55), () {
        debugPrint("[_actuallyStartListening listeningTimer] Safety timer expired.");
        if (mounted && _isListening) {
          debugPrint("[_actuallyStartListening listeningTimer] UI still listening, forcing stop.");
          _stopListening();
        }
      });
      debugPrint("[_actuallyStartListening] listen() called with locale $sttLocale.");
    } catch (e, s) {
      debugPrint("[_actuallyStartListening] Exception calling listen(): $e\n$s");
      if (mounted) {
        _showSnackBar('Could not start microphone: $e');
        _stopListening();
      }
    }
  }

  void _stopListening() async {
    _listeningTimer?.cancel();
    debugPrint("[VoiceAssistantScreen _stopListening] Called.");

    if (!mounted) {
      debugPrint("[VoiceAssistantScreen _stopListening] Not mounted. Aborting.");
      return;
    }

    if (_speechToText.isListening) {
      try {
        debugPrint("[VoiceAssistantScreen _stopListening] STT isListening true, calling stop.");
        await _speechToText.stop();
        debugPrint("[VoiceAssistantScreen _stopListening] STT stop completed.");
      } catch (e) {
        debugPrint('[VoiceAssistantScreen _stopListening] speechToText.stop() error: $e');
      }
    } else {
      debugPrint("[VoiceAssistantScreen _stopListening] STT isListening already false.");
    }

    _stopPulse();

    if (mounted) {
      if (_isListening) {
        setState(() {
          _isListening = false;
        });
      }
    } else {
      debugPrint("[VoiceAssistantScreen _stopListening] Not mounted after STT stop.");
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (!mounted) return;
    setState(() {
      _recognizedText = result.recognizedWords;
    });

    if (result.finalResult && _recognizedText.isNotEmpty) {
      _stopListening();
      _processCommand(_recognizedText);
    } else if (result.finalResult && _recognizedText.isEmpty) {
      _stopListening();
      if (mounted) _speak(AppLocalizations.of(context)!.speakCommandToSearch);
    }
  }

  // ------------------------
  // Existing logic for processing and handling Sarvam reply
  // ------------------------
  void _processCommand(String command) {
    if (!mounted) return;
    if (command.isEmpty) {
      _speak(AppLocalizations.of(context)!.speakCommandToSearch);
      return;
    }

    setState(() {
      _chatMessages.insert(0, {'role': 'user', 'text': command});
      _recognizedText = '';
    });

    if (mounted) {
      setState(() {
        _overlayTextController.text = '';
        _isProcessingOverlay = true;
        _overlayAssistantText = '';
      });
    }

    _handleSarvamTurn(command);
  }

  Future<void> _handleSarvamTurn(String userText) async {
    if (!mounted) return;
    final l = AppLocalizations.of(context)!;
    final localeProvider = context.read<LocaleProvider>();

    _showSnackBar(l.pleaseWaitMessage);

    // Pass language hint to Sarvam
    final sarvamLang = _mapToSarvamLangCode(localeProvider.locale); // e.g. 'te-IN'
    final rawAssistantText = await _sarvamService.chatReply(userText, preferredLanguage: sarvamLang);

    if (!mounted) return;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    if (rawAssistantText == null) {
      _showSnackBar(l.tryAgainLater);
      if (mounted) {
        setState(() {
        _isProcessingOverlay = false;
        _overlayAssistantText = l.tryAgainLater;
      });
      }
      return;
    }

    // sanitize assistant text before showing/TTS
    final assistantTextSanitized = _sanitizeAssistantText(rawAssistantText);

    if (mounted) {
      setState(() {
        _chatMessages.insert(0, {'role': 'assistant', 'text': assistantTextSanitized});
        _overlayAssistantText = assistantTextSanitized;
        _isProcessingOverlay = false;
      });
    }

    // persist history (store assistant then user — keeps chronological order)
    await _saveHistoryEntry({'role': 'assistant', 'text': assistantTextSanitized});
    await _saveHistoryEntry({'role': 'user', 'text': userText});

    // request TTS from Sarvam
    final audioFile = await _sarvamService.textToSpeechToFile(
      assistantTextSanitized,
      targetLanguageCode: sarvamLang,
    );

    if (!mounted) return;

    if (audioFile != null) {
      try {
        setState(() => _isPlayingAssistantAudio = true);
        await _audioPlayer.stop();
        await _audioPlayer.play(DeviceFileSource(audioFile.path));
      } catch (e) {
        debugPrint('Audio playback error: $e -> falling back to flutter_tts');
        setState(() => _isPlayingAssistantAudio = false);
        await _flutterTts.setLanguage(_mapToTtsLocale(localeProvider.locale));
        setState(() => _isPlayingAssistantAudio = true);
        await _flutterTts.speak(assistantTextSanitized);
      }
    } else {
      await _flutterTts.setLanguage(_mapToTtsLocale(localeProvider.locale));
      setState(() => _isPlayingAssistantAudio = true);
      await _flutterTts.speak(assistantTextSanitized);
    }
  }

  String _mapToSarvamLangCode(Locale locale) {
    final lc = locale.languageCode.toLowerCase();
    if (lc == 'te') return 'te-IN';
    if (lc == 'hi') return 'hi-IN';
    return 'en-IN';
  }

  String _mapToTtsLocale(Locale locale) => _mapToSarvamLangCode(locale);

  String _mapToSttLocale(Locale locale) {
    final lc = locale.languageCode.toLowerCase();
    if (lc == 'te') return 'te_IN';
    if (lc == 'hi') return 'hi_IN';
    return 'en_IN';
  }

  String _sanitizeAssistantText(String raw) {
    String s = raw;

    // Remove headings (lines starting with #)
    s = s.replaceAll(RegExp(r'(^|\n)\s*#{1,6}\s*'), '\n');

    // Remove code fences
    s = s.replaceAll(RegExp(r'''[\s\S]*?'''), '');

    // Replace inline code backticks
    s = s.replaceAll(RegExp(r'`([^`]+)`'), r'\1');

    // Remove emphasis markers *, **, _, __
    s = s.replaceAll(RegExp(r'(\*{1,3}|_{1,3})'), '');

    // Convert list markers to bullet char
    s = s.replaceAll(RegExp(r'(^|\n)\s*[-*+]\s*'), '\n• ');

    // Remove HTML tags
    s = s.replaceAll(RegExp(r'<[^>]*>'), '');

    // Normalize newlines and whitespace
    s = s.replaceAll(RegExp(r'\r\n?'), '\n');
    s = s.replaceAll(RegExp(r'\n{2,}'), '\n\n');
    s = s.replaceAll(RegExp(r'[ \t]{2,}'), ' ');

    s = s.trim();

   /* // Keep first 3 sentences
    final sentences = RegExp(r'([^\.\?\!]+[\.\?\!]?)').allMatches(s).map((m) => m.group(0)!.trim()).toList();
    if (sentences.isNotEmpty && sentences.length > 3) {
      s = sentences.take(3).join(' ').trim();
    } */

    return s;
  }

  Future<void> _speak(String text) async {
    if (_isPlayingAssistantAudio) return;
    if (text.isNotEmpty) {
      if (!mounted) return;
      final localeProvider = context.read<LocaleProvider>();
      await _flutterTts.setLanguage(_mapToTtsLocale(localeProvider.locale));
      if (mounted) setState(() => _isPlayingAssistantAudio = true);
      await _flutterTts.speak(text);
    }
  }

  // ------------------------
  // Persistence: save / load chat history list of JSON objects
  // ------------------------
  Future<void> _saveHistoryEntry(Map<String, String> entry) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_historyKey) ?? '[]';
      final List<dynamic> list = jsonDecode(raw);
      list.insert(0, entry);
      while (list.length > 200) list.removeLast();
      await prefs.setString(_historyKey, jsonEncode(list));
    } catch (e) {
      debugPrint('saveHistoryEntry error: $e');
    }
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_historyKey) ?? '[]';
      final List<dynamic> list = jsonDecode(raw);
      if (mounted) {
        setState(() {
          _chatMessages.clear();
          for (var item in list) {
            if (item is Map && item['role'] != null && item['text'] != null) {
              _chatMessages.add({'role': item['role'], 'text': item['text']});
            }
          }
        });
      }
    } catch (e) {
      debugPrint('loadHistory error: $e');
    }
  }

  /// Call this from ProfileScreen when user logs out to clear chat history
  Future<void> clearChatHistoryFromProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
      if (mounted) setState(() => _chatMessages.clear());
    } catch (e) {
      debugPrint('clearChatHistory error: $e');
    }
  }

  // ------------------------
  // Overlay controls (send typed text, close overlay)
  // ------------------------
  Future<void> _overlaySendText() async {
    final text = _overlayTextController.text.trim();
    if (text.isEmpty) {
      _showSnackBar('Enter message or speak');
      return;
    }
    _processCommand(text);
  }

  Future<void> _overlayClose() async { // Made async
    if (mounted) {
      await _audioPlayer.stop(); // Stop Sarvam TTS
      await _flutterTts.stop();  // Stop fallback TTS
      setState(() {
        _overlayVisible = false;
        _overlayAssistantText = '';
        _isProcessingOverlay = false;
        _isPlayingAssistantAudio = false; // Reset audio playing flag
      });
    }
  }

  // ------------------------
  // UI / helpers
  // ------------------------
  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 3)));
  }

  void _showSnackBarWithAction(String message, String actionLabel, VoidCallback onActionPressed) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.yellow[100], // Set the background color
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.black87), // Set message text color
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.black87, // Set button text color
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: onActionPressed,
            child: Text(actionLabel),
          ),
        ],
      ),
      duration: const Duration(seconds: 2),
    ));
  }


  @override
  void dispose() {
    debugPrint("[VoiceAssistantScreen dispose] Disposing screen...");
    _speechToText.stop();
    _speechToText.cancel();
    _flutterTts.stop();
    _audioPlayer.dispose();

    try {
      _animationController.dispose();
    } catch (e) {
      debugPrint("[VoiceAssistantScreen dispose] animationController dispose error: $e");
    }

    _listeningTimer?.cancel();
    _overlayTextController.dispose();
    debugPrint("[VoiceAssistantScreen dispose] Dispose complete.");
    super.dispose();
  }

  Widget _buildGridItem(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    final screenHeight = MediaQuery.of(context).size.height;
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: screenHeight * 0.045, color: color),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: screenHeight * 0.02, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    String greetingLine1;
    if (_userName != null && _userName!.isNotEmpty) greetingLine1 = "👋, Namaste ${_userName!}!";
    else greetingLine1 = "👋 Namaste!";

    String greetingLine2 = l.agriAssistantTagline;

    debugPrint("[VoiceAssistantScreen Build] Checking Tip of the Day. _currentTipOfTheDay: '$_currentTipOfTheDay'");
    bool shouldShowTip = _currentTipOfTheDay.isNotEmpty;
    debugPrint("[VoiceAssistantScreen Build] Should show Tip Card: $shouldShowTip");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryGreen,
        toolbarHeight: 80.0,
        centerTitle: true,
        elevation: 1.0,
        automaticallyImplyLeading: false,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(greetingLine1, style: const TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            Text(greetingLine2, style: const TextStyle(color: Colors.white, fontSize: 16.0), textAlign: TextAlign.center),
          ],
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: screenHeight * 0.02),
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: GestureDetector(
                        onTap: _isListening ? _stopListening : _handleMicTap, // MODIFIED HERE
                        child: CircleAvatar(
                          radius: screenHeight * 0.09,
                          backgroundColor: _isListening ? Colors.red.shade100 : primaryGreen.shade100,
                          child: Icon(_isListening ? Icons.mic_off : Icons.mic, size: screenHeight * 0.08, color: _isListening ? Colors.red : primaryGreen),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_isListening ? "${l.voiceAssistantTitle}..." : l.askYourDoubtsPrompt, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                    const SizedBox(height: 8),

                    if (_recognizedText.isNotEmpty && !_isListening)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                        child: Text("You said: $_recognizedText", style: TextStyle(fontSize: 14, color: primaryGreen, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      ),

                    const SizedBox(height: 12),
                    Text(l.quickAccessTitle, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),

                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: (screenWidth / 2.2) / (screenHeight * 0.12),
                      children: <Widget>[
                        _buildGridItem(context, l.libraryNavLabel, Icons.library_books, Colors.orange, () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const InfoLibraryScreen(isRootScreenForTab: false)));
                        }),
                        _buildGridItem(context, l.schemesNavLabel, Icons.account_balance_wallet, Colors.green, () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const SchemesScreen(isRootScreenForTab: false)));
                        }),
                        _buildGridItem(context, l.remindersNavLabel, Icons.notifications, Colors.blue, () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const RemindersScreen(isRootScreenForTab: false)));
                        }),
                        _buildGridItem(context, l.historyTitle, Icons.history, Colors.purple, () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const RecentsScreen()));
                        }),
                      ],
                    ),

                    const SizedBox(height: 16),
                    if (_currentTipOfTheDay.isNotEmpty)
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text("💡 ${l.tipOfTheDayTitle}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryGreen)),
                            const SizedBox(height: 6),
                            Text(_currentTipOfTheDay, style: TextStyle(fontSize: 14, color: Colors.grey[800]), maxLines: 3, overflow: TextOverflow.ellipsis),
                          ]),
                        ),
                      ),
                    SizedBox(height: screenHeight * 0.01),
                  ],
                ),
              ),
            ),
          ),

          // Overlay Section
          if (_overlayVisible)
            Positioned.fill(
              child: Stack(
                children: [
                  const ModalBarrier(color: Colors.black54, dismissible: false),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.92,
                      height: MediaQuery.of(context).size.height * 0.60,
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(child: Text(AppLocalizations.of(context)!.voiceAssistantTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                                  IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () async { // made async
                                        debugPrint("[Overlay Close Button] TAPPED! Stopping listening and closing overlay.");
                                        _stopListening();
                                        await _overlayClose(); // await the async method
                                      }
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.redAccent : Colors.grey),
                                                const SizedBox(width: 8),
                                                Text(_isListening ? AppLocalizations.of(context)!.speakingNowPrompt : 'Listening stopped', style: const TextStyle(fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Text(_recognizedText.isNotEmpty ? _recognizedText : AppLocalizations.of(context)!.speakCommandToSearch, textAlign: TextAlign.center),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      if (_isProcessingOverlay)
                                        Row(mainAxisAlignment: MainAxisAlignment.center, children: const [CircularProgressIndicator(), SizedBox(width: 12), Text('Processing...')])
                                      else if (_overlayAssistantText.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
                                          child: Text(_overlayAssistantText),
                                        ),
                                      const SizedBox(height: 12),
                                    ],
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                                    color: _isListening ? Colors.redAccent : Theme.of(context).primaryColor,
                                    tooltip: _isListening ? 'Stop listening' : 'Start listening',
                                    onPressed: () { // This is the mic button inside the overlay
                                      if (_isListening) {
                                        _stopListening();
                                      } else {
                                        _overlayTextController.clear();
                                        _handleMicTap(); // MODIFIED HERE (also use _handleMicTap for consistency)
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _overlayTextController,
                                      textInputAction: TextInputAction.send,
                                      onSubmitted: (_) => _overlaySendText(),
                                      decoration: InputDecoration(hintText: 'Type your doubt here', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton( // Changed from Flexible(child: ElevatedButton) for consistency
                                    onPressed: _overlaySendText,
                                    child: const Icon(Icons.send),
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(64, 48), // Ensure reasonable tap target
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
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
