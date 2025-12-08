// lib/api/client/interceptor.dart
import 'package:dio/dio.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('🔄 API Request: ${options.method} ${options.uri}');
    print('📱 Request URL: ${options.baseUrl}${options.path}');
    print('⏰ Request Time: ${DateTime.now()}');
    super.onRequest(options, handler);
  }
  @override
  void onResponse(Response r, ResponseInterceptorHandler handler) {
    print(' interfaceptor -- 🔄 API Response: ${r.statusCode}');
    super.onResponse(r, handler);
  }
  @override
  void onError(DioException e, ErrorInterceptorHandler handler) {
    print('API Error: ${e.response?.statusCode} ${e.message}');
    super.onError(e, handler);
  }
}