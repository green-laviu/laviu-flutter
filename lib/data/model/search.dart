class SearchPagination {
  final int page, pageSize, totalChannel, totalLive;
  SearchPagination({
    required this.page,
    required this.pageSize,
    required this.totalChannel,
    required this.totalLive,
  });
  factory SearchPagination.fromJson(Map<String, dynamic> j) => SearchPagination(
    page: j['page'],
    pageSize: j['pageSize'],
    totalChannel: j['totalChannel'],
    totalLive: j['totalLive'],
  );
}

class ChannelResult {
  final String id, name, thumbnailUrl;
  final int followerCount;
  bool isFollowing;
  ChannelResult({
    required this.id,
    required this.name,
    required this.thumbnailUrl,
    required this.followerCount,
    required this.isFollowing,
  });
  factory ChannelResult.fromJson(Map<String, dynamic> j) => ChannelResult(
    id: j['id'],
    name: j['name'],
    thumbnailUrl: j['thumbnailUrl'],
    followerCount: j['followerCount'],
    isFollowing: j['isFollowing'],
  );
}

class LiveResult {
  final String id, title, thumbnailUrl, channelName;
  final int viewers;
  final List<String> badges;
  LiveResult({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.viewers,
    required this.channelName,
    required this.badges,
  });
  factory LiveResult.fromJson(Map<String, dynamic> j) => LiveResult(
    id: j['id'],
    title: j['title'],
    thumbnailUrl: j['thumbnailUrl'],
    viewers: j['viewers'],
    channelName: j['channelName'],
    badges: List<String>.from(j['badges']),
  );
}

class SearchResponse {
  final String query, selectedFilter;
  final List<String> suggestions, filters;
  final SearchPagination pagination;
  final List<ChannelResult> channels;
  final List<LiveResult> lives;

  SearchResponse({
    required this.query,
    required this.selectedFilter,
    required this.suggestions,
    required this.filters,
    required this.pagination,
    required this.channels,
    required this.lives,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> j) => SearchResponse(
    query: j['query'],
    selectedFilter: j['selectedFilter'],
    suggestions: List<String>.from(j['suggestions']),
    filters: List<String>.from(j['filters']),
    pagination: SearchPagination.fromJson(j['pagination']),
    channels: (j['results']['channel'] as List)
        .map((e) => ChannelResult.fromJson(e))
        .toList(),
    lives: (j['results']['live'] as List)
        .map((e) => LiveResult.fromJson(e))
        .toList(),
  );
}
