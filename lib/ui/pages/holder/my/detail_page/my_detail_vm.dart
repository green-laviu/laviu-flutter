import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laviu_flutter/data/model/live_stream.dart';
import 'package:laviu_flutter/data/model/user.dart';
import 'package:laviu_flutter/data/repository/user_repository.dart';
import 'package:laviu_flutter/main.dart';
import 'package:logger/logger.dart';

final myDetailProvider =
    AutoDisposeNotifierProvider<MyDetailVM, MyDetailModel?>(() {
      return MyDetailVM();
    });

class MyDetailVM extends AutoDisposeNotifier<MyDetailModel?> {
  final mContext = navigatorKey.currentContext!;

  @override
  MyDetailModel? build() {
    init();

    ref.onDispose(() {
      Logger().d("MyDetailVM 파괴됨");
    });

    return null;
  }

  Future<void> init() async {
    Map<String, dynamic> body = await UserRepository().getMe();
    if (body["status"] != 200) {
      ScaffoldMessenger.of(mContext).showSnackBar(
        SnackBar(content: Text("나의 정보 조회 실패 : ${body["msg"]}")),
      );
      return;
    }

    state = MyDetailModel.fromMap(body["data"]);
  }
}

class MyDetailModel {
  final User user;
  final LiveStream? liveStream;

  MyDetailModel(
    this.user,
    this.liveStream,
  );

  MyDetailModel.fromMap(Map<String, dynamic> data)
    : user = User.fromMap(data["me"]),
      liveStream = data['live'] == null
          ? null
          : LiveStream.fromJson(data['live']);

  MyDetailModel copyWith({
    User? user,
    LiveStream? liveStream,
  }) {
    return MyDetailModel(
      user ?? this.user,
      liveStream ?? this.liveStream,
    );
  }

  @override
  String toString() {
    return 'MyDetailModel{user: $user, liveStream: $liveStream}';
  }
}
