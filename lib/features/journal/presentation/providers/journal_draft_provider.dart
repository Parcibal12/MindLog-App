import 'package:flutter_riverpod/flutter_riverpod.dart';

final journalContentDraftProvider = StateProvider<String>((ref) => '');

final aiFeedbackProvider = StateProvider<String>((ref) => '');
final aiPatternProvider = StateProvider<String>((ref) => '');