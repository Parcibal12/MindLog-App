import 'package:flutter_riverpod/flutter_riverpod.dart';

class PinNotifier extends StateNotifier<String> {
  PinNotifier() : super('');

  void addDigit(String digit) {
    if (state.length < 4) {
      state = state + digit;
      if (state.length == 4) {
        _verifyPin();
      }
    }
  }

  void removeDigit() {
    if (state.isNotEmpty) {
      state = state.substring(0, state.length - 1);
    }
  }

  void _verifyPin() {
  }
}

final pinProvider = StateNotifierProvider<PinNotifier, String>((ref) => PinNotifier());