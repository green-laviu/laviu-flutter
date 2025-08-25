import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laviu_flutter/data/model/enums/stream_status.dart';
import 'package:laviu_flutter/data/model/live_stream.dart';
import 'package:laviu_flutter/data/model/user.dart';
import 'package:laviu_flutter/data/repository/user_repository.dart';
import 'package:laviu_flutter/main.dart';
import 'package:logger/logger.dart';

final userDetailProvider =
    AutoDisposeNotifierProvider.family<UserDetailVM, UserDetailModel?, int>(() {
      return UserDetailVM();
    });

class UserDetailVM extends AutoDisposeFamilyNotifier<UserDetailModel?, int> {
  final mContext = navigatorKey.currentContext!;

  @override
  UserDetailModel? build(int userId) {
    init(userId);

    ref.onDispose(() {
      Logger().d("UserDetailVM 파괴됨");
    });

    return null;
  }

  Future<void> init(int userId) async {
    Map<String, dynamic> body = await UserRepository().getUserById(userId);
    if (body["status"] != 200) {
      ScaffoldMessenger.of(mContext).showSnackBar(
        SnackBar(content: Text("다른 유저 정보 조회 실패 : ${body["msg"]}")),
      );
      return;
    }

    state = UserDetailModel.fromMap(body["data"]);
  }
}

class UserDetailModel {
  User user;
  bool isFollowing;
  bool isNotified;
  StreamStatus? streamStatus;
  LiveStream? liveStream;

  UserDetailModel(
    this.user,
    this.isFollowing,
    this.isNotified,
    this.streamStatus,
    this.liveStream,
  );

  UserDetailModel.fromMap(Map<String, dynamic> data)
    : user = User.fromMap(data["streamer"]),
      isFollowing = data['streamer']['isFollowing'] ?? false,
      isNotified = data['streamer']['isNotified'] ?? false,
      streamStatus = StreamStatus.fromValue(data['streamer']['streamStatus']),
      liveStream = data['liveStream'] == null
          ? null
          : LiveStream.fromJson(data['liveStream']);

  UserDetailModel copyWith({
    User? user,
    bool? isFollowing,
    bool? isNotified,
    StreamStatus? streamStatus,
    LiveStream? liveStream,
  }) {
    return UserDetailModel(
      user ?? this.user,
      isFollowing ?? this.isFollowing,
      isNotified ?? this.isNotified,
      streamStatus ?? this.streamStatus,
      liveStream ?? this.liveStream,
    );
  }

  @override
  String toString() {
    return 'UserDetailModel{user: $user, isFollowing: $isFollowing, isNotified: $isNotified, streamStatus: $streamStatus, liveStream: $liveStream}';
  }
}
