// lib/services/auth_service.dart
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService extends GetxService {
  final storage = FlutterSecureStorage();
  final isLoggedIn = false.obs;
  final token = ''.obs;
  
  // 初始化方法
  Future<AuthService> init() async {
    await checkLoginStatus();
    return this;
  }
  
  // 从安全存储中恢复登录状态
  Future<void> checkLoginStatus() async {
    final savedToken = await storage.read(key: 'access_token');
    
    if (savedToken != null && savedToken.isNotEmpty) {
      token.value = savedToken;
      isLoggedIn.value = true;
    }
  }
  
  // 登录方法
  Future<bool> login(String username, String password) async {
    try {
      // 模拟登录API调用
      await Future.delayed(Duration(seconds: 1));
      
      // 登录成功后保存token
      await storage.write(key: 'access_token', value: 'jwt_token_$username');
      
      token.value = 'jwt_token_$username';
      isLoggedIn.value = true;
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // 设置登录状态（用于注册成功后）
  Future<void> setLogin(String accessToken) async {
    await storage.write(key: 'access_token', value: accessToken);
    token.value = accessToken;
    isLoggedIn.value = true;
  }
  
  // 登出方法
  Future<void> logout() async {
    await storage.delete(key: 'access_token');
    isLoggedIn.value = false;
    token.value = '';
  }
}