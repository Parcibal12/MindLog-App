import '../repositories/journal_repository_contract.dart';

class AnalyzeContentUseCase {
  final JournalRepositoryContract _repository;

  AnalyzeContentUseCase(this._repository);

  Future<Map<String, dynamic>> call(String content) {
    return _repository.analyzeContent(content);
  }
}
