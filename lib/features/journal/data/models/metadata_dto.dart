import 'package:json_annotation/json_annotation.dart';

part 'metadata_dto.g.dart';

@JsonSerializable()
class EmotionDto {
  final int id;
  final String name;
  @JsonKey(name: 'colorHex')
  final String? colorHex;

  EmotionDto({required this.id, required this.name, this.colorHex});

  factory EmotionDto.fromJson(Map<String, dynamic> json) => _$EmotionDtoFromJson(json);
  Map<String, dynamic> toJson() => _$EmotionDtoToJson(this);
}

@JsonSerializable()
class ContextTagDto {
  final int id;
  final String name;

  ContextTagDto({required this.id, required this.name});

  factory ContextTagDto.fromJson(Map<String, dynamic> json) => _$ContextTagDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ContextTagDtoToJson(this);
}