import 'package:json_annotation/json_annotation.dart';

part 'analytics_dto.g.dart';

@JsonSerializable()
class AnalyticsDto {
  final int totalEntries;
  final String dominantEmotion;
  final String dominantPattern;
  final List<ContextTagCountDto> topDisparadores;

  AnalyticsDto({
    required this.totalEntries,
    required this.dominantEmotion,
    required this.dominantPattern,
    required this.topDisparadores,
  });

  factory AnalyticsDto.fromJson(Map<String, dynamic> json) => _$AnalyticsDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AnalyticsDtoToJson(this);
}

@JsonSerializable()
class ContextTagCountDto {
  final String tagName;
  final int count;
  @JsonKey(defaultValue: "Ninguna")
  final String dominantEmotion;

  ContextTagCountDto({
    required this.tagName,
    required this.count,
    required this.dominantEmotion,
  });

  factory ContextTagCountDto.fromJson(Map<String, dynamic> json) => _$ContextTagCountDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ContextTagCountDtoToJson(this);
}