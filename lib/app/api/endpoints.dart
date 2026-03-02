// lib/api/endpoints.dart
class Endpoints {
  // 不同环境的基地址
  static const String _devAndroid = 'http://10.0.2.2:8000';
  static const String _devIOS = 'http://127.0.0.1:8000';
  static const String _devRealDevice = 'http://192.168.18.236:8000';  // 改成你局域网IP
  static const String _prod = 'https://api.yourdomain.com';

  // 关键：增加一个可手动切换的标志（调试超级方便）
  static bool get isProduction => const bool.fromEnvironment('dart.vm.product');

  static String get baseUrl {
    if (isProduction) {
      return _devRealDevice;
    }
    return _devRealDevice;   
  }

  // 认证模块
  static const String login = '/api/login'; // 用户登录
  static const String register = '/api/register';  // 用户注册信息

  // WebSocket 模块
  static String get wsBaseUrl => baseUrl.replaceFirst('http://', 'ws://');
  static const String esp32Data = '/esp32/data';  // ESP32 数据推送
  static const String rgbControl = '/api/device/rgb';  // RGB 控制
  static const String buzzerControl = '/api/device/buzzer';  // 蜂鸣器控制
  static const String modifyScreenText = '/api/device/screen/text';  // 修改屏幕文字

}