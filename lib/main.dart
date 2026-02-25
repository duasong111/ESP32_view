// lib/main.dart
import 'package:flutter/material.dart';
import 'app/app.dart';
import 'app/api/client/dio_client.dart';
// 将主文件引入，使得进行多界面的方向发展
void main() {
  DioClient().init();
  runApp(const App());
}