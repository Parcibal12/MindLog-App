import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/journal_repository.dart';
import '../../data/models/journal_dto.dart';

final journalEntriesProvider = FutureProvider.autoDispose<List<JournalDto>>((ref) async {
  final repository = ref.read(journalRepositoryProvider);
  return await repository.getEntries();
});

final currentStreakProvider = FutureProvider<int>((ref) async {
  final repository = ref.read(journalRepositoryProvider);
  
  const String myUserId = '648bea7c-175d-4caa-8c3b-1ea519b93e46'; 
  
  return await repository.getCurrentStreak(myUserId);
});