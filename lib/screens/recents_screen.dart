// lib/screens/recents_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mitti_ai/theme.dart'; // Added import for theme
import 'package:mitti_ai/generated/l10n/app_localizations.dart'; // Import AppLocalizations

class RecentsScreen extends StatefulWidget {
  const RecentsScreen({super.key});

  @override
  State<RecentsScreen> createState() => _RecentsScreenState();
}

class _RecentsScreenState extends State<RecentsScreen> {
  final String _historyKey = 'voice_chat_history';
  List<Map<String, String>> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey) ?? '[]';
    final List<dynamic> list = jsonDecode(raw);
    setState(() {
      _items = [];
      for (var it in list) {
        if (it is Map && it['role'] != null && it['text'] != null) {
          _items.add({'role': it['role'], 'text': it['text']});
        }
      }
    });
  }

  Future<void> _clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    setState(() => _items.clear());
  }

  @override
  Widget build(BuildContext context) {
    // Get AppLocalizations instance
    final AppLocalizations l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        // Use translated title
        title: Text(
          l.historyScreenTitle, // Changed from 'Recents'
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
        backgroundColor: primaryGreen, // Changed AppBar background color
        foregroundColor: Colors.white, // Changed AppBar icon/text color
        toolbarHeight: 80.0, // Changed AppBar height
        centerTitle: true, // Ensured AppBar title is centered
        elevation: 1.0, // Changed AppBar elevation
        // automaticallyImplyLeading: true, // Kept for back navigation
        actions: [
          IconButton(icon: const Icon(Icons.delete_outline), onPressed: () async {
            final ok = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                // Potentially translate these as well if needed
                title: Text(l.clearHistoryDialogTitle), // Example: "Clear history?"
                content: Text(l.clearHistoryDialogContent), // Example: "Delete all saved recent chats?"
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancelButtonLabel)), // Example: "Cancel"
                  TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l.clearButtonLabel)), // Example: "Clear"
                ],
              ),
            );
            if (ok == true) await _clear();
          }),
        ],
      ),
      body: _items.isEmpty
          // Potentially translate this as well
          ? Center(child: Text(l.noRecentChats)) // Example: "No recent chats"
          : ListView.separated(
        itemCount: _items.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final row = _items[index];
          final role = row['role'] ?? 'assistant';
          final text = row['text'] ?? '';
          final ThemeData theme = Theme.of(context); // Get the current theme
          return ListTile(
            tileColor: role == 'user' ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceVariant, // Conditional background color
            leading: Icon(
              role == 'user' ? Icons.person : Icons.smart_toy,
              // Icon color will now be default, which should contrast with tileColor
            ),
            title: Text(
              text,
              // Text style will now be default, which should contrast with tileColor
            ),
            subtitle: Text(role),
          );
        },
      ),
    );
  }
}
