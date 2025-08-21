import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:laviu_flutter/data/model/home_feed.dart';

class HomeRepository {
  final Dio _dio;

  // 임시 토큰. 나중에 세션/스토리지에서 주입
  final String _token;

  HomeRepository({Dio? dio, String? token})
    : _token =
          token ??
          'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJsYXZpdSIsInJvbGVzIjoiVVNFUiIsIm5pY2tuYW1lIjoidGVzdFZpZXdlciIsImlkIjo2LCJleHAiOjE3NTYyNjYxMDgsImVtYWlsIjoidGVzdFZpZXdlckBuYXRlLmNvbSJ9.DZK0sHXfmZdNSbVzbLMPv_uL-INP-93sbh4hIL1lW4_72XU66UMgT81MpxG3OFD4gVY2tCnH2_iNt_mq_dnfGw',
      _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: _resolveBaseUrl(),
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 10),
              // 공통 헤더(토큰은 요청 시 주입)
            ),
          );

  // 플랫폼/에뮬레이터 별 baseUrl 계산
  static String _resolveBaseUrl() {
    if (kIsWeb) return 'http://localhost:8080';
    try {
      if (Platform.isAndroid) {
        // Android 에뮬레이터에서 호스트 PC의 localhost 접근
        return 'http://10.0.2.2:8080';
      }
    } catch (_) {
      /* web일 때 Platform 접근 방지 */
    }
    return 'http://localhost:8080';
  }

  /// 실제 서버에서 홈 피드 가져오기
  Future<HomeFeed> fetchHomeFeed() async {
    final res = await _dio.get(
      '/s/api/v1/streams',
      options: Options(
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      ),
    );

    // 응답 래퍼: { status, msg, data }
    final body = res.data;
    if (body is! Map) {
      throw Exception('Unexpected response type: ${res.data.runtimeType}');
    }
    final data = body['data'];
    if (data is! Map) {
      throw Exception('Missing "data" field in response');
    }

    return HomeFeed.fromJson(Map<String, dynamic>.from(data));
  }
}
