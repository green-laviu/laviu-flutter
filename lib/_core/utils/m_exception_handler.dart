import 'package:flutter/material.dart';
import 'package:laviu_flutter/main.dart';
import 'package:logger/logger.dart';

class ExceptionHandler {
  static void handleException(dynamic exception, StackTrace stackTrace) {
    Logger().d('Exception occurred: $exception');
    Logger().d('StackTrace: $stackTrace');

    final mContext = navigatorKey.currentContext;

    ScaffoldMessenger.of(mContext!).showSnackBar(
      SnackBar(content: Text("$exception")),
    );
  }
}
