import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';
import '../datasources/remote/profile_api_client.dart';
import '../models/update_profile_dto.dart';

final profileApiClientProvider = Provider<ProfileApiClient>((ref) {
  final dio = ref.read(dioProvider);
  return ProfileApiClient(dio);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final apiClient = ref.read(profileApiClientProvider);
  return ProfileRepository(apiClient);
});

class ProfileRepository {
  final ProfileApiClient _apiClient;

  ProfileRepository(this._apiClient);

  Future<bool> updateProfile(String userId, UpdateProfileDto dto) async {
    try {
      final response = await _apiClient.updateProfile(userId, dto);
      return response.response.statusCode == 200 ||
          response.response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  Future<bool> triggerReport() async {
    try {
      final response = await _apiClient.triggerReport();
      return response.response.statusCode == 200 ||
          response.response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}
