import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/journal_repository.dart';
import '../../data/models/analytics_dto.dart';

final analyticsProvider = FutureProvider<AnalyticsDto>((ref) async {
  final repository = ref.read(journalRepositoryProvider);
  return await repository.getAnalytics();
});