import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final baseUrl = dotenv.env['BASE_URL']!;
final accessToken =
    "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJsYXZpdSIsIm5pY2tuYW1lIjoidGVzdFN0cmVhbWVyIiwiaWQiOjUsImV4cCI6MTc1NjE5NzI3MSwiZW1haWwiOiJ0ZXN0U3RyZWFtZXJAbmF0ZS5jb20ifQ.1wFacq_MNf8JavSNYEyfo5q4YnYJqnvQvRWjdWcfzMLuBNFzyJuzmtsjreDtOUw-_Mphs8nIYbOa3-2x-bwSDQ";

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
