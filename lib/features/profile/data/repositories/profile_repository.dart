import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/remote/profile_api_client.dart';
import '../models/update_profile_dto.dart';

String _getProfileBaseUrl() {
  const port = "5135";
  if (kIsWeb) return 'http://localhost:$port/api/';
  if (Platform.isAndroid) return 'http://10.0.2.2:$port/api/';
  return 'http://localhost:$port/api/';
}

final profileApiClientProvider = Provider<ProfileApiClient>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: _getProfileBaseUrl(),
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));
  return ProfileApiClient(dio);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final apiClient = ref.read(profileApiClientProvider);
  return ProfileRepository(apiClient);
});

// 3. REPOSITORIO
class ProfileRepository {
  final ProfileApiClient _apiClient;

  ProfileRepository(this._apiClient);

  Future<bool> updateProfile(String userId, UpdateProfileDto dto) async {
    try {
      final response = await _apiClient.updateProfile(userId, dto);
      return response.response.statusCode == 200 || response.response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  Future<bool> triggerReport() async {
    try {
      final response = await _apiClient.triggerReport();
      return response.response.statusCode == 200 || response.response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}