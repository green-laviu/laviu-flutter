import 'package:laviu_flutter/_core/utils/m_http.dart';
import 'package:laviu_flutter/data/model/search.dart';

class SearchRepository {
  Future<SearchResponse> fetch(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      return SearchResponse(
        query: '',
        selectedFilter: 'all',
        suggestions: const [],
        filters: const ['all', 'channel', 'live'],
        pagination: SearchPagination(
          page: 1,
          pageSize: 0,
          totalChannel: 0,
          totalLive: 0,
        ),
        channels: const [],
        lives: const [],
      );
    }

    // 방송(스트림) 검색
    final resStreams = await dio.get(
      '/s/api/v1/search/streams',
      queryParameters: {'query': q},
    );
    final streamsRaw = (resStreams.data?['data'] as List<dynamic>? ?? []);
    final lives = streamsRaw.map((e) {
      final m = e as Map<String, dynamic>;
      final streamer = (m['streamer'] as Map<String, dynamic>? ?? {});
      final hashtagList = (m['hashtagList'] as List<dynamic>? ?? []);
      return LiveResult(
        id: (m['streamId'] ?? '').toString(),
        title: m['title'] ?? '',
        thumbnailUrl: m['thumbnailUrl'] ?? '',
        viewers: m['viewerCount'] ?? 0,
        channelName: streamer['nickname'] ?? '',
        badges: hashtagList
            .map(
              (h) =>
                  (h as Map<String, dynamic>)['hashtagName']?.toString() ?? '',
            )
            .where((s) => s.isNotEmpty)
            .toList(),
      );
    }).toList();

    // 유저(채널) 검색
    final resUsers = await dio.get(
      '/s/api/v1/search/users',
      queryParameters: {'query': q},
    );
    final usersRaw = (resUsers.data?['data'] as List<dynamic>? ?? []);
    final channels = usersRaw.map((e) {
      final m = e as Map<String, dynamic>;
      final follow = (m['followStatus'] as Map<String, dynamic>? ?? {});
      return ChannelResult(
        id: (m['userId'] ?? '').toString(),
        name: m['nickname'] ?? '',
        thumbnailUrl: m['profileImageUrl'] ?? '',
        followerCount: m['followerCount'] ?? 0,
        isFollowing: follow['isFollowing'] ?? false,
      );
    }).toList();

    return SearchResponse(
      query: q,
      selectedFilter: 'all',
      suggestions: const [],
      filters: const ['all', 'channel', 'live'],
      pagination: SearchPagination(
        page: 1,
        pageSize: lives.length + channels.length,
        totalChannel: channels.length,
        totalLive: lives.length,
      ),
      channels: channels,
      lives: lives,
    );
  }
}
