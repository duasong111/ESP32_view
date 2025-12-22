// lib/api/endpoints.dart
class Endpoints {
  // 不同环境的基地址
  static const String _devAndroid = 'http://10.0.2.2:8000';
  static const String _devIOS = 'http://127.0.0.1:8000';
  static const String _devRealDevice = 'http://192.168.1.18:8000';  // 改成你局域网IP
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
  static const String loginEndpoint = '/api/chat/user_login/'; // 用户登录
  static const String refreshTokenEndpoint = '/api/chat/refresh_token/'; // 刷新用户认真信息
  static const String registerEndpoint = '/api/chat/user_register/';  // 用户注册信息
  static const String encryptPrivateKeyEndpoint = '/api/chat/encrypt_private_key/'; // 解密私钥
  static const String applyOfFriends = '/api/chat/send_friend_request/'; // 发送好友申请
  static const String refreshOfFriends = '/api/chat/refresh_friend_request/'; // 刷新好友申请
  static const String acceptOfFriends = '/api/chat/accept_friend_request/'; // 接受好友申请
  static const String getFriendsList = '/api/chat/get_friend_list/'; // 获取好友列表
  static const String showHistory = '/api/chat/show_history/'; // 查看聊天记录
  static const String unreadCount = '/api/chat/unread_count/'; // 查看未读消息数量




  
 
  
  // Chat 模块
  static const String chatList = '/chat/messages';
  static const String sendMsg = '/chat/send';
  static const String userInfo = '/user/info';
}