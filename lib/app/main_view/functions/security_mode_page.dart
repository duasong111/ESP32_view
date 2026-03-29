import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../api/endpoints.dart';
import '../../api/services/auth_service.dart';

class SecurityModePage extends StatefulWidget {
  const SecurityModePage({super.key});

  @override
  State<SecurityModePage> createState() => _SecurityModePageState();
}

class _SecurityModePageState extends State<SecurityModePage> {
  final authService = Get.find<AuthService>();
  
  // 安防模式配置
  bool _isActive = false;
  bool _enableOnlineAlert = false;
  int _maxAlertCount = 2;
  int _offlineThreshold = 60;
  int _alertInterval = 100;
  
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  /// 获取配置逻辑
  Future<void> _loadConfig() async {
    try {
      final jwtToken = authService.token.value;
      if (jwtToken.isEmpty) {
        TDToast.showWarning('请先登录', context: context);
        return;
      }

      final url = Uri.parse('${Endpoints.baseUrl}${Endpoints.offlineConfig}');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // 增加对 200 或业务 code 的判断
        if (data['code'] == 200 || data['success'] == true) {
          final config = data['data'] ?? {};
          setState(() {
            _isActive = config['is_active'] ?? false;
            _enableOnlineAlert = config['enable_online_alert'] ?? false;
            _maxAlertCount = config['max_alert_count'] ?? 2;
            _offlineThreshold = config['offline_threshold'] ?? 60;
            _alertInterval = config['alert_interval'] ?? 100;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('加载安防配置失败: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// 保存配置逻辑
  Future<void> _saveConfig() async {
    final jwtToken = authService.token.value;
    if (jwtToken.isEmpty) {
      TDToast.showWarning('请先登录', context: context);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final deviceId = authService.currentDeviceId; // 确保这个值不为空
      final url = Uri.parse('${Endpoints.baseUrl}${Endpoints.offlineConfig}');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({
          'device_id': deviceId,
          'is_active': _isActive,
          'enable_online_alert': _enableOnlineAlert,
          'max_alert_count': _maxAlertCount,
          'offline_threshold': _offlineThreshold,
          'alert_interval': _alertInterval,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        TDToast.showSuccess('配置已同步', context: context);
      } else {
        TDToast.showText('保存失败', context: context);
      }
    } catch (e) {
      TDToast.showText('网络请求异常', context: context);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TDTheme.of(context).grayColor1, // 使用 TDesign 背景色
      appBar: TDNavBar(
        title: '安防模式设置',
        screenAdaptation: true,
        useDefaultBack: true, // 简化返回按钮
        onBack: () => Get.back(),
      ),
      body: _isLoading
          ? const Center(child: TDCircleIndicator(size: 24))
          : SingleChildScrollView( // 使用 SingleChildScrollView 适配小屏幕
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildMainSwitch(),
                  const SizedBox(height: 16),
                  // 使用 AnimatedOpacity 增加置灰动效
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _isActive ? 1.0 : 0.5,
                    child: AbsorbPointer( // 当关闭时禁止交互
                      absorbing: !_isActive,
                      child: _buildConfigCard(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  TDButton(
                    text: '确认并保存',
                    width: double.infinity,
                    size: TDButtonSize.large,
                    type: TDButtonType.fill,
                    theme: TDButtonTheme.primary,
                    disabled: _isSaving,
                    onTap: _saveConfig,
                  ),
                ],
              ),
            ),
    );
  }

  /// 主开关卡片
  Widget _buildMainSwitch() {
    return Container(
      decoration: BoxDecoration(
        color: TDTheme.of(context).whiteColor1,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('设备保护状态', 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(_isActive ? '正在监控设备状态' : '实时监控已关闭',
                style: TextStyle(
                  color: _isActive ? TDTheme.of(context).successColor5 : TDTheme.of(context).fontGyColor3
                )),
            ],
          ),
          TDSwitch(
            isOn: _isActive,
            onChanged: (value) {
              setState(() => _isActive = value);
              return true;
            
            },
          ),
        ],
      ),
    );
  }

  /// 配置参数卡片
  Widget _buildConfigCard() {
    return Container(
      decoration: BoxDecoration(
        color: TDTheme.of(context).whiteColor1,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('详细参数', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          
          // 提醒切换
          _buildItemRow('上线提醒', TDSwitch(
            isOn: _enableOnlineAlert,
            size: TDSwitchSize.small,
            onChanged: (value) {
              setState(() => _enableOnlineAlert = value);
              return true;
            },
          )),
          const Divider(height: 32),
          
          // 滑块部分
          _buildSliderItem(
            label: '最大告警次数',
            value: _maxAlertCount.toDouble(),
            min: 1, max: 10, unit: '次',
            onChanged: (v) => setState(() => _maxAlertCount = v.toInt()),
          ),
          const SizedBox(height: 24),
          
          _buildSliderItem(
            label: '离线判断阈值',
            value: _offlineThreshold.toDouble(),
            min: 10, max: 300, unit: 's',
            onChanged: (v) => setState(() => _offlineThreshold = v.toInt()),
          ),
          const SizedBox(height: 24),
          
          _buildSliderItem(
            label: '告警重复间隔',
            value: _alertInterval.toDouble(),
            min: 30, max: 600, unit: 's',
            onChanged: (v) => setState(() => _alertInterval = v.toInt()),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(String label, Widget trailing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: TDTheme.of(context).fontGyColor1)),
        trailing,
      ],
    );
  }

  Widget _buildSliderItem({
    required String label, 
    required double value, 
    required double min, 
    required double max, 
    required String unit,
    required ValueChanged<double> onChanged
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 14, color: TDTheme.of(context).fontGyColor1)),
            Text('${value.toInt()} $unit', 
              style: TextStyle(color: TDTheme.of(context).brandColor8, fontWeight: FontWeight.bold)),
          ],
        ),
        // 使用原生的 Slider 但配色遵循 TDesign
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: TDTheme.of(context).brandColor8,
            inactiveTrackColor: TDTheme.of(context).brandColor1,
            thumbColor: Colors.white,
            overlayColor: TDTheme.of(context).brandColor8.withOpacity(0.1),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}