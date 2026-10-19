import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the user's theme choice and persists it across launches.
///
/// Until the user picks a theme, [themeMode] is [ThemeMode.system] so the app
/// follows the device setting.
class ThemeController extends ChangeNotifier {
  ThemeController._(this._prefs, this._themeMode);

  static const _prefsKey = 'theme_mode';

  final SharedPreferences _prefs;
  ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  static Future<ThemeController> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    final mode = ThemeMode.values.firstWhere(
      (mode) => mode.name == saved,
      orElse: () => ThemeMode.system,
    );
    return ThemeController._(prefs, mode);
  }

  /// Switches to the opposite of the [current] brightness being shown.
  Future<void> toggle(Brightness current) => setThemeMode(
    current == Brightness.dark ? ThemeMode.light : ThemeMode.dark,
  );

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    await _prefs.setString(_prefsKey, mode.name);
  }
}
