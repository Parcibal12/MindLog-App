abstract class AuthRepositoryContract {
  bool get hasPin;

  Future<void> savePin(String pin);

  bool validatePin(String pin);

  bool get isBiometricsEnabled;

  Future<void> setBiometricsEnabled(bool value);

  Future<bool> authenticateWithBiometrics();
}
