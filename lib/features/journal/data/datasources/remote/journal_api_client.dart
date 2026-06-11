import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'journal_api_client.g.dart';

@RestApi(baseUrl: "http://localhost:5135/api/")
abstract class JournalApiClient {
  factory JournalApiClient(Dio dio, {String baseUrl}) = _JournalApiClient;

  @POST("Journal")
  Future<HttpResponse<void>> createEntry(@Body() Map<String, dynamic> body);
}