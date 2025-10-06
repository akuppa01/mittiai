// lib/services/schemes_service.dart
//import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlparser;
import 'package:html/dom.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mitti_ai/services/db_helper.dart';
//import 'package:mitti_ai/services/state_mappings.dart'; // Added import

class SchemesService {
  final DBHelper _db = DBHelper.instance;

  // Placeholder for state to state_id mapping. YOU MUST POPULATE THIS.
  static const Map<String, String> _STATE_ID_MAP = {
    'andhra pradesh': '5',
    'arunachal pradesh': '19',
    'assam': '37',
    'andaman and nicobar islands': '1',
    'bihar': '65',
    'chandigarh': '104',
    'chhattisgarh': '106',
    'chattisgarh': '106',
    'dadra and nagar haveli': '134',
    'delhi': '139',
    'goa': '151',
    'gujarat': '154',
    'haryana': '188',
    'himachal pradesh': '210',
    'jammu and kashmir': '223',
    'jharkhand': '246',
    'karnataka': '271',
    'kerala': '302',
    'ladakh': '712',
    'lakshadweep': '317',
    'madhya pradesh': '319',
    'maharashtra': '371',
    'manipur': '408',
    'meghalaya': '418',
    'mizoram': '430',
    'nagaland': '439',
    'odisha': '451',
    'puducherry': '482',
    'punjab': '487',
    'rajasthan': '510',
    'sikkim': '544',
    'tamil nadu': '549',
    'telangana': '582',
    'tripura': '593',
    'uttar pradesh': '602',
    'uttarakhand': '678',
    'west bengal': '692',
  };

  static const int MAX_PAGES_TO_SCRAPE = 10; // Max pages to fetch per state
  static const String _BASE_GOV_INDIA_URL = "https://services.india.gov.in";

  Future<bool> hasNetwork() async {
    final conn = await Connectivity().checkConnectivity();
    return conn != ConnectivityResult.none;
  }

  Future<void> ensureFreshForState(String? userStateName) async {
    final lastFetchStr = await _db.getMeta('schemes_last_fetch_\${userStateName?.toLowerCase() ?? "central"}') ?? '';
    final lastFetchInt = int.tryParse(lastFetchStr) ?? 0;
    final lastDate = lastFetchInt == 0 ? DateTime.fromMillisecondsSinceEpoch(0) : DateTime.fromMillisecondsSinceEpoch(lastFetchInt);
    final now = DateTime.now();
    final needsFetch = lastFetchInt == 0 || now.difference(lastDate).inDays >= 7;
    
    if (!needsFetch) {
      // print('SchemesService: Data for \${userStateName ?? "central"} is fresh. Skipping fetch.');
      return;
    }
    if (!await hasNetwork()) {
      // print('SchemesService: No network. Skipping fetch.');
      return;
    }
    
    await updateSchemes(userStateName);
    await _db.setMeta('schemes_last_fetch_\${userStateName?.toLowerCase() ?? "central"}', DateTime.now().millisecondsSinceEpoch.toString());
  }

  Future<void> updateSchemes(String? userStateName) async {
    if (!await hasNetwork()) {
      // print('SchemesService: No network. Skipping scheme update.');
      return;
    }

    if (userStateName == null || userStateName.isEmpty) {
      // print('SchemesService: No user state selected. Skipping scheme update for now.');
      return;
    }

    final String normalizedStateName = userStateName.toLowerCase();
    final String? stateId = _STATE_ID_MAP[normalizedStateName];

    if (stateId == null) {
      // print('SchemesService: No state_id mapping found for state: $normalizedStateName. Skipping.');
      return; 
    }

    // print('SchemesService: Starting update for $normalizedStateName (State ID: $stateId) using new logic.');
    await _db.deleteSchemesByState(normalizedStateName);

    final List<Map<String, dynamic>> allFetchedSchemesOnThisRun = [];
    bool schemesFoundOnPreviousPage = true;

    for (int pageNo = 1; pageNo <= MAX_PAGES_TO_SCRAPE && schemesFoundOnPreviousPage; pageNo++) {
      final targetUrl = '$_BASE_GOV_INDIA_URL/service/search?kw=&ln=en&cat_id_search=98&location=district&state_id=$stateId&page_no=$pageNo';
      // print('SchemesService: Fetching page $pageNo for $normalizedStateName from $targetUrl');

      final String? htmlContent = await _fetchPage(targetUrl);
      if (htmlContent == null || htmlContent.isEmpty) {
        // print('SchemesService: Failed to fetch or empty content for page $pageNo of $normalizedStateName.');
        schemesFoundOnPreviousPage = false;
        break;
      }

      final doc = htmlparser.parse(htmlContent);
      
      // 1. Find the single, top-level container for the page's schemes section
      final schemesPageSection = doc.querySelector('#fontSize > div > div.edu-lern-wrap');
      if (schemesPageSection == null) {
        // print('SchemesService: DEBUG: Could not find main schemes page section (#fontSize > div > div.edu-lern-wrap) on page $pageNo.');
        schemesFoundOnPreviousPage = false; // Stop if structure changes
        break;
      }
      // print('SchemesService: DEBUG: Found main schemes page section on page $pageNo.');

      // 2. From schemesPageSection, get its div.inner-content
      final innerContentWrapper = schemesPageSection.querySelector('div.inner-content');
      if (innerContentWrapper == null) {
        // print('SchemesService: DEBUG: Could not find inner content wrapper (div.inner-content) within schemesPageSection on page $pageNo.');
        schemesFoundOnPreviousPage = false; // Stop if structure changes
        break;
      }
      // print('SchemesService: DEBUG: Found inner content wrapper on page $pageNo.');

      // 3. From innerContentWrapper, select ALL div.edu-lern-con elements
      final actualSchemeItems = innerContentWrapper.querySelectorAll('div.edu-lern-con');

      if (actualSchemeItems.isEmpty) {
        // print('SchemesService: No actual scheme items (div.edu-lern-con) found on page $pageNo for $normalizedStateName.');
        schemesFoundOnPreviousPage = false; // No more items on this or subsequent pages
        break;
      }
      
      // print('SchemesService: Found ${actualSchemeItems.length} actual scheme items (div.edu-lern-con) on page $pageNo for $normalizedStateName.');
      int schemesFoundOnThisPage = 0;

      // 4. Loop through each div.edu-lern-con (now called schemeConElement)
      for (var schemeConElement in actualSchemeItems) {
        final h3Element = schemeConElement.querySelector('h3');
        final titleElement = h3Element?.querySelector('a');
        final summaryElement = schemeConElement.querySelector('p');

        final String title = titleElement?.text.trim() ?? '';
        final String? relativeUrl = titleElement?.attributes['href'];
        final String summary = summaryElement?.text.trim() ?? '';

        if (title.isNotEmpty && relativeUrl != null && relativeUrl.isNotEmpty) {
          final String absoluteUrl = relativeUrl.startsWith('http') ? relativeUrl : '$_BASE_GOV_INDIA_URL$relativeUrl';
          
          final scheme = {
            'url': absoluteUrl,
            'title': _cleanText(title),
            'short': _cleanText(summary),
            'summary': _cleanText(summary.length <= 300 ? summary : '${summary.substring(0, 290).trim()}...'),
            'detail': _cleanText(summary),
            'steps': <String>[],
            'documents': <Map<String,String>>[],
            'state': normalizedStateName,
            'is_central': 0,
            'importance': 100 + (allFetchedSchemesOnThisRun.length + 1),
            'last_updated': DateTime.now().millisecondsSinceEpoch,
          };
          allFetchedSchemesOnThisRun.add(scheme);
          schemesFoundOnThisPage++;
          // print('SchemesService: Successfully parsed scheme: $title');
        } else {
          // print('SchemesService: Could not find title/URL or summary for a schemeConElement. Title: "$title", URL: "$relativeUrl", Summary Element Found: ${summaryElement != null}, H3 Element Found: ${h3Element != null}');
        }
      }

      if (schemesFoundOnThisPage == 0 && actualSchemeItems.isNotEmpty) {
        // print('SchemesService: Found schemeConElements but failed to parse any schemes on page $pageNo for $normalizedStateName.');
      }
      if (schemesFoundOnThisPage == 0 && pageNo > 1) { 
          schemesFoundOnPreviousPage = false;
      }

      await Future.delayed(const Duration(seconds: 1));
    }

    if (allFetchedSchemesOnThisRun.isNotEmpty) {
      //// print('SchemesService: Upserting ${allFetchedSchemesOnThisRun.length} schemes for $normalizedStateName.');
      for (var scheme in allFetchedSchemesOnThisRun) {
        await _db.upsertScheme(scheme);
      }
    } else {
      //// print('SchemesService: No schemes found in total for $normalizedStateName after checking all pages.');
    }
    //// print('SchemesService: Finished updating schemes for $normalizedStateName using new logic.');
  }

  Future<String?> _fetchPage(String url) async {
    try {
      final resp = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 12));
      if (resp.statusCode == 200) return resp.body;
      //// print('SchemesService: Failed to fetch page \$url - Status Code: \${resp.statusCode}');
    } catch (e) {
      //// print('SchemesService: Error fetching page \$url - \$e');
    }
    return null;
  }
  
  String _cleanText(String? s) {
    if (s == null) return '';
    var t = s.replaceAll(RegExp(r'\\s+'), ' ').trim(); 
    t = t.replaceAll(RegExp(r'Skip to main content', caseSensitive: false), '');
    t = t.replaceAll(RegExp(r'Language selection', caseSensitive: false), '');
    t = t.replaceAll(RegExp(r'Last Updated:.*', caseSensitive: false), ''); 
    t = t.replaceAll(RegExp(r'Font Size:.*', caseSensitive: false), '');
    return t.trim(); 
  }

  // Old parsing logic - can be removed if new logic is sufficient
  List<Map<String, String>> _parseListing(String html) {
    final doc = htmlparser.parse(html);
    final containerSelectors = ['div.listing-block', '.listing', 'section.listing', 'div#content', 'div.page-body', 'main', 'body'];
    final excludePattern = RegExp(r'cat_id=|/category/|/service/listing|/service\\?cat_id', caseSensitive: false);
    final res = <Map<String, String>>[];
    for (var sel in containerSelectors) {
      final containers = doc.querySelectorAll(sel);
      if (containers.isEmpty) continue;
      for (var c in containers) {
        final anchors = c.querySelectorAll('a');
        for (var a in anchors) {
          final href = (a.attributes['href'] ?? '').trim();
          final text = a.text.trim();
          if (href.isEmpty || text.isEmpty) continue;
          if (excludePattern.hasMatch(href)) continue;
          if (!href.toLowerCase().contains('/service/detail/')) { 
             if(!href.toLowerCase().contains('/service/')) continue;
          }
          if (!_isLikelyServiceAnchor(a)) continue;
          final url = href.startsWith('http') ? href : '$_BASE_GOV_INDIA_URL\$href';
          final short = _findShortDescriptionNearby(a);
          res.add({'url': url, 'title': text.replaceAll(RegExp(r'\\s+'), ' '), 'short': short});
        }
      }
      if (res.isNotEmpty) break; 
    }
    final seen = <String>{};
    final out = <Map<String, String>>[];
    for (var r in res) {
      final u = r['url'] ?? '';
      if (u.isEmpty) continue;
      if (seen.add(u)) out.add(r);
    }
    return out;
  }

  bool _isLikelyServiceAnchor(Element a) {
    final rejectTokens = ['nav', 'menu', 'sidebar', 'left', 'header', 'footer', 'breadcrumb', 'category', 'filter', 'sort'];
    final acceptTokens = ['service', 'listing', 'card', 'result', 'item', 'services', 'service-list', 'scheme-name', 'service-title'];
    Element? cur = a;
    int depth = 0;
    while(cur != null && depth < 6) { 
        final combined = ((cur.id ?? '') + ' ' + (cur.className ?? '') + ' ' + (cur.localName ?? '')).toLowerCase();
        for (var rt in rejectTokens) {
            if (combined.contains(rt)) return false;
        }
        for (var at in acceptTokens) {
            if (combined.contains(at)) return true; 
        }
        cur = cur.parent;
        depth++;
    }
    final text = a.text.trim();
    if (text.length < 6) return false; 
    final href = (a.attributes['href'] ?? '').toLowerCase();
    if (href.contains('listing') || href.contains('cat_id=') || href.contains('/category/')) return false;
    if (href.contains('/service/detail/') || href.contains('/scheme/')) return true;
    return false; 
  }

  String _findShortDescriptionNearby(Element anchorElement) {
    try {
      Element? current = anchorElement.parent;
      for(int i=0; i<3 && current != null; ++i) { 
          var pSibling = current.querySelector('p');
          if (pSibling != null) {
            final t = pSibling.text.trim();
            if (t.isNotEmpty && t.length > 10 && t.length < 300) { 
                if (t.toLowerCase() != anchorElement.text.trim().toLowerCase()) {
                    return t.replaceAll(RegExp(r'\\s+'), ' ');
                }
            }
          }
          if (current.nextElementSibling?.localName == 'p') {
              final t = current.nextElementSibling!.text.trim();
              if (t.isNotEmpty && t.length > 10 && t.length < 300) return t.replaceAll(RegExp(r'\\s+'), ' ');
          }
           if (anchorElement.nextElementSibling?.localName == 'p') {
              final t = anchorElement.nextElementSibling!.text.trim();
              if (t.isNotEmpty && t.length > 10 && t.length < 300) return t.replaceAll(RegExp(r'\\s+'), ' ');
          }
          current = current.parent;
      }
    } catch (_) {}
    return '';
  }

  Map<String, dynamic> _extractDetails(String detailHtml, String fallbackTitle, String fallbackShort) {
    // ... (keep old _extractDetails for now or remove if not needed by any fallback)
    if (detailHtml.isEmpty) return {'detail': fallbackShort, 'steps': <String>[], 'documents': <Map<String,String>>[], 'checklist': <String>[]};
    final doc = htmlparser.parse(detailHtml);
    Element? chosen;
    final commonSelectors = ['article.service-detail', 'div.service-description', 'div.scheme-details', 'div#contentBody', 'div.main-content', 'section.main', 'article', 'div.service-detail', 'div#content', 'div.maincontent', 'section.service', 'div.listing-detail'];
    for (var sel in commonSelectors) {
      final e = doc.querySelector(sel);
      if (e != null) {
        final txt = _cleanText(e.text);
        if (txt.length > 50 && (txt.toLowerCase().contains(fallbackTitle.toLowerCase()) || txt.contains("scheme") || txt.contains("benefit"))) {
             chosen = e; break; 
        }
      }
    }
    if (chosen == null) chosen = doc.body; // Fallback
    final detailText = _cleanText(chosen?.text ?? fallbackShort);
    return { 'detail': detailText, 'steps': <String>[], 'documents': <Map<String,String>>[], 'checklist': <String>[] };
  }
}
