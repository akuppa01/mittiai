import 'dart:convert';
//import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
// Import removed as it's not directly used here and was for SchemesService reference which is not needed in DBHelper
// import 'package:mitti_ai/services/schemes_service.dart';

class DBHelper {
  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _db;

  Future<Database> get database async => _db ??= await _initDB('mitti_db.db');

  Future<Database> _initDB(String fileName) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, fileName);
    return await openDatabase(
      path,
      version: 1, // Consider incrementing version if schema changes significantly in the future
      onCreate: _onCreate,
      // onUpgrade: _onUpgrade, // If you ever need to alter the table structure
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE schemes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        url TEXT UNIQUE,
        title TEXT,
        short TEXT,
        detail TEXT,
        state TEXT, -- Added to store the state name
        is_central INTEGER, -- 0 for state, 1 for central
        importance INTEGER,
        documents TEXT, -- Stored as JSON string
        steps TEXT, -- Stored as JSON string
        checklist TEXT, -- Stored as JSON string, if you use it
        last_updated INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE meta (
        k TEXT PRIMARY KEY,
        v TEXT
      )
    ''');
  }

  Future<void> upsertScheme(Map<String, dynamic> scheme) async {
    final db = await database;
    final documents = jsonEncode(scheme['documents'] ?? []);
    final steps = jsonEncode(scheme['steps'] ?? []);
    final checklist = jsonEncode(scheme['checklist'] ?? []); // Assuming you might use this
    final now = scheme['last_updated'] ?? DateTime.now().millisecondsSinceEpoch;

    // Ensure 'is_central' is handled correctly (0 or 1)
    int isCentralFlag = 0; // Default to state scheme
    if (scheme['is_central'] != null) {
      if (scheme['is_central'] is bool) {
        isCentralFlag = scheme['is_central'] ? 1 : 0;
      } else if (scheme['is_central'] is int) {
        isCentralFlag = scheme['is_central'] == 1 ? 1 : 0;
      }
    }

    await db.insert(
      'schemes',
      {
        'url': scheme['url'],
        'title': scheme['title'],
        'short': scheme['short'],
        'detail': scheme['detail'],
        'state': scheme['state'], // Ensure this is being passed in from SchemesService
        'is_central': isCentralFlag,
        'importance': scheme['importance'] ?? 0,
        'documents': documents,
        'steps': steps,
        'checklist': checklist,
        'last_updated': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getSchemesByState(String stateName) async {
    final db = await database;
    // We only care about state-specific schemes here, so is_central should be 0.
    final rows = await db.query('schemes', where: 'state = ? AND is_central = ?', whereArgs: [stateName, 0], orderBy: 'importance DESC, last_updated DESC');
    return rows.map((r) => _rowToMap(r)).toList();
  }

  // This method might be deprecated if we only show state-specific schemes based on user selection
  // Or it could be used if a user explicitly wants to see only central schemes without a state context
  Future<List<Map<String, dynamic>>> getCentralSchemes({int limit = 100}) async {
    final db = await database;
    final rows = await db.query('schemes', where: 'is_central = ?', whereArgs: [1], orderBy: 'importance DESC, last_updated DESC', limit: limit);
    return rows.map((r) => _rowToMap(r)).toList();
  }

  // New method to delete schemes by state
  Future<void> deleteSchemesByState(String stateName) async {
    final db = await database;
    await db.delete('schemes', where: 'state = ? AND is_central = ?', whereArgs: [stateName, 0]);
    print('DBHelper: Deleted schemes for state: $stateName');
  }

  Map<String, dynamic> _rowToMap(Map<String, dynamic> r) {
    // Helper to safely decode JSON strings, returning empty list if null or invalid
    List<dynamic> _safeJsonDecodeList(String? jsonString) {
      if (jsonString == null || jsonString.isEmpty) return [];
      try {
        final decoded = jsonDecode(jsonString);
        return decoded is List ? decoded : [];
      } catch (e) {
        return []; // Return empty list on error
      }
    }
    Map<String,dynamic> _safeJsonDecodeMap(String? jsonString) {
        if (jsonString == null || jsonString.isEmpty) return {};
        try {
            final decoded = jsonDecode(jsonString);
            return decoded is Map<String,dynamic> ? decoded : {};
        } catch (e) {
            return {};
        }
    }


    return {
      'id': r['id'],
      'url': r['url'],
      'title': r['title'],
      'short': r['short'],
      'detail': r['detail'],
      'state': r['state'],
      'is_central': r['is_central'] == 1, // Convert int back to bool for provider
      'importance': r['importance'],
      'documents': _safeJsonDecodeList(r['documents'] as String?),
      'steps': _safeJsonDecodeList(r['steps'] as String?),
      'checklist': _safeJsonDecodeList(r['checklist'] as String?), // Assuming checklist items are strings
      'last_updated': r['last_updated'],
    };
  }

  Future<void> setMeta(String key, String value) async {
    final db = await database;
    await db.insert('meta', {'k': key, 'v': value}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getMeta(String key) async {
    final db = await database;
    final rows = await db.query('meta', where: 'k = ?', whereArgs: [key]);
    if (rows.isEmpty) return null;
    return rows.first['v'] as String?;
  }

  // This clearSchemes might be too broad now. Consider if it's still needed
  // or if state-specific deletion is preferred.
  Future<void> clearAllSchemes() async { // Renamed for clarity
    final db = await database;
    await db.delete('schemes');
    print('DBHelper: Cleared all schemes.');
  }
}
