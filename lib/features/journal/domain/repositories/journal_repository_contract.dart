import '../entities/analytics.dart';
import '../entities/context_tag.dart';
import '../entities/emotion.dart';
import '../entities/journal_entry.dart';

abstract class JournalRepositoryContract {
  Future<void> createEntry({
    required String content,
    required int emotionId,
    required String emotionName,
    required int intensity,
    required List<int> contextTagIds,
    required String aiFeedback,
    required String aiPattern,
  });

  Future<List<JournalEntry>> getEntries();

  Future<Map<String, dynamic>> analyzeContent(String content);

  Future<Analytics> getAnalytics();

  Future<List<Emotion>> getEmotions();

  Future<List<ContextTag>> getContextTags();

  Future<int> getCurrentStreak(String userId);

  Future<int> syncOfflineEntries();
}
