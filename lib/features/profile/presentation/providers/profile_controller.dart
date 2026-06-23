import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/user_constants.dart';
import '../../data/models/update_profile_dto.dart';
import '../../data/repositories/profile_repository.dart';

final profileControllerProvider =
    StateNotifierProvider<ProfileController, AsyncValue<void>>((ref) {
      return ProfileController(ref.read(profileRepositoryProvider));
    });

class ProfileController extends StateNotifier<AsyncValue<void>> {
  final ProfileRepository _repository;

  ProfileController(this._repository) : super(const AsyncData(null));

  Future<bool> saveProfileAndGenerateReport(String email, bool autoSend) async {
    state = const AsyncLoading();

    final dto = UpdateProfileDto(
      therapistName: "Dr. Asignado",
      therapistEmail: email.trim(),
      autoSendReports: autoSend,
    );

    final successUpdate = await _repository.updateProfile(
      UserConstants.currentUserId,
      dto,
    );

    if (!successUpdate) {
      state = AsyncError("Error al guardar perfil", StackTrace.current);
      return false;
    }

    final successReport = await _repository.triggerReport();

    if (successReport) {
      state = const AsyncData(null);
      return true;
    } else {
      state = AsyncError(
        "Perfil guardado, pero falló el envío",
        StackTrace.current,
      );
      return false;
    }
  }
}
