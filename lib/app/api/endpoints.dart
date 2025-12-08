// lib/api/endpoints.dart
class Endpoints {
  // 不同环境的基地址
  static const String _devAndroid = 'http://10.0.2.2:8000';
  static const String _devIOS = 'http://127.0.0.1:8000';
  static const String _devRealDevice = 'http://192.168.1.6:8000';  // 改成你局域网IP
  static const String _prod = 'https://api.yourdomain.com';

  // 关键：增加一个可手动切换的标志（调试超级方便）
  static bool get isProduction => const bool.fromEnvironment('dart.vm.product');

  static String get baseUrl {
    if (isProduction) {
      return _devRealDevice;
    }

    // 开发环境：优先读取本地存储的调试地址，没有就用默认真机地址
    // const debugUrl = String.fromEnvironment('API_BASE_URL');
    // if (debugUrl.isNotEmpty) {
    //   return debugUrl;
    // }
    return _devRealDevice;   
  }

  // 认证模块
  static const String loginEndpoint = '/api/chat/user_login/';
  static const String refreshTokenEndpoint = '/api/chat/refresh_token/';
  static const String registerEndpoint = '/api/chat/user_register/';
  static const String encryptPrivateKeyEndpoint = '/api/chat/encrypt_private_key/';
  static const String testEndpoint = '/api/test';
  
  // Chat 模块
  static const String chatList = '/chat/messages';
  static const String sendMsg = '/chat/send';
  static const String userInfo = '/user/info';
}