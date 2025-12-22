// lib/api/client/interceptor.dart
import 'package:dio/dio.dart' as dio;          // 给 dio 包加个前缀
import 'package:get/get.dart';
import '../services/auth_service.dart';

class ApiInterceptor extends dio.Interceptor {
  @override
  void onRequest(dio.RequestOptions options, dio.RequestInterceptorHandler handler) {
    // 打印请求地址
    print('🔍 拦截器 - 请求地址: ${options.uri}');
    print('🔍 拦截器 - 请求方法: ${options.method}');
    
    final authService = Get.find<AuthService>();
    if (authService.isLoggedIn.value && authService.token.value.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer ${authService.token.value}';
      print('✅ 拦截器 - 添加Authorization头: ${options.headers['Authorization']}');
    } else {
      print('❌ 拦截器 - 未添加Authorization头，用户未登录或Token为空');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(dio.Response<dynamic> r, dio.ResponseInterceptorHandler handler) {
    print('interceptor  API Response: ${r.statusCode} ${r.data}');
    super.onResponse(r, handler);
  }

  @override
  void onError(dio.DioException e, dio.ErrorInterceptorHandler handler) {
    print('API Error: ${e.response?.statusCode} ${e.message}');
    super.onError(e, handler);
  }
}