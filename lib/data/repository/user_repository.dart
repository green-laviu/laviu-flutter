import 'package:dio/dio.dart';
import 'package:laviu_flutter/_core/utils/m_http.dart';
import 'package:logger/logger.dart';

class UserRepository {
  Future<Map<String, dynamic>> oauthLogin(String accessToken) async {
    Response response = await dio.post(
      "/oauth/login",
      data: {"accessToken": accessToken},
    );
    final responseBody = response.data;
    // final responseBody = {
    //   "status": 200,
    //   "msg": "성공",
    //   "data": {
    //     "userId": 2,
    //     "nickname": "new_user",
    //     "email": "newuser@example.com",
    //     "profileUrl": "profile_image_url_2",
    //     "providerType": "NAVER",
    //     "token": "Bearer mock-jwt-token-for-new-user",
    //     "isNewUser": true,
    //   },
    // };
    Logger().d('UserRepository의 oauthLogin: ${responseBody}');
    return responseBody;
  }

  Future<Map<String, dynamic>> update(Map<String, dynamic> data) async {
    Response response = await dio.put("/s/api/users", data: data);
    Logger().d("update data : $data");
    final responseBody = response.data;
    Logger().d('UserRepository의 update: ${responseBody}');
    return responseBody;
  }

  // 다른 유저 정보 조회
  Future<Map<String, dynamic>> getUserById(int userId) async {
    // Response response = await dio.get("/s/api/v1/users/$userId");
    // final responseBody = response.data;
    final responseBody = {
      "status": 200,
      "msg": "성공",
      "data": {
        "streamer": {
          "userId": 3,
          "nickname": "love",
          "profileImageUrl": "https://nate.com/profile3.jpg",
          "followerCount": 0,
          "bio": "안녕하세요",
          "isFollowing": true,
          "isNotified": null,
          "streamStatus": "LIVE",
          "isLive": true,
        },
        "liveStream": {
          "streamId": 3,
          "streamKey": "vi8AP2rknBM800YI0l9Bog==",
          "title": "파이썬 기초 강의",
          "viewerCount": 50,
          "thumbnailUrl": "https://example.com/thumb3.jpg",
          "status": "LIVE",
          "hashtagList": [
            {"hashtagId": 2, "hashtagName": "방송"},
          ],
          "isLive": true,
        },
      },
    };
    Logger().d('UserRepository의 getUserById: ${responseBody}');
    return responseBody;
  }

  // 내 정보 조회
  Future<Map<String, dynamic>> getMe() async {
    // Response response = await dio.get("GET /s/api/v1/users/me");
    // final responseBody = response.data;
    final responseBody = {
      "status": 200,
      "msg": "성공",
      "data": {
        "me": {
          "userId": 1,
          "nickname": "ssar",
          "profileImageUrl": "https://nate.com/profile1.jpg",
          "followerCount": 2,
          "isLive": true,
          "bio": "안녕하세요",
        },
        "live": {
          "streamId": 1,
          "streamKey": "cfy_aDktqoqESx6g1DGBEw==",
          "title": "자바 기초 강의",
          "viewerCount": 100,
          "thumbnailUrl": "https://example.com/thumb1.jpg",
          "status": "LIVE",
          "hashtagList": [
            {"hashtagId": 1, "hashtagName": "게임"},
            {"hashtagId": 2, "hashtagName": "방송"},
          ],
          "isLive": true,
        },
      },
    };
    Logger().d('UserRepository의 getMe: ${responseBody}');
    return responseBody;
  }
}
