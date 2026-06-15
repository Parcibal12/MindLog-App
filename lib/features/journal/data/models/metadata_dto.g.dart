// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metadata_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmotionDto _$EmotionDtoFromJson(Map<String, dynamic> json) => EmotionDto(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  colorHex: json['colorHex'] as String?,
);

Map<String, dynamic> _$EmotionDtoToJson(EmotionDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'colorHex': instance.colorHex,
    };

ContextTagDto _$ContextTagDtoFromJson(Map<String, dynamic> json) =>
    ContextTagDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$ContextTagDtoToJson(ContextTagDto instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};
