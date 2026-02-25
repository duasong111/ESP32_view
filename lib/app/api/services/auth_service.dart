// lib/services/auth_service.dart

import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService extends GetxService {
  final storage = FlutterSecureStorage();

  final isLoggedIn = false.obs;
  final token = ''.obs;
  final currentUser = ''.obs;

  // 初始化方法
  Future<AuthService> init() async {
    await checkLoginStatus();
    return this;
  }

  // 从安全存储中恢复登录状态
  Future<void> checkLoginStatus() async {
    try {
      final savedToken = await storage.read(key: 'access_token');
      final savedUsername = await storage.read(key: 'current_username');

      if (savedToken != null &&
          savedToken.isNotEmpty &&
          savedUsername != null &&
          savedUsername.isNotEmpty) {
        token.value = savedToken;
        currentUser.value = savedUsername;
        isLoggedIn.value = true;
      } else {
        _clearLoginState();
      }
    } catch (e) {
      _clearLoginState();
    }
  }

  // 内部方法：清空登录状态
  void _clearLoginState() {
    isLoggedIn.value = false;
    token.value = '';
    currentUser.value = '';
  }

  // 登录方法（保留你原来的模拟登录，可替换成真实调用）
  Future<bool> login(String username, String password) async {
    try {
      // 模拟登录API调用
      await Future.delayed(const Duration(seconds: 1));

      // 登录成功后保存token
      await storage.write(key: 'access_token', value: 'jwt_token_$username');
      await storage.write(key: 'current_username', value: username);

      token.value = 'jwt_token_$username';
      currentUser.value = username;
      isLoggedIn.value = true;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 修改后的 setLogin 方法
  /// 用于注册成功或登录成功后统一设置登录状态
  Future<void> setLogin(
    String accessToken, {
    String? username,
  }) async {
    // 保存 token
    await storage.write(key: 'access_token', value: accessToken);
    token.value = accessToken;
    isLoggedIn.value = true;

    // 保存用户名
    if (username != null && username.isNotEmpty) {
      await storage.write(key: 'current_username', value: username);
      currentUser.value = username;
    }
  }

  // 登出方法
  Future<void> logout() async {
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'current_username');

    isLoggedIn.value = false;
    token.value = '';
    currentUser.value = '';
  }
}