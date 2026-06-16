import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../models/journal_dto.dart';
import '../../models/analytics_dto.dart';
import '../../models/metadata_dto.dart';
import '../../models/streak_dto.dart';

part 'journal_api_client.g.dart';

@RestApi(baseUrl: "http://localhost:5135/api/")
abstract class JournalApiClient {
  factory JournalApiClient(Dio dio, {String baseUrl}) = _JournalApiClient;

  @POST("Journal")
  Future<HttpResponse<void>> createEntry(@Body() Map<String, dynamic> body);

  @GET("Journal")
  Future<List<JournalDto>> getEntries();

  @POST("Journal/analyze")
  Future<dynamic> analyzeEntry(@Body() Map<String, dynamic> body);

  @GET("Journal/analytics")
  Future<AnalyticsDto> getAnalytics();

  @GET("Journal/emotions")
  Future<List<EmotionDto>> getEmotions();

  @GET("Journal/tags")
  Future<List<ContextTagDto>> getContextTags();

  @GET('/Journal/streak/{userId}')
  Future<StreakDto> getCurrentStreak(@Path('userId') String userId);
}