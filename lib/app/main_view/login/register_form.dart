// lib/modules/auth/widgets/register_form.dart
import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import '../../../app/api/services/auth_service.dart';
import 'package:get/get.dart';
import '../../api/client/dio_client.dart';
import '../../api/endpoints.dart';
import 'package:cryptography/cryptography.dart';
import 'package:ed25519_hd_key/ed25519_hd_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:uuid/uuid.dart';

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
  final _storage = const FlutterSecureStorage();
  final _uuid = const Uuid();

  // 全局算法实例
  final _pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 600000, // 2025年推荐值
    bits: 256,
  );
  final _aesGcm = AesGcm.with256bits();

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
      // 1. 生成密钥对
      final seed = List<int>.generate(32, (_) => DateTime.now().microsecond + _.hashCode);
      final master = await ED25519_HD_KEY.getMasterKeyFromSeed(seed);
      // 现在使用的是Ed25519算法生成密钥对-比传统的体积更小，加密型更强
      final privateKey = master.key;
      final publicKeyObj = await ED25519_HD_KEY.getPublicKey(privateKey);
      final privateKeyHex = uint8ListToHex(Uint8List.fromList(privateKey));
      final publicKeyHex = uint8ListToHex(Uint8List.fromList(publicKeyObj));      
      final salt = SecretKeyData.random(length: 16).bytes;
      final iv = SecretKeyData.random(length: 12).bytes; // AES-GCM 推荐 12 字节
      final secretKey = await _pbkdf2.deriveKey(
        secretKey: SecretKey(utf8.encode(password)),
        nonce: salt,
      );
      final secretBox = await _aesGcm.encrypt(
        privateKey,
        secretKey: secretKey,
        nonce: iv,
      );
      final encryptedPrivateKeyBase64 = base64Encode(secretBox.concatenation());
      final ivBase64 = base64Encode(iv);
      final saltBase64 = base64Encode(salt);
      String deviceId = await _storage.read(key: 'device_id') ?? _uuid.v4();
      await _storage.write(key: 'device_id', value: deviceId);
      final response = await DioClient().post(
        Endpoints.registerEndpoint,
        data: {
          "username": username,
          "password": password,
          "public_key": publicKeyHex,
          "device_id": deviceId,
          "encrypted_private_key": encryptedPrivateKeyBase64,
          "encryption_params": jsonEncode({
            "iv": ivBase64,
            "salt": saltBase64,
          }),
          "encryption_method": "password_pbkdf2_aes256gcm",
        },
      );
      if (response.statusCode == 201) {
        final data = response.data;
        await _storage.write(key: 'private_key', value: privateKeyHex);
        await _storage.write(key: 'public_key', value: publicKeyHex);
        await _storage.write(key: 'access_token', value: data['access']);
        await _storage.write(key: 'refresh_token', value: data['refresh']);
        await _storage.write(key: 'current_username', value: username);
        
        final authService = Get.find<AuthService>();
        await authService.setLogin(data['access']);

        TDToast.showText('注册成功，已自动登录', context: context);
        Get.offAllNamed('/home');
      } else {
        final error = response.data['error'] ?? '注册失败';
        TDToast.showText(error, context: context);
      }
    } catch (e) {
      TDToast.showText('网络异常：$e', context: context);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 工具函数
  String uint8ListToHex(Uint8List bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
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