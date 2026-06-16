class UpdateProfileDto {
  final String? therapistName;
  final String? therapistEmail;
  final bool autoSendReports;

  UpdateProfileDto({
    this.therapistName,
    this.therapistEmail,
    required this.autoSendReports,
  });

  Map<String, dynamic> toJson() => {
    'therapistName': therapistName,
    'therapistEmail': therapistEmail,
    'autoSendReports': autoSendReports,
  };
}