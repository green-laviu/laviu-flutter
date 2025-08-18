import 'package:flutter_riverpod/flutter_riverpod.dart';

final livePreviewProvider = NotifierProvider<LivePreviewFM, LivePreviewModel>(
  () {
    return LivePreviewFM();
  },
);

class LivePreviewFM extends Notifier<LivePreviewModel> {
  @override
  LivePreviewModel build() {
    return LivePreviewModel('', []);
  }

  void title(String title) {
    state = state.copyWith(
      title: title,
    );
  }

  void hashtagList(List<String> tags) {
    state = state.copyWith(hashtagList: tags);
  }
}

class LivePreviewModel {
  final String title;
  final List<String> hashtagList;

  LivePreviewModel(
    this.title, [
    this.hashtagList = const [],
  ]);

  LivePreviewModel copyWith({
    String? title,
    List<String>? hashtagList,
  }) {
    return LivePreviewModel(
      title ?? this.title,
      hashtagList != null ? List.unmodifiable(hashtagList) : this.hashtagList,
    );
  }

  @override
  String toString() {
    return 'LivePreviewModel{title: $title, hashtagList: $hashtagList}';
  }
}
