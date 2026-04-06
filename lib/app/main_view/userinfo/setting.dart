import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../api/endpoints.dart';
import '../../api/services/auth_service.dart';
import '../../api/services/setting_service.dart';

class SettingView extends StatefulWidget {
  const SettingView({super.key});

  @override
  State<SettingView> createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> {
  final SettingService _settingService = Get.find<SettingService>();
  
  // 状态变量
  late bool _temperatureAlertEnabled;
  late double _temperatureThreshold;
  late String _notificationType;
  late String _notificationUrl;
  
  final TextEditingController _urlController = TextEditingController();
  bool _isNotificationExpanded = false;
  
  // 设备绑定 Controller (建议在弹窗时初始化，这里为了保持逻辑延续放在 state)
  final TextEditingController _deviceIdController = TextEditingController(text: 'esp32_001');
  final TextEditingController _activationCodeController = TextEditingController();
  final TextEditingController _deviceNameController = TextEditingController(text: 'esp32_001');

  // 防抖计时器
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _temperatureAlertEnabled = _settingService.temperatureAlertEnabled;
    _temperatureThreshold = _settingService.temperatureThreshold;
    _notificationType = _settingService.notificationType;
    _notificationUrl = _settingService.notificationUrl;
    _urlController.text = _notificationUrl;
    _isNotificationExpanded = _notificationType != 'none';
  }
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    _urlController.dispose();
    _deviceIdController.dispose();
    _activationCodeController.dispose();
    _deviceNameController.dispose();
    super.dispose();
  }

  // --- 逻辑处理方法 ---

  /// 带有防抖功能的 URL 保存
  void _onUrlChanged(String value) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      _notificationUrl = value;
      _settingService.setNotificationUrl(value);
      
      // 如果是 Bark 且 URL 有效，尝试同步 Token
      if (_notificationType == 'bark' && value.contains('http')) {
        _sendBarkToken(value);
      }
    });
  }

  /// 发送 Bark Token 到后端
  Future<void> _sendBarkToken(String url) async {
    try {
      final uri = Uri.tryParse(url);
      if (uri == null || uri.pathSegments.isEmpty) return;
      
      final token = uri.pathSegments.first;
      final authService = Get.find<AuthService>();
      final jwtToken = authService.token.value;
      
      if (jwtToken.isEmpty) return;

      final apiUrl = Uri.parse('${Endpoints.baseUrl}${Endpoints.addBarkToken}');
      final response = await http.post(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({
          'token': token,
          'device': Platform.isIOS ? 'iPhone' : 'Android',
        }),
      );
      
      // 异步检查 mounted
      if (!mounted) return;

      if (response.statusCode == 200) {
        TDToast.showText('Bark 配置已同步', context: context);
      }
    } catch (e) {
      debugPrint('Bark Token Sync Error: $e');
    }
  }

  /// 执行设备绑定
  /// 绑定设备（带详细日志调试版）
  Future<void> _bindDevice() async {
    final deviceId = _deviceIdController.text.trim();
    final activationCode = _activationCodeController.text.trim();
    final deviceName = _deviceNameController.text.trim();
    
    if (deviceId.isEmpty || activationCode.isEmpty || deviceName.isEmpty) {
      TDToast.showWarning('请填写完整信息', context: context);
      return;
    }

    TDToast.showLoading(context: context);

    try {
      final authService = Get.find<AuthService>();
      final String jwtToken = authService.token.value;
      final String fullUrl = '${Endpoints.baseUrl}${Endpoints.deviceBind}';
      
      // --- 关键修改：构建 Headers 并打印日志 ---
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      };

      // 打印详细日志到控制台
      debugPrint('==== [HTTP Request Debug] ====');
      debugPrint('URL: $fullUrl');
      debugPrint('Headers: ${jsonEncode(headers)}'); // 这里会完整显示你的 Token
      debugPrint('Body: ${jsonEncode({
        'device_id': deviceId,
        'activation_code': activationCode,
        'device_name': deviceName,
      })}');
      debugPrint('==============================');

      final response = await http.post(
        Uri.parse(fullUrl),
        headers: headers,
        body: jsonEncode({
          'device_id': deviceId,
          'activation_code': activationCode,
          'device_name': deviceName,
        }),
      );

      // 打印响应日志
      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (!mounted) return;
      TDToast.dismissLoading(); // 手动关闭 Loading

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        if (res['code'] == 200) {
          final data = res['data'];
          // 将设备添加到 AuthService
          final device = Device(
            deviceId: data['device_id'] as String,
            deviceName: data['device_name'] as String,
            activationCode: activationCode,
            boundAt: data['bound_at'] != null ? DateTime.parse(data['bound_at'] as String) : DateTime.now(),
          );
          await authService.addDevice(device);
          
          Get.back();
          TDToast.showSuccess('设备绑定成功', context: context);
        } else {
          TDToast.showText(res['message'] ?? '绑定失败', context: context);
        }
      } else if (response.statusCode == 401) {
        TDToast.showWarning('登录失效，请重新登录', context: context);
      } else {
        TDToast.showText('服务器错误: ${response.statusCode}', context: context);
      }
    } catch (e) {
      debugPrint('Request Exception: $e');
      if (mounted) {
        TDToast.dismissLoading();
        TDToast.showText('网络连接异常', context: context);
      }
    }
  }

  // --- UI 构建方法 ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TDTheme.of(context).grayColor1,
      appBar: const TDNavBar(title: '设置'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('温度提醒'),
          _buildSettingCard(
            children: [
              _buildSwitchTile(
                title: '启用温度提醒',
                subtitle: '超出阈值时发送通知',
                value: _temperatureAlertEnabled,
                onChanged: (value) {
                  setState(() => _temperatureAlertEnabled = value);
                  _settingService.setTemperatureAlertEnabled(value);
                },
              ),
              if (_temperatureAlertEnabled) ...[
                const TDDivider(),
                _buildSliderTile(
                  title: '温度阈值',
                  value: _temperatureThreshold,
                  min: 0,
                  max: 50,
                  unit: '℃',
                  onChanged: (value) => setState(() => _temperatureThreshold = value),
                  onChangeEnd: (value) => _settingService.setTemperatureThreshold(value),
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 24),
          
          _buildSectionHeader('自定义通知'),
          _buildSettingCard(
            children: [
              ListTile(
                leading: Icon(Icons.notifications_active_outlined, color: TDTheme.of(context).brandColor8),
                title: const Text('通知方式', style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(_getNotificationSubtitle()),
                trailing: Icon(_isNotificationExpanded ? Icons.expand_less : Icons.expand_more),
                onTap: () => setState(() => _isNotificationExpanded = !_isNotificationExpanded),
              ),
              if (_isNotificationExpanded) ...[
                const TDDivider(),
                _buildRadioTile('钉钉机器人', 'dingtalk'),
                const TDDivider(),
                _buildRadioTile('Bark 提醒', 'bark'),
                const TDDivider(),
                _buildRadioTile('不通知', 'none'),
                if (_notificationType != 'none') _buildUrlInput(),
              ],
            ],
          ),
          
          const SizedBox(height: 24),
          
          _buildSectionHeader('硬件管理'),
          _buildSettingCard(
            children: [
              ListTile(
                leading: Icon(Icons.link, color: TDTheme.of(context).brandColor8),
                title: const Text('绑定新设备'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showDeviceBindDialog,
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSettingCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged}) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: value,
      onChanged: onChanged,
      activeColor: TDTheme.of(context).brandColor8,
    );
  }

  Widget _buildSliderTile({required String title, required double value, required double min, required double max, required String unit, required ValueChanged<double> onChanged, required ValueChanged<double> onChangeEnd}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(title), Text('${value.toStringAsFixed(1)} $unit', style: TextStyle(color: TDTheme.of(context).brandColor8, fontWeight: FontWeight.bold))],
          ),
          Slider(value: value, min: min, max: max, divisions: max.toInt(), onChanged: onChanged, onChangeEnd: onChangeEnd, activeColor: TDTheme.of(context).brandColor8),
        ],
      ),
    );
  }

  Widget _buildRadioTile(String title, String value) {
    return RadioListTile<String>(
      title: Text(title),
      value: value,
      groupValue: _notificationType,
      activeColor: TDTheme.of(context).brandColor8,
      onChanged: (val) {
        if (val == null) return;
        setState(() {
          _notificationType = val;
          _urlController.text = _settingService.notificationUrl;
        });
        _settingService.setNotificationType(val);
      },
    );
  }

  Widget _buildUrlInput() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _urlController,
        decoration: InputDecoration(
          labelText: _notificationType == 'dingtalk' ? 'Webhook URL' : 'Bark URL',
          hintText: '请输入完整的 URL 地址',
          border: const OutlineInputBorder(),
        ),
        onChanged: _onUrlChanged,
      ),
    );
  }

  String _getNotificationSubtitle() {
    if (_notificationType == 'dingtalk') return '钉钉机器人';
    if (_notificationType == 'bark') return 'Bark 推送';
    return '已禁用';
  }

  void _showDeviceBindDialog() {
    Get.defaultDialog(
      title: '设备绑定',
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            TextField(controller: _deviceIdController, decoration: const InputDecoration(labelText: '设备 ID')),
            TextField(controller: _activationCodeController, decoration: const InputDecoration(labelText: '激活码')),
            TextField(controller: _deviceNameController, decoration: const InputDecoration(labelText: '备注名称')),
          ],
        ),
      ),
      textConfirm: '开始绑定',
      textCancel: '取消',
      confirmTextColor: Colors.white,
      buttonColor: TDTheme.of(context).brandColor8,
      onConfirm: _bindDevice,
    );
  }
}