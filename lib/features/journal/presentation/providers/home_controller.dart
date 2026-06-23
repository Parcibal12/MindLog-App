import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/user_constants.dart';
import '../../data/models/journal_dto.dart';
import '../../data/repositories/journal_repository.dart';

final journalEntriesProvider = FutureProvider.autoDispose<List<JournalDto>>((
  ref,
) async {
  final repository = ref.read(journalRepositoryProvider);
  return await repository.getEntries();
});

final currentStreakProvider = FutureProvider<int>((ref) async {
  final repository = ref.read(journalRepositoryProvider);
  try {
    return await repository.getCurrentStreak(UserConstants.currentUserId);
  } catch (_) {
    return 0;
  }
});

final searchQueryProvider = StateProvider<String>((ref) => '');
