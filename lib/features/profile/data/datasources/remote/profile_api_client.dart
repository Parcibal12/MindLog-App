import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../models/update_profile_dto.dart';

part 'profile_api_client.g.dart';

@RestApi(baseUrl: "http://localhost:5135/api/")
abstract class ProfileApiClient {
  factory ProfileApiClient(Dio dio, {String baseUrl}) = _ProfileApiClient;

  @PUT("Users/{userId}/profile")
  Future<HttpResponse<void>> updateProfile(
    @Path("userId") String userId,
    @Body() UpdateProfileDto body,
  );

  @POST("Reports/trigger-automatic")
  Future<HttpResponse<void>> triggerReport();
}