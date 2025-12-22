// lib/services/auth_service.dart
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService extends GetxService {
  final storage = FlutterSecureStorage();
  final isLoggedIn = false.obs;
  final token = ''.obs;
  final currentUser = ''.obs;
  final privateKey = ''.obs; // 新增：用户的私钥
  final publicKey = ''.obs; // 新增：用户的公钥
  
  // 初始化方法
  Future<AuthService> init() async {
    await checkLoginStatus();
    return this;
  }
  
  // 从安全存储中恢复登录状态
  Future<void> checkLoginStatus() async {
    try {
      final savedToken = await storage.read(key: 'access_token');
      final savedPrivateKey = await storage.read(key: 'private_key');
      final savedPublicKey = await storage.read(key: 'public_key');
      final savedCurrentUser = await storage.read(key: 'current_username');
      
      print('AuthService.checkLoginStatus - 从存储读取: token: $savedToken, username: $savedCurrentUser, publicKey: $savedPublicKey, privateKey: $savedPrivateKey');
      
      // 只有当token和用户名都存在且不为空时，才认为已登录
      if (savedToken != null && savedToken.isNotEmpty && savedCurrentUser != null && savedCurrentUser.isNotEmpty) {
        token.value = savedToken;
        currentUser.value = savedCurrentUser;
        isLoggedIn.value = true;
        
        // 更新公钥和私钥
        privateKey.value = savedPrivateKey ?? '';
        publicKey.value = savedPublicKey ?? '';
        
        print('AuthService - 已登录，公钥: ${publicKey.value}');
      } else {
        // 否则重置登录状态
        isLoggedIn.value = false;
        token.value = '';
        currentUser.value = '';
        privateKey.value = '';
        publicKey.value = '';
        print('AuthService - 未登录');
      }
    } catch (e) {
      print('AuthService - 检查登录状态失败: $e');
      isLoggedIn.value = false;
      token.value = '';
      currentUser.value = '';
      privateKey.value = '';
      publicKey.value = '';
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
  Future<void> setLogin(String accessToken, {String? privateKey, String? publicKey, String? username}) async {
    print('AuthService.setLogin - accessToken: $accessToken, username: $username, publicKey: $publicKey, privateKey: $privateKey');
    await storage.write(key: 'access_token', value: accessToken);
    token.value = accessToken;
    isLoggedIn.value = true;
    
    // 保存用户名
    if (username != null && username.isNotEmpty) {
      await storage.write(key: 'current_username', value: username);
      currentUser.value = username;
    } else {
      // 如果没有提供用户名，尝试从存储中读取
      final savedUsername = await storage.read(key: 'current_username');
      if (savedUsername != null) {
        currentUser.value = savedUsername;
      }
    }
    
    // 保存私钥
    if (privateKey != null && privateKey.isNotEmpty) {
      await storage.write(key: 'private_key', value: privateKey);
      this.privateKey.value = privateKey;
      print('AuthService - 私钥已保存: $privateKey');
    } else {
      print('AuthService - 传入的私钥为空，不保存');
    }
    
    // 保存公钥
    if (publicKey != null && publicKey.isNotEmpty) {
      await storage.write(key: 'public_key', value: publicKey);
      this.publicKey.value = publicKey;
      print('AuthService - 公钥已保存: $publicKey');
    } else {
      print('AuthService - 传入的公钥为空，不保存');
    }
    print('AuthService - 登录成功，公钥值: ${this.publicKey.value}');
  }
  
  // 更新私钥
  Future<void> updatePrivateKey(String newPrivateKey) async {
    await storage.write(key: 'private_key', value: newPrivateKey);
    privateKey.value = newPrivateKey;
  }
  
  // 登出方法
  Future<void> logout() async {
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'private_key');
    await storage.delete(key: 'public_key');
    await storage.delete(key: 'current_username');
    isLoggedIn.value = false;
    token.value = '';
    currentUser.value = '';
    privateKey.value = '';
    publicKey.value = '';
  }
}