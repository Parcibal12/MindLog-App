import '../repositories/journal_repository_contract.dart';

class CreateEntryUseCase {
  final JournalRepositoryContract _repository;

  CreateEntryUseCase(this._repository);

  Future<void> call({
    required String content,
    required int emotionId,
    required String emotionName,
    required int intensity,
    required List<int> contextTagIds,
    required String aiFeedback,
    required String aiPattern,
  }) {
    return _repository.createEntry(
      content: content,
      emotionId: emotionId,
      emotionName: emotionName,
      intensity: intensity,
      contextTagIds: contextTagIds,
      aiFeedback: aiFeedback,
      aiPattern: aiPattern,
    );
  }
}
