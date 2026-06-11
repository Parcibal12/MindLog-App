import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/remote/journal_api_client.dart';
import '../models/journal_dto.dart';

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
}