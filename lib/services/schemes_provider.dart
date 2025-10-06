// lib/services/schemes_provider.dart
import 'package:flutter/material.dart';
import 'package:mitti_ai/services/db_helper.dart';
import 'package:mitti_ai/services/schemes_service.dart';
//import 'package:shared_preferences/shared_preferences.dart';

class SchemesProvider with ChangeNotifier {
  final SchemesService _svc = SchemesService();
  final DBHelper _db = DBHelper.instance;

  List<Map<String, dynamic>> _schemes = [];
  List<Map<String, dynamic>> get schemes => _schemes;

  bool _loading = false;
  bool get loading => _loading;

  bool _updating = false;
  bool get updating => _updating;

  String? _currentProfileState; // To keep track of the state used for loading

  // Method to be called once when the provider is first used for a specific state context
  Future<void> initAndLoad({String? userStateName}) async {
    _currentProfileState = userStateName; // Store the state being loaded
    _setLoading(true);
    // Ensure data is fresh or fetched if stale/missing for the current state
    await _svc.ensureFreshForState(_currentProfileState);
    // Load whatever is in the DB for that state
    await loadFromDb(userStateName: _currentProfileState);
    _setLoading(false);
  }

  // Method to explicitly refresh schemes for the current (or a new) state
  Future<void> refresh({String? userStateName, bool runBlocking = false}) async {
    // If userStateName is provided, it means we are potentially changing context
    if (userStateName != null) {
      _currentProfileState = userStateName;
    }

    if (runBlocking) {
      _setLoading(true); // Use loading for a full blocking refresh
      await _svc.updateSchemes(_currentProfileState); // Force update from network
      await loadFromDb(userStateName: _currentProfileState); // Reload from DB
      _setLoading(false);
    } else {
      _setUpdating(true);
      // Fetch in background, then update UI
      _svc.updateSchemes(_currentProfileState).then((_) async {
        // Important: Load for the state that the update was initiated for
        await loadFromDb(userStateName: _currentProfileState);
      }).whenComplete(() {
        _setUpdating(false);
      });
    }
  }

  // Loads schemes from the local database based on the user's state.
  Future<void> loadFromDb({String? userStateName}) async {
    print('SchemesProvider.loadFromDb: Loading for userStateName: $userStateName');
    if (userStateName != null && userStateName.isNotEmpty) {
      // Only load schemes for the given state.
      _schemes = await _db.getSchemesByState(userStateName);
      print('SchemesProvider.loadFromDb: Loaded ${_schemes.length} schemes for state $userStateName');
    } else {
      // No state selected, or state is empty. Load an empty list.
      // The UI (SchemesScreen) should prompt the user to select a state.
      _schemes = [];
      print('SchemesProvider.loadFromDb: No state selected or state is empty, loaded 0 schemes.');
    }
    notifyListeners();
  }

  void _setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }

  void _setUpdating(bool val) {
    _updating = val;
    notifyListeners();
  }
}
