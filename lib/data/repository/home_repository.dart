import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:laviu_flutter/data/model/home_feed.dart';

class HomeRepository {
  Future<HomeFeed> fetchHomeFeedMock() async {
    final raw = await rootBundle.loadString('assets/mock/home_feed.json');
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return HomeFeed.fromJson(map);
  }
}
