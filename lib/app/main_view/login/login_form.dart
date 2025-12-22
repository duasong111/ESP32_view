import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:get/get.dart';
import 'package:cryptography/cryptography.dart';
import '../../api/client/dio_client.dart';
import '../../api/endpoints.dart';
import '../../api/services/auth_service.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _agreeProtocol = true; // 默认勾选
  final _storage = FlutterSecureStorage();
  final _uuid = Uuid();

  Future<void> _login() async {
    if (!_agreeProtocol) {
      TDToast.showText('请阅读并同意用户协议和隐私政策', context: context);
      return;
    }
    if (_accountController.text.isEmpty || _passwordController.text.isEmpty) {
      TDToast.showText('请填写账号和密码', context: context);
      return;
    }
    // 读取或生成设备ID
    String deviceId = await _storage.read(key: 'device_id') ?? _uuid.v4();
    await _storage.write(key: 'device_id', value: deviceId);
    final response = await DioClient().post(

        Endpoints.loginEndpoint,
        data: {
          'username': _accountController.text,
          'password': _passwordController.text,
          'device_id': deviceId,
        },
      );
    if (response.statusCode == 200) {
      try {
        // 登录成功，保存token等操作
        final authService = Get.find<AuthService>();
        final accessToken = response.data['access'];
        final refreshToken = response.data['refresh'];
        
        // 从响应中提取用户信息
        String username = _accountController.text;
        String publicKey = '';
        String privateKey = '';
        
        // 尝试从不同位置提取私钥 - 检查更多可能的字段名
        List<String> possiblePrivateKeyFields = [
          'private_key',
          'privateKey',
          'private-key',
          'user_private_key',
          'userPrivateKey',
          'rsa_private_key',
          'rsaPrivateKey'
        ];
        

        
        // 尝试从user字段的所有可能字段名中提取
        if (response.data.containsKey('user') && response.data['user'] is Map) {
          Map userMap = response.data['user'] as Map;
          username = userMap['username'] ?? userMap['name'] ?? _accountController.text;
          publicKey = userMap['public_key'] ?? userMap['publicKey'] ?? '';
          
          // 尝试从user字段的所有可能私钥字段名中提取
          for (String fieldName in possiblePrivateKeyFields) {
            if (userMap.containsKey(fieldName)) {
              privateKey = userMap[fieldName] ?? '';
              break;
            }
          }
        }
        
        // 如果user字段中没有找到私钥，尝试从响应顶层提取
        if (privateKey.isEmpty) {
          for (String fieldName in possiblePrivateKeyFields) {
            if (response.data.containsKey(fieldName)) {
              privateKey = response.data[fieldName] ?? '';
              break;
            }
          }
        }
        
        // 提取公钥（如果还没提取到）
        if (publicKey.isEmpty && response.data.containsKey('user') && response.data['user'] is Map) {
          Map userMap = response.data['user'] as Map;
          publicKey = userMap['public_key'] ?? userMap['publicKey'] ?? '';
        }
        if (publicKey.isEmpty && response.data.containsKey('public_key')) {
          publicKey = response.data['public_key'] ?? response.data['publicKey'] ?? '';
        }
        
        // 检查user字段（如果存在）
        if (response.data.containsKey('user')) {
          if (response.data['user'] is Map) {
            Map userMap = response.data['user'] as Map;
            
          }
        }
        if (accessToken != null && accessToken is String) {
          // 先保存基本登录信息
          await authService.setLogin(
            accessToken, 
            username: username, 
            publicKey: publicKey, 
            privateKey: privateKey
          );
          
          // 使用登录密码解密私钥
          await _decryptPrivateKey();
          
          TDToast.showText('登录成功！', context: context);
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          TDToast.showText('登录失败：服务器返回数据异常', context: context);
          return;
        }
      } catch (e, stackTrace) {
        TDToast.showText('登录成功但处理数据失败', context: context);
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      // 登录失败，提示用户
      TDToast.showText('登录失败，请检查账号密码', context: context);
    }
    // TDToast.showText('登录成功！', context: context);
    // Navigator.pushReplacementNamed(context, '/home');
  }

  // 显示协议弹窗
  void _showProtocol(String title, String content) {
    Navigator.of(context).push(
      TDSlidePopupRoute(
        slideTransitionFrom: SlideTransitionFrom.bottom,
        // barrierDismissible: false,
        builder: (context) {
          return TDPopupBottomConfirmPanel(
            title: title,
            // showAction: false, // 不显示底部按钮
            child: Container(
              padding: const EdgeInsets.all(20),
              height: 400,
              child: SingleChildScrollView(
                child: Text(
                  content,
                  style: const TextStyle(fontSize: 14, height: 1.8),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 解密用户的私钥和公钥
  Future<void> _decryptPrivateKey() async {
    
    try {
      // 调用解密接口
     final response = await DioClient().get(
        Endpoints.encryptPrivateKeyEndpoint,
      );
      print('查看解密获取的内容...$response');
      if (response.statusCode == 200 && response.data != null) {
        TDToast.showText('私钥解密成功', context: context);
      } else {
        TDToast.showText('私钥解密失败', context: context);
      }
    } catch (e) {
      print('私钥解密异常: $e');
      TDToast.showText('私钥解密异常', context: context);
    }
  }

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // 用户名输入
          TDInput(
            controller: _accountController,
            hintText: '请输入用户名 ',
            leftIcon: const Icon(TDIcons.bad_laugh),
            backgroundColor: Colors.grey[50],
          ),
          const SizedBox(height: 16),
          TDInput(
            controller: _passwordController,
            hintText: '请输入密码',
            leftIcon: const Icon(TDIcons.user_password),
            obscureText: true,
            backgroundColor: Colors.grey[50],
          ),
          const SizedBox(height: 32),
          TDButton(
            text: '登录',
            size: TDButtonSize.large,
            isBlock: true,
            theme: _agreeProtocol
                ? TDButtonTheme.primary
                : TDButtonTheme.defaultTheme,
            onTap: _agreeProtocol ? _login : null, // 不勾选时禁用点击
          ),
          const SizedBox(height: 24),
          // 协议勾选区域
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TDCheckbox(
                checked: _agreeProtocol,
                onCheckBoxChanged: (bool? v) {
                  setState(() {
                    _agreeProtocol = v ?? false;
                  });
                },
              ),
              const SizedBox(width: 8),
              const Text('我已阅读并同意'),
              GestureDetector(
                onTap: () => _showProtocol('用户协议', '''
                《ArrivalAreaChat 用户协议》
                欢迎使用 ArrivalAreaChat！本协议是您与 ArrivalAreaChat（以下简称“我们”）之间关于使用本软件服务的法律协议。
                1. 服务内容
                  我们提供即时通讯、文件传输、群聊等功能。
                2. 用户权利与义务
                  您应保证注册信息真实有效，不得利用本软件从事违法活动。
                3. 隐私保护
                  我们承诺保护您的个人信息安全，除法律要求外不会向第三方泄露。
                4. 协议更新
                  我们有权适时更新本协议，更新后将继续为您提供服务。
                继续使用即视为您已阅读并同意本协议。
                  '''),
                child: const Text(
                  '《用户协议》',
                  style: TextStyle(color: Color(0xFF07C160)),
                ),
              ),
              const Text('和'),

              GestureDetector(
                onTap: () => _showProtocol('隐私政策', '''
                《ArrivalAreaChat 隐私政策》
                我们非常重视您的隐私保护。本政策说明我们如何收集、使用和保护您的个人信息。
                1. 我们收集的信息
                  - 您主动提供的：手机号、昵称、头像等
                  - 自动收集：设备信息、日志信息
                2. 信息使用目的
                  - 提供聊天服务
                  - 改进产品体验
                  - 保障账户安全
                3. 信息共享
                  除以下情况外，我们不会向第三方共享您的个人信息：
                  - 获得您明确同意
                  - 响应法律法规要求
                  - 关联公司间共享（仅限必要范围）
                您使用本软件即表示您已阅读并同意本隐私政策。
                  '''),
                child: const Text(
                  '《隐私政策》',
                  style: TextStyle(color: Color(0xFF07C160)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}