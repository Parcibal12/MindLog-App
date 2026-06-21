import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/profile_api_client.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/models/update_profile_dto.dart';

final dioProvider = Provider((ref) => Dio());

final profileApiClientProvider = Provider((ref) {
  return ProfileApiClient(ref.read(dioProvider));
});

final profileRepositoryProvider = Provider((ref) {
  return ProfileRepository(ref.read(profileApiClientProvider));
});

final profileControllerProvider = StateNotifierProvider<ProfileController, AsyncValue<void>>((ref) {
  return ProfileController(ref.read(profileRepositoryProvider));
});

class ProfileController extends StateNotifier<AsyncValue<void>> {
  final ProfileRepository _repository;

  ProfileController(this._repository) : super(const AsyncData(null));

  Future<bool> saveProfileAndGenerateReport(String email, bool autoSend) async {
    state = const AsyncLoading();

    const String myUserId = "648bea7c-175d-4caa-8c3b-1ea519b93e46"; 

    final dto = UpdateProfileDto(
      therapistName: "Dr. Asignado",
      therapistEmail: email.trim(),
      autoSendReports: autoSend,
    );

    final successUpdate = await _repository.updateProfile(myUserId, dto);
    
    if (!successUpdate) {
      state = AsyncError("Error al guardar perfil", StackTrace.current);
      return false;
    }

    final successReport = await _repository.triggerReport();

    if (successReport) {
      state = const AsyncData(null);
      return true;
    } else {
      state = AsyncError("Perfil guardado, pero falló el envío", StackTrace.current);
      return false;
    }
  }
}