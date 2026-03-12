import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../api/endpoints.dart';
import '../../api/services/auth_service.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  final AuthService authService = Get.find<AuthService>();
  
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _avatarController = TextEditingController();
  
  String _originalEmail = '';
  String _originalPhone = '';
  String _originalAddress = '';
  String _originalEducation = '';
  String _originalAvatar = '';
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _educationController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  void _loadUserInfoFromService() {
    final user = authService.userInfo.value;
    if (user != null) {
      _usernameController.text = user.username;
      _emailController.text = user.email ?? '';
      _addressController.text = user.address ?? '';
      _phoneController.text = user.phone ?? '';
      _educationController.text = user.education ?? '';
      _avatarController.text = user.avatar ?? '';
      
      _originalEmail = user.email ?? '';
      _originalPhone = user.phone ?? '';
      _originalAddress = user.address ?? '';
      _originalEducation = user.education ?? '';
      _originalAvatar = user.avatar ?? '';
    }
  }
  
  void _resetToOriginal() {
    _emailController.text = _originalEmail;
    _phoneController.text = _originalPhone;
    _addressController.text = _originalAddress;
    _educationController.text = _originalEducation;
    _avatarController.text = _originalAvatar;
  }

  Future<void> _fetchUserInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final jwtToken = authService.token.value;
      
      if (jwtToken.isEmpty) {
        debugPrint('JWT token 为空');
        return;
      }

      final apiUrl = Uri.parse('${Endpoints.baseUrl}${Endpoints.getUserInfo}');
      final response = await http.get(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final userData = responseData['data'] as Map<String, dynamic>;
          final user = User.fromJson(userData);
          await authService.updateUserInfo(user);
          _loadUserInfoFromService();
        } else {
          debugPrint('获取用户信息失败: ${responseData['message']}');
          TDToast.showText('获取用户信息失败', context: context);
        }
      } else {
        debugPrint('获取用户信息失败: ${response.statusCode} - ${response.body}');
        TDToast.showText('获取用户信息失败', context: context);
      }
    } catch (e) {
      debugPrint('获取用户信息失败: $e');
      TDToast.showText('获取用户信息失败', context: context);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final jwtToken = authService.token.value;
      
      if (jwtToken.isEmpty) {
        debugPrint('JWT token 为空');
        return;
      }

      final apiUrl = Uri.parse('${Endpoints.baseUrl}${Endpoints.updateUserInfo}');
      final response = await http.put(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'education': _educationController.text.trim(),
          'avatar': _avatarController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          await _fetchUserInfo();
          TDToast.showText('用户信息已更新', context: context);
          Get.back();
        } else {
          debugPrint('更新用户信息失败: ${responseData['message']}');
          TDToast.showText('更新用户信息失败', context: context);
        }
      } else {
        debugPrint('更新用户信息失败: ${response.statusCode} - ${response.body}');
        TDToast.showText('更新用户信息失败', context: context);
      }
    } catch (e) {
      debugPrint('更新用户信息失败: $e');
      TDToast.showText('更新用户信息失败', context: context);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TDNavBar(title: '修改资料'),
      body: Obx(() {
        final user = authService.userInfo.value;
        return _isLoading
            ? const Center(child: TDLoading(size: TDLoadingSize.large))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 头像区域
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            TDAvatar(
                              size: TDAvatarSize.large,
                              type: TDAvatarType.normal,
                              defaultUrl: _avatarController.text.isNotEmpty 
                                  ? _avatarController.text 
                                  : 'assets/images/avatar.png',
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _avatarController,
                              decoration: const InputDecoration(
                                labelText: '头像 URL',
                                hintText: '请输入头像链接',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // 用户信息表单
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '基本信息',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            _buildInfoField(
                              label: '用户名',
                              controller: _usernameController,
                              enabled: false,
                              icon: Icons.person,
                            ),
                            
                            const SizedBox(height: 16),
                            
                            _buildInfoField(
                              label: '邮箱',
                              controller: _emailController,
                              enabled: true,
                              icon: Icons.email,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            
                            const SizedBox(height: 16),
                            
                            _buildInfoField(
                              label: '手机号',
                              controller: _phoneController,
                              enabled: true,
                              icon: Icons.phone,
                              keyboardType: TextInputType.phone,
                            ),
                            
                            const SizedBox(height: 16),
                            
                            _buildInfoField(
                              label: '地址',
                              controller: _addressController,
                              enabled: true,
                              icon: Icons.location_on,
                            ),
                            
                            const SizedBox(height: 16),
                            
                            _buildInfoField(
                              label: '教育背景',
                              controller: _educationController,
                              enabled: true,
                              icon: Icons.school,
                            ),
                            
                            if (user != null) ...[
                              const SizedBox(height: 20),
                              const TDDivider(),
                              const SizedBox(height: 12),
                              Text(
                                '注册时间: ${_formatDateTime(user.createdAt)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // 提交和取消按钮
                    Row(
                      children: [
                        Expanded(
                          child: TDButton(
                            text: '取消',
                            theme: TDButtonTheme.light,
                            onTap: () {
                              _resetToOriginal();
                              Get.back();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TDButton(
                            text: '提交',
                            theme: TDButtonTheme.primary,
                            onTap: _updateUserInfo,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
      }),
    );
  }

  Widget _buildInfoField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TDInput(
      controller: controller,
      hintText: label,
      leftIcon: Icon(icon),
      type: TDInputType.normal,
      size: TDInputSize.large,
      readOnly: !enabled,
      inputType: keyboardType,
      backgroundColor: enabled ? null : TDTheme.of(context).grayColor1,
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '未知';
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }
}