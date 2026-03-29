// lib/services/auth_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class User {
  final int id;
  final String username;
  final String? email;
  final String? address;
  final String? phone;
  final String? education;
  final String? avatar;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.username,
    this.email,
    this.address,
    this.phone,
    this.education,
    this.avatar,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user_id'] != null ? json['user_id'] as int : json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      education: json['education'] as String?,
      avatar: json['avatar'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': id,
      'username': username,
      'email': email,
      'address': address,
      'phone': phone,
      'education': education,
      'avatar': avatar,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class Device {
  final String deviceId;
  final String deviceName;
  final String activationCode;
  final DateTime? boundAt;

  Device({
    required this.deviceId,
    required this.deviceName,
    required this.activationCode,
    this.boundAt,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      deviceId: json['device_id'] as String,
      deviceName: json['device_name'] as String,
      activationCode: json['activation_code'] as String,
      boundAt: json['bound_at'] != null 
          ? DateTime.parse(json['bound_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'device_name': deviceName,
      'activation_code': activationCode,
      'bound_at': boundAt?.toIso8601String(),
    };
  }
}

class AuthService extends GetxService {
  final storage = FlutterSecureStorage();

  final isLoggedIn = false.obs;
  final token = ''.obs;
  final currentUser = ''.obs;
  final Rx<User?> userInfo = Rx<User?>(null);
  
  // 设备管理
  final RxList<Device> devices = <Device>[].obs;
  final Rx<Device?> selectedDevice = Rx<Device?>(null);

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
      final savedUserInfo = await storage.read(key: 'user_info');

      if (savedToken != null &&
          savedToken.isNotEmpty &&
          savedUsername != null &&
          savedUsername.isNotEmpty) {
        token.value = savedToken;
        currentUser.value = savedUsername;
        isLoggedIn.value = true;
        
        if (savedUserInfo != null) {
          try {
            userInfo.value = User.fromJson(jsonDecode(savedUserInfo));
          } catch (e) {
            debugPrint('解析用户信息失败: $e');
          }
        }
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
    userInfo.value = null;
    storage.delete(key: 'user_info');
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
    User? user,
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
    
    // 保存用户信息
    if (user != null) {
      userInfo.value = user;
      await storage.write(key: 'user_info', value: jsonEncode(user.toJson()));
    }
  }
  
  /// 更新用户信息
  Future<void> updateUserInfo(User user) async {
    userInfo.value = user;
    await storage.write(key: 'user_info', value: jsonEncode(user.toJson()));
  }
  
  /// 添加设备
  Future<void> addDevice(Device device) async {
    devices.add(device);
    await _saveDevices();
    
    // 如果是第一个设备，自动选中
    if (devices.length == 1) {
      selectedDevice.value = device;
    }
  }
  
  /// 移除设备
  Future<void> removeDevice(Device device) async {
    devices.remove(device);
    if (selectedDevice.value == device) {
      selectedDevice.value = devices.isNotEmpty ? devices.first : null;
    }
    await _saveDevices();
  }
  
  /// 选择设备
  void selectDevice(Device device) {
    selectedDevice.value = device;
  }
  
  /// 保存设备列表
  Future<void> _saveDevices() async {
    final devicesJson = jsonEncode(devices.map((d) => d.toJson()).toList());
    await storage.write(key: 'bound_devices', value: devicesJson);
    if (selectedDevice.value != null) {
      await storage.write(key: 'selected_device', value: selectedDevice.value!.deviceId);
    }
  }
  
  /// 加载设备列表
  Future<void> loadDevices() async {
    try {
      final devicesJson = await storage.read(key: 'bound_devices');
      final selectedDeviceId = await storage.read(key: 'selected_device');
      
      if (devicesJson != null && devicesJson.isNotEmpty) {
        final devicesList = jsonDecode(devicesJson) as List;
        devices.value = devicesList.map((d) => Device.fromJson(d as Map<String, dynamic>)).toList();
        
        // 恢复选中的设备
        if (selectedDeviceId != null) {
          final device = devices.firstWhereOrNull((d) => d.deviceId == selectedDeviceId);
          if (device != null) {
            selectedDevice.value = device;
          } else if (devices.isNotEmpty) {
            selectedDevice.value = devices.first;
          }
        } else if (devices.isNotEmpty) {
          selectedDevice.value = devices.first;
        }
      }
    } catch (e) {
      debugPrint('加载设备列表失败: $e');
    }
  }
  
  /// 获取当前选中的设备 ID
  String get currentDeviceId {
    return selectedDevice.value?.deviceId ?? 'esp32_001';
  }

  // 登出方法
  Future<void> logout() async {
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'current_username');
    await storage.delete(key: 'user_info');

    isLoggedIn.value = false;
    token.value = '';
    currentUser.value = '';
    userInfo.value = null;
  }
}