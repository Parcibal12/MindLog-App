import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/journal_repository.dart'; 
import '../../data/models/metadata_dto.dart';

final journalContentDraftProvider = StateProvider<String>((ref) => '');

final aiFeedbackProvider = StateProvider<String>((ref) => '');
final aiPatternProvider = StateProvider<String>((ref) => '');
final draftEmotionIdProvider = StateProvider<int?>((ref) => null);
final draftIntensityProvider = StateProvider<int>((ref) => 5);
final draftContextTagsProvider = StateProvider<List<int>>((ref) => []);

final emotionsProvider = FutureProvider<List<EmotionDto>>((ref) async {
  final repository = ref.read(journalRepositoryProvider);
  return await repository.getEmotions();
});

final contextTagsProvider = FutureProvider<List<ContextTagDto>>((ref) async {
  final repository = ref.read(journalRepositoryProvider);
  return await repository.getContextTags();
});