import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final themeRepositoryProvider = Provider<ThemeRepository>((ref) {
  return ThemeRepository();
});

class ThemeRepository {
  final Box _box = Hive.box('privacyVault');

  bool isDarkMode() {
    return _box.get('isDarkMode', defaultValue: false);
  }

  Future<void> setDarkMode(bool isDark) async {
    await _box.put('isDarkMode', isDark);
  }
}