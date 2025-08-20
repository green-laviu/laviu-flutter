import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final baseUrl = dotenv.env['BASE_URL']!;
final accessToken =
    "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJsYXZpdSIsInJvbGVzIjoiVVNFUiIsIm5pY2tuYW1lIjoidGVzdFN0cmVhbWVyIiwiaWQiOjUsImV4cCI6MTc1NjI2NjEzMywiZW1haWwiOiJ0ZXN0U3RyZWFtZXJAbmF0ZS5jb20ifQ.Buvlkcat0_GSYQunSuAYpoO94Rf5IOyZj1sLrYKKTox_iwaDLWzLYZp1nowvV8m2_W_FT7QCmWgtvHdltcIlkw";

final dio = Dio(
  BaseOptions(
    baseUrl: baseUrl,
    contentType: "application/json; charset=utf-8",
    validateStatus: (status) => true,
    headers: {
      "Authorization": "Bearer $accessToken",
    },
  ),
);
