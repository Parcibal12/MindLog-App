import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme_repository.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final repository = ref.read(themeRepositoryProvider);
  return ThemeNotifier(repository);
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final ThemeRepository _repository;

  ThemeNotifier(this._repository) 
      : super(_repository.isDarkMode() ? ThemeMode.dark : ThemeMode.light);

  void toggleTheme() {
    final isCurrentlyDark = state == ThemeMode.dark;
    final newState = isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;
    
    state = newState;
    _repository.setDarkMode(!isCurrentlyDark);
  }
}