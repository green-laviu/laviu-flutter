import 'live_stream.dart';

class HomeFeed {
  final List<LiveStream> carousel;
  final List<LiveStream> recommended;

  HomeFeed({required this.carousel, required this.recommended});

  factory HomeFeed.fromJson(Map<String, dynamic> j) => HomeFeed(
    carousel: (j['carousel'] as List)
        .map((e) => LiveStream.fromJson(e))
        .toList(),
    recommended: (j['recommended'] as List)
        .map((e) => LiveStream.fromJson(e))
        .toList(),
  );
}
