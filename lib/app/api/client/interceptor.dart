// lib/api/client/interceptor.dart
import 'package:dio/dio.dart' as dio;          // 给 dio 包加个前缀
import 'package:get/get.dart';
import '../services/auth_service.dart';

class ApiInterceptor extends dio.Interceptor {
  @override
  void onRequest(dio.RequestOptions options, dio.RequestInterceptorHandler handler) {
    final authService = Get.find<AuthService>();
    if (authService.isLoggedIn.value && authService.token.value.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer ${authService.token.value}';
    } else {
    }
    super.onRequest(options, handler);
  }
  @override
  void onResponse(dio.Response<dynamic> r, dio.ResponseInterceptorHandler handler) {
    super.onResponse(r, handler);
  }

  @override
  void onError(dio.DioException e, dio.ErrorInterceptorHandler handler) {
    print('API Error: ${e.response?.statusCode} ${e.message}');
    super.onError(e, handler);
  }
}