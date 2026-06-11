import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/journal_repository.dart';
import '../../data/models/journal_dto.dart';

final journalEntriesProvider = FutureProvider.autoDispose<List<JournalDto>>((ref) async {
  final repository = ref.read(journalRepositoryProvider);
  return await repository.getEntries();
});