import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/remote/journal_api_client.dart';
import '../models/journal_dto.dart';
import '../models/analytics_dto.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

final journalApiClientProvider = Provider<JournalApiClient>((ref) {
  final dio = ref.read(dioProvider);
  return JournalApiClient(dio);
});

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  final apiClient = ref.read(journalApiClientProvider);
  return JournalRepository(apiClient);
});

class JournalRepository {
  final JournalApiClient _apiClient;

  JournalRepository(this._apiClient);

  Future<void> createEntry({
    required String content,
    required int emotionId,
    required String emotionName,
    required int intensity,
    required List<int> contextTagIds,
    required String aiFeedback,
    required String aiPattern
  }) async {
    try {
      final dto = JournalDto(
        userId: "648bea7c-175d-4caa-8c3b-1ea519b93e46",
        content: content,
        emotionId: emotionId,
        emotionName: emotionName,
        intensity: intensity,
        contextTagIds: contextTagIds,
        createdAt: DateTime.now(),
        aiFeedback: aiFeedback,
        aiPattern: aiPattern,
      );
      
      await _apiClient.createEntry(dto.toJson());
    } catch (e) {
      throw Exception("Error al enviar el diario: $e");
    }
  }

  Future<List<JournalDto>> getEntries() async {
    try {
      return await _apiClient.getEntries();
    } catch (e) {
      throw Exception("Error al obtener los diarios: $e");
    }
  }

  Future<Map<String, String>> analyzeContent(String content) async {
    try {
      final data = await _apiClient.analyzeEntry({"content": content});
      return {
        "feedback": data["feedback"]?.toString() ?? "Reflexión generada.",
        "pattern": data["pattern"]?.toString() ?? "NEUTRAL"
      };
    } catch (e) {
      throw Exception("Error en IA: $e");
    }
  }

  Future<AnalyticsDto> getAnalytics() async {
    try {
      return await _apiClient.getAnalytics();
    } catch (e) {
      throw Exception("Error al obtener analíticas: $e");
    }
  }
}