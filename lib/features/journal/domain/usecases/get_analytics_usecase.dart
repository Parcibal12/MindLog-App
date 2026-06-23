import '../entities/analytics.dart';
import '../repositories/journal_repository_contract.dart';

class GetAnalyticsUseCase {
  final JournalRepositoryContract _repository;

  GetAnalyticsUseCase(this._repository);

  Future<Analytics> call() {
    return _repository.getAnalytics();
  }
}
