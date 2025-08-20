import 'package:dio/dio.dart';
import 'package:laviu_flutter/_core/utils/m_http.dart';
import 'package:logger/logger.dart';

class LiveStreamRepository {
  Future<Map<String, dynamic>> start(Map<String, dynamic> data) async {
    Response response = await dio.post("/s/api/v1/streams/start", data: data);
    final responseBody = response.data;
    // final responseBody = {
    //   "status": 200,
    //   "msg": "성공",
    //   "data": {
    //     "streamId": 4,
    //     "streamKey": "5067c36c-091c-4402-a1b9-f86f8eccbbb7",
    //     "title": "방송타이틀",
    //     "hashtagList": [
    //       {"hashtagId": 3, "hashtagName": "게임1"},
    //       {"hashtagId": 4, "hashtagName": "방송1"},
    //     ],
    //     "status": "PENDING",
    //   },
    // };
    Logger().d('LiveStreamRepository의 start: ${responseBody}');
    return responseBody;
  }
}
