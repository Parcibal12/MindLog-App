import 'package:json_annotation/json_annotation.dart';

part 'streak_dto.g.dart';

@JsonSerializable()
class StreakDto {
  final int currentStreak;

  StreakDto({required this.currentStreak});

  factory StreakDto.fromJson(Map<String, dynamic> json) => _$StreakDtoFromJson(json);
  Map<String, dynamic> toJson() => _$StreakDtoToJson(this);
}