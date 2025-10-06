// lib/services/sarvam_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
// Remove: import 'package:flutter_dotenv/flutter_dotenv.dart'; // No longer needed
import 'package:path_provider/path_provider.dart';

class SarvamService {
  final Dio _dio;

  // endpoints (keep them here so it's easy to change)
  final String _chatUrl = 'https://api.sarvam.ai/v1/chat/completions';
  final String _ttsUrl = 'https://api.sarvam.ai/text-to-speech';

  // Access the API key defined at compile time
  static const String _apiKey = String.fromEnvironment('SARVAM_API_KEY');

  SarvamService({Dio? dio}) : _dio = dio ?? Dio() {
    // Optional: Check if the API key was provided at compile time
    if (_apiKey.isEmpty) {
      // You could throw an error, log a warning, or handle this case as needed.
      // For a production build, you'd expect this to always be set.
      print('WARNING: SARVAM_API_KEY was not provided at compile time.');
    }
  }

  /// chatReply: ask the model to answer in plain farmer-friendly language,
  /// *and* instruct it to produce approximately double the typical brief answer length.
  /// The preferredLanguage remains optional.
  Future<String?> chatReply(String userText, {String model = 'sarvam-m', String? preferredLanguage}) async {
    try {
      if (_apiKey.isEmpty) throw Exception('SARVAM_API_KEY missing or not provided at compile time');

      // System instruction:
      // - keep language plain and practical
      // - avoid markdown and code blocks
      // - produce around twice the length of a typical short answer (i.e., expand and add one brief practical example or one extra sentence of steps)
      final systemInstruction = preferredLanguage != null
          ? 'You are a helpful assistant for small farmers. Answer in $preferredLanguage in simple language but with more detail (2 paragraphs). Keep answers practical and easy to follow. Provide approximately twice the usual brief answer length (i.e., expand the reply so it contains about two short paragraphs or roughly double the number of short sentences you would normally give), but stay focused and actionable. Do NOT add markdown, headings, code blocks, or long technical lists — just plain text.'
          : 'You are a helpful assistant for small farmers. Answer in plain, simple language. Keep answers practical and easy to follow. Provide approximately twice the usual brief answer length (i.e., expand the reply so it contains about two short paragraphs or roughly double the number of short sentences you would normally give), but stay focused and actionable. Do NOT add markdown, headings, code blocks, or long technical lists — just plain text.';

      final body = {
        'model': model,
        'messages': [
          {'role': 'system', 'content': systemInstruction},
          {'role': 'user', 'content': userText}
        ],
      };

      final resp = await _dio.post(
        _chatUrl,
        data: jsonEncode(body),
        options: Options(headers: {
          'api-subscription-key': _apiKey, // Use the compile-time constant
          'Content-Type': 'application/json',
          'accept': 'application/json',
        }),
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = resp.data;
        final choices = (data['choices'] as List<dynamic>?) ?? [];
        if (choices.isNotEmpty) {
          final content = choices[0]['message']?['content'] as String?;
          return content ?? '';
        }
        return '';
      } else {
        throw Exception('Sarvam chat failed: ${resp.statusCode}');
      }
    } catch (e) {
      // log upstream if needed
      print('SarvamService.chatReply error: $e');
      return null;
    }
  }

  /// Calls Sarvam TTS and writes the returned base64 audio to a temp file.
  /// Returns the File path (wav) or null if failed.
  Future<File?> textToSpeechToFile(String text, {required String targetLanguageCode}) async {
    try {
      if (_apiKey.isEmpty) throw Exception('SARVAM_API_KEY missing or not provided at compile time');

      final body = {
        'text': text,
        'target_language_code': targetLanguageCode,
        'speaker': "anushka", // (anushka, vidya, manisha, karun, hitesh, abhilash)
        'pitch': 0.2,        // (Max: 1.3)
        'pace': 0.9,       //(Max: 1)
        'loudness': 1.5,    //(Max: 3)
        'speech_sample_rate': 22050, //(22050kHz)
        'enable_preprocessing': true,
        'model': "bulbul:v2"
        // optionally add speaker/voice parameters here
      };

      final resp = await _dio.post(
        _ttsUrl,
        data: jsonEncode(body),
        options: Options(headers: {
          'api-subscription-key': _apiKey, // Use the compile-time constant
          'Content-Type': 'application/json',
        }),
        // increase timeouts if necessary
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = resp.data;
        final audios = (data['audios'] as List<dynamic>?) ?? [];
        if (audios.isEmpty) throw Exception('No audio returned');

        final base64Audio = audios[0] as String;
        final bytes = base64Decode(base64Audio);

        final dir = await getTemporaryDirectory();
        final filename = 'sarvam_tts_${DateTime.now().millisecondsSinceEpoch}.wav';
        final file = File('${dir.path}/$filename');
        await file.writeAsBytes(bytes);
        return file;
      } else {
        throw Exception('Sarvam TTS failed: ${resp.statusCode}');
      }
    } catch (e) {
      print('SarvamService.textToSpeechToFile error: $e');
      return null;
    }
  }
}
