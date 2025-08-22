import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laviu_flutter/data/repository/live_watch_repository.dart';

final liveWatchRepositoryProvider = Provider<LiveWatchRepository>((ref) {
  return LiveWatchRepository();
});

/// 상세 조회 프로바이더: streamId로 불러옴
final liveWatchDetailProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, streamId) async {
      final repo = ref.watch(liveWatchRepositoryProvider);
      return repo.fetchLiveDetail(streamId);
    });
