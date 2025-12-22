// lib/api/client/dio_client.dart
import 'package:dio/dio.dart';
import '../endpoints.dart';
import 'interceptor.dart';

class DioClient {
  static final DioClient _singleton = DioClient._();
  factory DioClient() => _singleton;
  DioClient._();

  late final Dio dio;
  bool _isInitialized = false;

  void init() {
    dio = Dio(BaseOptions(
      baseUrl: Endpoints.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    dio.interceptors.add(ApiInterceptor());
    _isInitialized = true;
  }
  Dio get _dio {
    if (!_isInitialized) {
      throw Exception('DioClient 未初始化！请在 main() 中调用 DioClient().init()');
    }
    return dio;
  }
  // 添加 GET 请求方法
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  // 添加 POST 请求方法
  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  // 添加其他 HTTP 方法...
  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }
}