import '../../data/models/update_profile_dto.dart';
import '../repositories/profile_repository_contract.dart';

class SaveProfileUseCase {
  final ProfileRepositoryContract _repository;

  SaveProfileUseCase(this._repository);

  Future<bool> call({
    required String userId,
    required UpdateProfileDto dto,
  }) async {
    final successUpdate = await _repository.updateProfile(userId, dto);
    if (!successUpdate) return false;

    return await _repository.triggerReport();
  }
}
