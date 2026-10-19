import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Past calculations, newest first, saved on the device.
///
/// Uses `shared_preferences`, which is browser localStorage on web.
class CalculationHistory extends ChangeNotifier {
  CalculationHistory._(this._prefs)
    : _entries = _prefs.getStringList(_key) ?? [];

  static const _key = 'calculation_history';

  static Future<CalculationHistory> load() async =>
      CalculationHistory._(await SharedPreferences.getInstance());

  final SharedPreferences _prefs;
  final List<String> _entries;

  List<String> get entries => List.unmodifiable(_entries);

  void add(String calculation) {
    _entries.insert(0, calculation);
    _save();
  }

  void clear() {
    _entries.clear();
    _save();
  }

  void _save() {
    _prefs.setStringList(_key, _entries);
    notifyListeners();
  }
}
