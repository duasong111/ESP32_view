// lib/modules/auth/widgets/register_form.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../../app/api/services/auth_service.dart';
import '../../api/client/dio_client.dart';
import '../../api/endpoints.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _register() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (username.isEmpty || password.isEmpty) {
      TDToast.showText('请填写完整信息', context: context);
      return;
    }
    if (password != confirmPassword) {
      TDToast.showText('两次密码不一致', context: context);
      return;
    }
    if (password.length < 8) {
      TDToast.showText('密码至少8位', context: context);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 打印请求信息
      print('=== 注册请求 ===');
      print('URL: ${Endpoints.baseUrl}${Endpoints.register}');
      print('请求数据: {"username": "$username", "password": "$password"}');
      
      // 发送注册请求
      final response = await DioClient().post(
        Endpoints.register,
        data: {
          "username": username,
          "password": password,
        },
      );
      
      // 打印响应信息
      print('=== 注册响应 ===');
      print('状态码: ${response.statusCode}');
      print('响应数据: ${response.data}');

      if (response.statusCode == 201) {
        final data = response.data;
        print('注册响应: $data');
        
        // 检查响应是否包含data字段
        if (!data.containsKey('data') || data['data'] == null) {
          TDToast.showText('注册失败：响应格式错误', context: context);
          return;
        }
        
        final dataContent = data['data'];
        final String? accessToken = dataContent['token'];

        if (accessToken == null || accessToken.isEmpty) {
          TDToast.showText('注册失败：未返回访问令牌', context: context);
          return;
        }

        // 更新 AuthService
        final authService = Get.find<AuthService>();
        await authService.setLogin(
          accessToken,
          username: username,
        );

        TDToast.showText('注册成功，已自动登录', context: context);
        Get.offAllNamed('/home');
      } else {
        final error = response.data['error'] ?? '注册失败';
        TDToast.showText(error, context: context);
      }
    } catch (e, stack) {
      print('注册异常: $e');
      print(stack);
      TDToast.showText('注册失败：网络错误', context: context);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const SizedBox(height: 40),
          TDInput(
            controller: _usernameController,
            hintText: '请输入用户名',
            leftIcon: const Icon(TDIcons.paste_filled),
            backgroundColor: Colors.grey[50],
          ),
          const SizedBox(height: 16),
          TDInput(
            controller: _passwordController,
            hintText: '设置密码（至少8位）',
            obscureText: true,
            leftIcon: const Icon(TDIcons.verified),
            backgroundColor: Colors.grey[50],
          ),
          const SizedBox(height: 16),
          TDInput(
            controller: _confirmPasswordController,
            hintText: '确认密码',
            obscureText: true,
            leftIcon: const Icon(TDIcons.verified),
            backgroundColor: Colors.grey[50],
          ),
          const SizedBox(height: 32),
          TDButton(
            text: _isLoading ? '注册中...' : '注册并登录',
            size: TDButtonSize.large,
            isBlock: true,
            theme: TDButtonTheme.primary,
            onTap: _isLoading ? null : _register,
          ),
        ],
      ),
    );
  }
}