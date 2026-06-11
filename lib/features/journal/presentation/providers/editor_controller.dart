import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/journal_repository.dart';

final editorControllerProvider = StateNotifierProvider<EditorController, AsyncValue<void>>((ref) {
  final repository = ref.read(journalRepositoryProvider);
  return EditorController(repository);
});

class EditorController extends StateNotifier<AsyncValue<void>> {
  final JournalRepository _repository;

  EditorController(this._repository) : super(const AsyncData(null));

  Future<bool> saveEntry({
    required String content,
    required int emotionId,
    required String emotionName,
    required int intensity,
    required List<int> contextTagIds,
  }) async {
    state = const AsyncLoading(); 
    try {
      await _repository.createEntry(
        content: content,
        emotionId: emotionId,
        emotionName: emotionName,
        intensity: intensity,
        contextTagIds: contextTagIds,
      );
      state = const AsyncData(null); 
      return true; 
    } catch (e, st) {
      state = AsyncError(e, st); 
      return false;
    }
  }
}