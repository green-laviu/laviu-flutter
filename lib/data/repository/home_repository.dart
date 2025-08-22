import 'package:dio/dio.dart';
import 'package:laviu_flutter/_core/utils/m_http.dart';
import 'package:laviu_flutter/data/model/home_feed.dart';

class HomeRepository {
  HomeRepository();

  /// 홈 피드 조회: GET /s/api/v1/streams
  /// 서버 래퍼 {status, msg, data} 기준으로 data만 파싱
  Future<HomeFeed> fetchHomeFeed() async {
    final Response res = await dio.get('/s/api/v1/streams');

    // m_http.dart에 validateStatus=true라서 4xx/5xx도 throw 안 됨 → 바디로 판별
    final body = res.data;
    if (body is! Map) {
      throw Exception('Unexpected response type: ${res.data.runtimeType}');
    }

    final apiStatus = body['status'] as int?;
    if (apiStatus != null && apiStatus != 200) {
      final msg = body['msg']?.toString() ?? 'API status != 200';
      throw Exception('API error: $msg');
    }

    final data = body['data'];
    if (data is! Map) {
      final msg = body['msg']?.toString() ?? 'Missing "data" field';
      throw Exception('API error: $msg');
    }

    return HomeFeed.fromJson(Map<String, dynamic>.from(data));
  }
}
