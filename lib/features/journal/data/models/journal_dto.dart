import 'package:json_annotation/json_annotation.dart';

part 'journal_dto.g.dart';

@JsonSerializable()
class JournalDto {
  final String userId;
  final String content;
  final int emotionId;
  final String emotionName;
  final int intensity;
  final List<int> contextTagIds;
  final DateTime createdAt;
  final String? aiFeedback; 
  final String? aiPattern;

  JournalDto({
    required this.userId,
    required this.content,
    required this.emotionId,
    required this.emotionName,
    required this.intensity,
    required this.contextTagIds,
    required this.createdAt,
    this.aiFeedback,
    this.aiPattern,
  });

  factory JournalDto.fromJson(Map<String, dynamic> json) => _$JournalDtoFromJson(json);
  Map<String, dynamic> toJson() => _$JournalDtoToJson(this);
}