import 'package:laviu_flutter/_core/utils/m_http.dart';

class LiveWatchRepository {
  /// GET /s/api/v1/streams/{streamId}
  /// 서버 래퍼 {status,msg,data} 중 data.live 만 반환
  Future<Map<String, dynamic>> fetchLiveDetail(int streamId) async {
    final res = await dio.get('/s/api/v1/streams/$streamId');

    final body = res.data;
    if (body is! Map) {
      throw Exception('Unexpected response type: ${res.data.runtimeType}');
    }

    final data = body['data'];
    if (data is! Map) {
      final msg = body['msg'] ?? 'Missing "data" field';
      throw Exception('API error: $msg');
    }

    final live = data['live'];
    if (live is! Map) {
      throw Exception('Missing "live" field in data');
    }

    return Map<String, dynamic>.from(live);
  }
}
