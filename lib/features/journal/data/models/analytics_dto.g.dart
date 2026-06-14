// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalyticsDto _$AnalyticsDtoFromJson(Map<String, dynamic> json) => AnalyticsDto(
  totalEntries: (json['totalEntries'] as num).toInt(),
  dominantEmotion: json['dominantEmotion'] as String,
  dominantPattern: json['dominantPattern'] as String,
  topDisparadores: (json['topDisparadores'] as List<dynamic>)
      .map((e) => ContextTagCountDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$AnalyticsDtoToJson(AnalyticsDto instance) =>
    <String, dynamic>{
      'totalEntries': instance.totalEntries,
      'dominantEmotion': instance.dominantEmotion,
      'dominantPattern': instance.dominantPattern,
      'topDisparadores': instance.topDisparadores,
    };

ContextTagCountDto _$ContextTagCountDtoFromJson(Map<String, dynamic> json) =>
    ContextTagCountDto(
      tagName: json['tagName'] as String,
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$ContextTagCountDtoToJson(ContextTagCountDto instance) =>
    <String, dynamic>{'tagName': instance.tagName, 'count': instance.count};
