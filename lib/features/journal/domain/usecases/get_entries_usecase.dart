import '../entities/journal_entry.dart';
import '../repositories/journal_repository_contract.dart';

class GetEntriesUseCase {
  final JournalRepositoryContract _repository;

  GetEntriesUseCase(this._repository);

  Future<List<JournalEntry>> call() {
    return _repository.getEntries();
  }
}
