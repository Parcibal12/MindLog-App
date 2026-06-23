import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/journal_repository.dart';
import 'home_controller.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(ref);
});

class SyncService {
  final Ref _ref;

  SyncService(this._ref);

  Future<void> runSilentSync() async {
    final repository = _ref.read(journalRepositoryProvider);
    
    try {
      final syncedCount = await repository.syncOfflineEntries();
      
      if (syncedCount > 0) {
        _ref.invalidate(journalEntriesProvider);
        _ref.invalidate(currentStreakProvider);
      }
    } catch (e) {
      // Ignorar error de sincronización silenciosa
    }
  }
}