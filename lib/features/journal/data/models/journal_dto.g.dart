// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JournalDto _$JournalDtoFromJson(Map<String, dynamic> json) => JournalDto(
  userId: json['userId'] as String,
  content: json['content'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$JournalDtoToJson(JournalDto instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
    };
