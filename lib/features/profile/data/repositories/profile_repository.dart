import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/update_profile_dto.dart';

class ProfileRepository {
  final String baseUrl = 'http://localhost:5135/api';

  Future<bool> updateProfile(String userId, UpdateProfileDto dto) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/Users/$userId/profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(dto.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> triggerReport() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Reports/trigger-automatic'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}