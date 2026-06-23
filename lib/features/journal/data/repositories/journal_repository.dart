import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/user_constants.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/providers/network_provider.dart';
import '../datasources/remote/journal_api_client.dart';
import '../models/analytics_dto.dart';
import '../models/journal_dto.dart';
import '../models/metadata_dto.dart';

final journalApiClientProvider = Provider<JournalApiClient>((ref) {
  final dio = ref.read(dioProvider);
  return JournalApiClient(dio);
});

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  final apiClient = ref.read(journalApiClientProvider);
  return JournalRepository(apiClient, ref);
});

class JournalRepository {
  final JournalApiClient _apiClient;
  final Ref _ref;
  final Box<String> _offlineBox = Hive.box<String>('offline_journals');
  final Box _cacheBox = Hive.box('privacyVault');

  JournalRepository(this._apiClient, this._ref);

  bool _isOfflineError(DioException e) {
    final isOffline =
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.error is SocketException;
    if (isOffline) {
      _ref.read(isOfflineModeProvider.notifier).state = true;
    }
    return isOffline;
  }

  void _setOnline() {
    _ref.read(isOfflineModeProvider.notifier).state = false;
  }

  Future<void> createEntry({
    required String content,
    required int emotionId,
    required String emotionName,
    required int intensity,
    required List<int> contextTagIds,
    required String aiFeedback,
    required String aiPattern,
  }) async {
    final dto = JournalDto(
      userId: UserConstants.currentUserId,
      content: content,
      emotionId: emotionId,
      emotionName: emotionName,
      intensity: intensity,
      contextTagIds: contextTagIds,
      createdAt: DateTime.now(),
      aiFeedback: aiFeedback,
      aiPattern: aiPattern,
    );

    try {
      await _apiClient.createEntry(dto.toJson());
      _setOnline();
    } on DioException catch (e) {
      if (_isOfflineError(e)) {
        await _offlineBox.add(jsonEncode(dto.toJson()));
        return;
      }
      throw Exception("Error del servidor al enviar el diario.");
    }
  }

  Future<List<JournalDto>> getEntries() async {
    try {
      final remoteEntries = await _apiClient.getEntries();
      _setOnline();
      await _cacheBox.put(
        'cached_entries',
        jsonEncode(remoteEntries.map((e) => e.toJson()).toList()),
      );
      return remoteEntries;
    } on DioException catch (e) {
      if (_isOfflineError(e)) {
        final cached = _cacheBox.get('cached_entries');
        if (cached != null) {
          final List<dynamic> decoded = jsonDecode(cached);
          return decoded
              .map((e) => JournalDto.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      }
      throw Exception("Error al obtener los diarios: $e");
    }
  }

  Future<Map<String, dynamic>> analyzeContent(String content) async {
    try {
      final data = await _apiClient.analyzeEntry({"content": content});
      _setOnline();
      return {
        "feedback": data["feedback"]?.toString() ?? "Reflexión generada.",
        "pattern": data["pattern"]?.toString() ?? "NEUTRAL",
        "emotionId": data["emotionId"] as int? ?? 1,
        "intensity": data["intensity"] as int? ?? 5,
        "contextTagIds": List<int>.from(data["contextTagIds"] ?? []),
      };
    } on DioException catch (e) {
      if (_isOfflineError(e)) {
        return {
          "feedback":
              "Modo sin conexión. Tu diario se guardará en tu bóveda de privacidad.",
          "pattern": "OFFLINE",
          "emotionId": 1,
          "intensity": 5,
          "contextTagIds": <int>[],
        };
      }
      throw Exception("Error del servidor en la IA.");
    }
  }

  Future<AnalyticsDto> getAnalytics() async {
    try {
      final remoteAnalytics = await _apiClient.getAnalytics();
      _setOnline();
      await _cacheBox.put(
        'cached_analytics',
        jsonEncode(remoteAnalytics.toJson()),
      );
      return remoteAnalytics;
    } on DioException catch (e) {
      if (_isOfflineError(e)) {
        final cached = _cacheBox.get('cached_analytics');
        if (cached != null) {
          final Map<String, dynamic> decoded = jsonDecode(cached);
          return AnalyticsDto.fromJson(decoded);
        }
        throw const SocketException(
          "Sin conexión a internet y sin datos locales previos.",
        );
      }
      throw Exception("Error al obtener analíticas: $e");
    }
  }

  Future<List<EmotionDto>> getEmotions() async {
    try {
      final remoteEmotions = await _apiClient.getEmotions();
      _setOnline();
      await _cacheBox.put(
        'cached_emotions',
        jsonEncode(remoteEmotions.map((e) => e.toJson()).toList()),
      );
      return remoteEmotions;
    } on DioException catch (e) {
      if (_isOfflineError(e)) {
        final cached = _cacheBox.get('cached_emotions');
        if (cached != null) {
          final List<dynamic> decoded = jsonDecode(cached);
          return decoded
              .map((e) => EmotionDto.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      }
      throw Exception("Error al obtener emociones: $e");
    }
  }

  Future<List<ContextTagDto>> getContextTags() async {
    try {
      final remoteTags = await _apiClient.getContextTags();
      _setOnline();
      await _cacheBox.put(
        'cached_contexts',
        jsonEncode(remoteTags.map((e) => e.toJson()).toList()),
      );
      return remoteTags;
    } on DioException catch (e) {
      if (_isOfflineError(e)) {
        final cached = _cacheBox.get('cached_contexts');
        if (cached != null) {
          final List<dynamic> decoded = jsonDecode(cached);
          return decoded
              .map((e) => ContextTagDto.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      }
      throw Exception("Error al obtener contextos: $e");
    }
  }

  Future<int> getCurrentStreak(String userId) async {
    try {
      final response = await _apiClient.getCurrentStreak(userId);
      _setOnline();
      return response.currentStreak;
    } catch (e) {
      return 0;
    }
  }

  Future<int> syncOfflineEntries() async {
    if (_offlineBox.isEmpty) return 0;
    int syncedCount = 0;
    final keys = _offlineBox.keys.toList();
    for (var key in keys) {
      try {
        final String data = _offlineBox.get(key)!;
        final Map<String, dynamic> json = jsonDecode(data);
        await _apiClient.createEntry(json);
        await _offlineBox.delete(key);
        syncedCount++;
      } catch (e) {
        continue;
      }
    }
    return syncedCount;
  }
}
