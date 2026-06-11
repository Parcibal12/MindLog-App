// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JournalDto _$JournalDtoFromJson(Map<String, dynamic> json) => JournalDto(
  userId: json['userId'] as String,
  content: json['content'] as String,
  emotionId: (json['emotionId'] as num).toInt(),
  emotionName: json['emotionName'] as String,
  intensity: (json['intensity'] as num).toInt(),
  contextTagIds: (json['contextTagIds'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  aiFeedback: json['aiFeedback'] as String?,
  aiPattern: json['aiPattern'] as String?,
);

Map<String, dynamic> _$JournalDtoToJson(JournalDto instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'content': instance.content,
      'emotionId': instance.emotionId,
      'emotionName': instance.emotionName,
      'intensity': instance.intensity,
      'contextTagIds': instance.contextTagIds,
      'createdAt': instance.createdAt.toIso8601String(),
      'aiFeedback': instance.aiFeedback,
      'aiPattern': instance.aiPattern,
    };
