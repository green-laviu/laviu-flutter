import 'package:dio/dio.dart';
import 'package:laviu_flutter/_core/utils/m_http.dart';
import 'package:logger/logger.dart';

class UserRepository {
  Future<Map<String, dynamic>> oauthLogin(String accessToken) async {
    // Response response = await dio.post("/oauth/login", data: {"accessToken": accessToken});
    // final responseBody = response.data;
    final responseBody = {
      "status": 200,
      "msg": "성공",
      "data": {
        "userId": 2,
        "nickname": "new_user",
        "email": "newuser@example.com",
        "profileUrl": "profile_image_url_2",
        "providerType": "NAVER",
        "token": "mock-jwt-token-for-new-user",
        "isNewUser": true,
      },
    };
    Logger().d('UserRepository의 oauthLogin: ${responseBody}');
    return responseBody;
  }

  Future<Map<String, dynamic>> writeAdditionalInfo(Map<String, dynamic> data) async {
    Response response = await dio.put("/s/user/addtion-info", data: data);
    final responseBody = response.data;
    Logger().d('UserRepository의 writeAdditionalInfo: ${responseBody}');
    return responseBody;
  }

  Future<Map<String, dynamic>> update(Map<String, dynamic> data) async {
    Response response = await dio.put("/s/api/users", data: data);
    Logger().d("update data : $data");
    final responseBody = response.data;
    Logger().d('UserRepository의 update: ${responseBody}');
    return responseBody;
  }
}
