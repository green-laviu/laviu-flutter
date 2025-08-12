import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:laviu_flutter/data/model/search.dart';

class SearchRepository {
  Future<SearchResponse> fetchMock(String query) async {
    // 실제로는 query로 다른 파일/엔드포인트 분기 가능
    final raw = await rootBundle.loadString('assets/mock/search.json');
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return SearchResponse.fromJson(map);
  }
}
