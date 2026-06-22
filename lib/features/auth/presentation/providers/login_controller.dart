import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';

enum AuthState {
  checking,
  creatingPin,
  confirmingPin,
  enteringPin,
  authenticated,
  error
}

final loginControllerProvider = StateNotifierProvider<LoginController, AuthState>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return LoginController(repository);
});

class LoginController extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  String _temporalPin = '';

  LoginController(this._repository) : super(AuthState.checking) {
    _init();
  }

  Future<void> _init() async {
    if (_repository.hasPin) {
      state = AuthState.enteringPin;
      await triggerBiometrics();
    } else {
      state = AuthState.creatingPin;
    }
  }

  Future<void> triggerBiometrics() async {
    if (state != AuthState.enteringPin) return;
    
    final success = await _repository.authenticateWithBiometrics();
    if (success) {
      state = AuthState.authenticated;
    }
  }

  void processPin(String pinEntered) {
    switch (state) {
      case AuthState.creatingPin:
        _temporalPin = pinEntered;
        state = AuthState.confirmingPin;
        break;

      case AuthState.confirmingPin:
        if (pinEntered == _temporalPin) {
          _repository.savePin(pinEntered);
          state = AuthState.authenticated;
        } else {
          _temporalPin = '';
          state = AuthState.error; 
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) state = AuthState.creatingPin;
          });
        }
        break;

      case AuthState.enteringPin:
      case AuthState.error:
        if (_repository.validatePin(pinEntered)) {
          state = AuthState.authenticated;
        } else {
          state = AuthState.error;
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) state = AuthState.enteringPin;
          });
        }
        break;
      default:
        break;
    }
  }
}