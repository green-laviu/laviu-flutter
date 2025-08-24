import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laviu_flutter/data/model/search.dart';
import 'package:laviu_flutter/data/repository/search_repository.dart';

final searchRepositoryProvider = Provider<SearchRepository>(
  (ref) => SearchRepository(),
);

// 검색어/탭 선택 상태
final searchQueryProvider = StateProvider<String>((ref) => '');
final searchTabIndexProvider = StateProvider<int>(
  (ref) => 1,
); // 0=채널, 1=라이브 (기본 라이브)

// 결과
final searchResponseProvider = FutureProvider<SearchResponse>((ref) async {
  final repo = ref.watch(searchRepositoryProvider);
  final q = ref.watch(searchQueryProvider);
  return repo.fetch(q); // fetchMock → fetch 로 교체
});
