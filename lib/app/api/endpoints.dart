// lib/api/endpoints.dart
class Endpoints {
  // 不同环境的基地址
  static const String _devAndroid = 'http://10.0.2.2:8000';
  static const String _devIOS = 'http://127.0.0.1:8000';
  static const String _devRealDevice = 'http://192.168.18.210:8000';  // 改成你局域网IP
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
  static const String getUserInfo = '/api/user/info';  // 获取用户信息
  static const String updateUserInfo = '/api/update';  // 更新用户信息

  // WebSocket 模块
  static String get wsBaseUrl => baseUrl.replaceFirst('http://', 'ws://');
  static const String esp32Data = '/esp32/data';  // ESP32 数据推送
  static const String rgbControl = '/api/device/rgb';  // RGB 控制
  static const String buzzerControl = '/api/device/buzzer';  // 蜂鸣器控制
  static const String modifyScreenText = '/api/device/screen/text';  // 修改屏幕文字
  static const String addBarkToken = '/api/device/accept_bark_token';  // 添加用户的Bark Token值
  static const String setBarkThreshold = '/api/device/accept_threshold';  // 设置温湿度发阈值
  static const String setDistanceThreshold = '/api/device/distance_threshold';  // 设置距离预警
  static const String controlSelfThreshold = '/api/device/control_self';  // 控制自己的阈值
  static const String deviceBind = '/api/device/bind';  // 绑定设备
  static const String deviceUnbind = '/api/device/unbind';  // 解绑设备
  static const String deviceControl = '/api/device/control';  // 控制设备
  static const String notifications = '/api/notifications';  // 通知模块
  static const String offlineConfig = '/api/device/offline_config';  // 下线配置模块
  
  }
