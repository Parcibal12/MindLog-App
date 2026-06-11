import 'package:json_annotation/json_annotation.dart';

part 'journal_dto.g.dart';

@JsonSerializable()
class JournalDto {
  final String userId;
  final String content;
  final DateTime createdAt;

  JournalDto({
    required this.userId,
    required this.content,
    required this.createdAt,
  });

  factory JournalDto.fromJson(Map<String, dynamic> json) => _$JournalDtoFromJson(json);
  Map<String, dynamic> toJson() => _$JournalDtoToJson(this);
}