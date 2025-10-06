// lib/screens/info_library_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mitti_ai/services/locale_provider.dart';
import '../../data/farming_info.dart';
import 'package:mitti_ai/generated/l10n/app_localizations.dart'; // Localization
import 'package:mitti_ai/theme.dart'; // Added for primaryGreen

class InfoLibraryScreen extends StatefulWidget {
  final bool isRootScreenForTab;
  final VoidCallback? onGoToVoiceAssistantTab;

  const InfoLibraryScreen({super.key, required this.isRootScreenForTab, this.onGoToVoiceAssistantTab});

  @override
  State<InfoLibraryScreen> createState() => _InfoLibraryScreenState();
}

class _InfoLibraryScreenState extends State<InfoLibraryScreen> {
  String _search = '';

  // pick language code from LocaleProvider (expects 'en','hi','te')
  String _langCodeFromProvider(BuildContext context) {
    final lp = Provider.of<LocaleProvider>(context);
    final code = lp.locale.languageCode.toLowerCase();
    if (code.startsWith('te')) return 'te';
    if (code.startsWith('hi')) return 'hi';
    return 'en';
  }

  List<Map<String, String>> _filteredItemsForCategory(String category, String lang) {
    final items = farmingInfo[category] ?? [];
    if (_search.trim().isEmpty) return items;
    final q = _search.toLowerCase();
    return items.where((item) {
      final t = (item['title_$lang'] ?? item['title_en'] ?? '').toLowerCase();
      final d = (item['description_$lang'] ?? item['description_en'] ?? '').toLowerCase();
      return t.contains(q) || d.contains(q);
    }).toList();
  }

  // Helper method to get localized category names
  String _getLocalizedCategoryName(String categoryKey, AppLocalizations l10n) {
    switch (categoryKey) {
      case 'Seeds':
        return l10n.categorySeeds;
      case 'Fertilizers':
        return l10n.categoryFertilizers;
      case 'Pests & Diseases':
        return l10n.categoryPestsAndDiseases;
      // Add other cases if you have more categories in farmingInfo
      default:
        return categoryKey; // Fallback to the key itself if no translation is found
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = _langCodeFromProvider(context);
    final l10n = AppLocalizations.of(context)!; // Get AppLocalizations instance
    final categories = farmingInfo.keys.toList();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80.0, // Matched AppBar height
        backgroundColor: primaryGreen, // Applied theme color
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Set icon color to white
          onPressed: () {
            if (widget.isRootScreenForTab && widget.onGoToVoiceAssistantTab != null) {
              widget.onGoToVoiceAssistantTab!();
            } else if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(l10n.infoLibraryTitle, style: const TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold)), // Set title color to white and bold
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Search
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l10n.searchHint, // Use localized search hint
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                isDense: true,
              ),
              onChanged: (v) {
                setState(() => _search = v);
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: categories.map((categoryKey) { // categoryKey is e.g. "Seeds"
                  final filtered = _filteredItemsForCategory(categoryKey, lang);
                  if (filtered.isEmpty) {
                    // skip category if nothing matches search
                    if (_search.trim().isNotEmpty) return const SizedBox.shrink();
                  }
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ExpansionTile(
                      // Use localized category name
                      title: Text(_getLocalizedCategoryName(categoryKey, l10n), style: const TextStyle(fontWeight: FontWeight.bold)), // Changed to bold
                      children: filtered.map((item) {
                        final title = item['title_$lang'] ?? item['title_en'] ?? '';
                        final desc = item['description_$lang'] ?? item['description_en'] ?? '';
                        return ListTile(
                          title: Text(title),
                          subtitle: Text(desc),
                          onTap: () {
                            // show details dialog (simple)
                            showDialog(context: context, builder: (_) {
                              return AlertDialog(
                                title: Text(title),
                                content: SingleChildScrollView(child: Text(desc)),
                                actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))], // Consider localizing 'Close' too
                              );
                            });
                          },
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
