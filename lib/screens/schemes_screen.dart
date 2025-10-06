// lib/screens/schemes_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:mitti_ai/services/schemes_service.dart'; // optional
//import 'package:mitti_ai/services/db_helper.dart';
import 'package:mitti_ai/services/schemes_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mitti_ai/generated/l10n/app_localizations.dart';
import 'package:mitti_ai/theme.dart'; // Added for primaryGreen

class SchemesScreen extends StatefulWidget {
  final bool isRootScreenForTab;
  final VoidCallback? onGoToVoiceAssistantTab;
  final VoidCallback? onGoToProfileTab; // Added this line

  const SchemesScreen({
    super.key, 
    required this.isRootScreenForTab, 
    this.onGoToVoiceAssistantTab,
    this.onGoToProfileTab // Added this line
  });

  @override
  State<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends State<SchemesScreen> {
  String? _userStateName;

  @override
  void initState() {
    super.initState();
    _loadAndInitProvider();
  }

  Future<void> _loadAndInitProvider() async {
    final prefs = await SharedPreferences.getInstance();
    final stateName = prefs.getString('user_state_name') ?? prefs.getString('state_code') ?? '';
    // Ensure _userStateName is set to null if stateName is empty, otherwise use stateName.
    _userStateName = stateName.isNotEmpty ? stateName.toLowerCase() : null; // Modified this line

    // Check if context is still valid before using it.
    if (!mounted) return;
    final prov = Provider.of<SchemesProvider>(context, listen: false);
    // Pass the potentially null _userStateName to the provider.
    await prov.initAndLoad(userStateName: _userStateName);
  }

  Future<void> _onManualRefresh() async {
    // Check if context is still valid before using it.
    if (!mounted) return;
    final prov = Provider.of<SchemesProvider>(context, listen: false);
    await prov.refresh(userStateName: _userStateName);
  }

  Widget _tile(Map<String, dynamic> s, AppLocalizations l) {
    final documents = (s['documents'] as List<dynamic>? ?? []).cast<Map<String,dynamic>>();
    final steps = (s['steps'] as List<dynamic>? ?? []).cast<String>();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(s['title'] ?? ''),
        subtitle: Text(s['summary'] ?? s['short'] ?? ''),
        onTap: () {
          showDialog(context: context, builder: (_) {
            final detail = (s['detail'] ?? '').toString().trim();
            final hasMeaningfulDetail = detail.length > 80;
            return AlertDialog(
              title: Text(s['title'] ?? ''),
              content: SingleChildScrollView(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (hasMeaningfulDetail) Text(detail) else Text(l.schemeDialogOpenWebsite),
                  const SizedBox(height: 12),
                  if (steps.isNotEmpty) ...[
                    Text(l.schemeDialogStepsLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    for (var st in steps) Text('• $st'),
                    const SizedBox(height: 8),
                  ],
                  if (documents.isNotEmpty) ...[
                    Text(l.schemeDialogDocumentsLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    for (var d in documents) GestureDetector(
                      onTap: () async {
                        final url = d['url'] ?? '';
                        if (url.isNotEmpty && await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                        }
                      },
                      child: Text(d['title'] ?? d['url'], style: const TextStyle(color: Colors.blue)),
                    )
                  ],
                  const SizedBox(height: 12),
                  TextButton.icon(
                    icon: const Icon(Icons.link, size: 20),
                    label: Text(
                      l.schemeDialogViewSourceButton,
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      foregroundColor: Colors.blue, // Matching the original link color
                    ),
                    onPressed: () async { // Changed onTap to onPressed
                      final url = s['url'] ?? ''; // s is the scheme map from _tile method
                      if (url.isNotEmpty && await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                ]),
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Increased padding
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l.schemeDialogCloseButton,
                    style: const TextStyle(fontSize: 16), // Increased font size
                  ),
                )
              ],

            );
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final prov = Provider.of<SchemesProvider>(context);
    final isUpdating = prov.updating;
    final schemes = prov.schemes;
    final isLoading = prov.loading; // Use isLoading from provider

    return Scaffold(
      appBar: AppBar(
        leading: (widget.isRootScreenForTab && widget.onGoToVoiceAssistantTab != null)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: widget.onGoToVoiceAssistantTab,
              )
            : null, // Keeps default back button if not root or no callback
        backgroundColor: primaryGreen,
        toolbarHeight: 80.0,
        centerTitle: true,
        elevation: 1.0,
        iconTheme: const IconThemeData(color: Colors.white), 
        title: Text(l.schemesScreenTitle, style: const TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold)),
        actions: [IconButton(onPressed: _onManualRefresh, icon: const Icon(Icons.refresh, color: Colors.white))],
      ),
      body: isLoading // Check isLoading first
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
        if (isUpdating)
          Container(
            width: double.infinity,
            color: Colors.blue.shade50,
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              const SizedBox(width: 6),
              const CircularProgressIndicator(strokeWidth: 2),
              const SizedBox(width: 12),
              Expanded(child: Text(l.schemesScreenUpdatingSchemes)),
            ]),
          ),
        Expanded(
          child: schemes.isEmpty && _userStateName != null // Check if schemes are empty AND a state is selected
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      l.schemesScreenNoSchemesForState(_userStateName ?? 'your state'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                )
              : RefreshIndicator( // Keep RefreshIndicator for non-empty list or when no state is selected (initial load)
                  onRefresh: () async {
                    await prov.refresh(userStateName: _userStateName);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    // If schemes are empty and _userStateName is null, this will build an empty list,
                    // which is fine because the banner at the bottom will cover the "no state selected" case.
                    itemCount: schemes.length,
                    itemBuilder: (_, i) => _tile(schemes[i], l),
                  ),
                ),
        ),
        if (_userStateName == null && !isLoading && !isUpdating) // Show banner only if not loading/updating and no state
          Container(
            color: Colors.yellow[100],
            padding: const EdgeInsets.all(8),
            child: Row(children: [
              const Icon(Icons.info_outline),
              const SizedBox(width: 8),
              Expanded(child: Text(l.schemesScreenLoginPrompt)),
              TextButton(
                onPressed: () { 
                  if (widget.onGoToProfileTab != null) {
                    widget.onGoToProfileTab!();
                  } else if (widget.isRootScreenForTab && widget.onGoToVoiceAssistantTab != null) {
                    widget.onGoToVoiceAssistantTab!();
                  }
                }, 
                child: Text(l.schemesScreenLoginButton)
              ),
            ]),
          )
      ]),
    );
  }
}
