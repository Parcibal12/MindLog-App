import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/journal_repository.dart';
import 'home_controller.dart';

final editorControllerProvider = StateNotifierProvider<EditorController, AsyncValue<void>>((ref) {
  final repository = ref.read(journalRepositoryProvider);
  return EditorController(repository, ref);
});

class EditorController extends StateNotifier<AsyncValue<void>> {
  final JournalRepository _repository;
  final Ref _ref;
  EditorController(this._repository, this._ref) : super(const AsyncData(null));

  Future<bool> saveEntry({
    required String content,
    required int emotionId,
    required String emotionName,
    required int intensity,
    required List<int> contextTagIds,
    required String aiFeedback,
    required String aiPattern,
  }) async {
    state = const AsyncLoading(); 
    try {
      await _repository.createEntry(
        content: content,
        emotionId: emotionId,
        emotionName: emotionName,
        intensity: intensity,
        contextTagIds: contextTagIds,
        aiFeedback: aiFeedback,
        aiPattern: aiPattern,
      );
      
      _ref.invalidate(currentStreakProvider);
      _ref.invalidate(journalEntriesProvider);

      state = const AsyncData(null); 
      return true; 
    } catch (e, st) {
      state = AsyncError(e, st); 
      return false;
    }
  }

  Future<Map<String, dynamic>?> analyze(String content) async {
    state = const AsyncLoading();
    try {
      final result = await _repository.analyzeContent(content);
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}