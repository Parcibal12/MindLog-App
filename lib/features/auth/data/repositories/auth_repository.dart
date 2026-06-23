import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';

import '../../domain/repositories/auth_repository_contract.dart';

final authRepositoryProvider = Provider<AuthRepositoryContract>((ref) {
  return AuthRepository();
});

class AuthRepository implements AuthRepositoryContract {
  final Box _vaultBox = Hive.box('privacyVault');
  final LocalAuthentication _auth = LocalAuthentication();

  @override
  bool get hasPin => _vaultBox.containsKey('user_pin');

  @override
  Future<void> savePin(String pin) async {
    await _vaultBox.put('user_pin', pin);
  }

  @override
  bool validatePin(String pin) {
    final storedPin = _vaultBox.get('user_pin');
    return storedPin == pin;
  }

  @override
  bool get isBiometricsEnabled =>
      _vaultBox.get('use_biometrics', defaultValue: true);

  @override
  Future<void> setBiometricsEnabled(bool value) async {
    await _vaultBox.put('use_biometrics', value);
  }

  @override
  Future<bool> authenticateWithBiometrics() async {
    if (kIsWeb || !isBiometricsEnabled) return false;

    try {
      final canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final canAuthenticate =
          canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

      if (!canAuthenticate) return false;

      return await _auth.authenticate(
        localizedReason: 'Usa tu huella o rostro para desbloquear MindLog',
      );
    } catch (e) {
      return false;
    }
  }
}
