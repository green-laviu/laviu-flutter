import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:laviu_flutter/data/model/following.dart';

class FollowingRepository {
  Future<FollowingFeed> fetchMock() async {
    final raw = await rootBundle.loadString('assets/mock/following.json');
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return FollowingFeed.fromJson(map);
  }
}
