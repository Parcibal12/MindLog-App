import '../../data/models/update_profile_dto.dart';

abstract class ProfileRepositoryContract {
  Future<bool> updateProfile(String userId, UpdateProfileDto dto);

  Future<bool> triggerReport();
}
