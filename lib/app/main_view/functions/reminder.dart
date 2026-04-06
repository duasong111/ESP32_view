import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../api/endpoints.dart';
import '../../api/services/auth_service.dart';
import '../../api/services/setting_service.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  final SettingService settingService = Get.find<SettingService>();
  
  late double _distanceMin;
  late int _alertSeconds;
  late bool _isActive;
  String _deviceId = '';
  
  @override
  void initState() {
    super.initState();
    _isActive = settingService.distanceAlertEnabled;
    _distanceMin = settingService.distanceThreshold;
    _alertSeconds = 300; // 默认预警间隔 300秒
    _loadDeviceId();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadDeviceId();
  }

  void _loadDeviceId() {
    try {
      final authService = Get.find<AuthService>();
      final deviceId = authService.currentDeviceId;
      if (deviceId.isNotEmpty) {
        setState(() {
          _deviceId = deviceId;
        });
      }
    } catch (e) {
      debugPrint('加载设备信息失败: $e');
    }
  }
  
  @override
  void dispose() {
    // 无需dispose任何controller，因为_deviceId是String类型，不是TextEditingController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TDNavBar(title: '智能提醒'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // 距离阈值设置卡片
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '距离预警设置',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Switch(
                          value: _isActive,
                          onChanged: (value) {
                            setState(() {
                              _isActive = value;
                            });
                            settingService.setDistanceAlertEnabled(value);
                            _uploadDistanceThreshold();
                          },
                          activeColor: TDTheme.of(context).brandColor8,
                        ),
                      ],
                    ),
                    
                    if (_isActive) ...[
                      const SizedBox(height: 20),
                      
                      // 设备编号显示
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Text('当前设备: ', style: TextStyle(fontWeight: FontWeight.w500)),
                            Text(_deviceId.isNotEmpty ? _deviceId : '未绑定设备'),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // 距离最小值
                      _buildThresholdSlider(
                        title: '距离最小值',
                        value: _distanceMin,
                        min: 0,
                        max: 200,
                        unit: 'cm',
                        color: Colors.purple,
                        onChanged: (value) {
                          setState(() {
                            _distanceMin = value;
                          });
                        },
                        onChangeEnd: (value) {
                          settingService.setDistanceThreshold(value);
                          _uploadDistanceThreshold();
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // 预警间隔时间
                      _buildAlertSecondsSlider(),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  /// 构建预警间隔时间滑块
  Widget _buildAlertSecondsSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('预警间隔时间', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            Text(
              '${(_alertSeconds / 60).toStringAsFixed(0)} 分钟',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: _alertSeconds.toDouble(),
          min: 60,
          max: 3600,
          divisions: 59,
          onChanged: (value) {
            setState(() {
              _alertSeconds = value.toInt();
            });
          },
          onChangeEnd: (value) {
            _uploadDistanceThreshold();
          },
          activeColor: Colors.green,
        ),
      ],
    );
  }
  
  /// 构建阈值滑块
  Widget _buildThresholdSlider({
    required String title,
    required double value,
    required double min,
    required double max,
    required String unit,
    required Color color,
    required ValueChanged<double> onChanged,
    required ValueChanged<double> onChangeEnd,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            Text(
              '${value.toStringAsFixed(1)} $unit',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          onChanged: onChanged,
          onChangeEnd: onChangeEnd,
          activeColor: color,
        ),
      ],
    );
  }
  
  /// 上传距离阈值到后端
  Future<void> _uploadDistanceThreshold() async {
    try {
      final authService = Get.find<AuthService>();
      final jwtToken = authService.token.value;
      final deviceId = authService.currentDeviceId;
      
      if (jwtToken.isEmpty) {
        debugPrint('JWT token 为空，无法上传距离阈值');
        return;
      }
      
      if (deviceId.isEmpty) {
        debugPrint('设备ID为空，无法上传距离阈值');
        TDToast.showText('请先绑定设备', context: context);
        return;
      }
      
      final apiUrl = Uri.parse('${Endpoints.baseUrl}${Endpoints.setDistanceThreshold}');
      final response = await http.post(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({
          'device_id': deviceId,
          'distance_min': _distanceMin,
          'alert_interval': _alertSeconds,
          'is_active': _isActive,
        }),
      );
      
      if (response.statusCode == 200) {
        debugPrint('距离阈值上传成功: ${response.body}');
        TDToast.showText('距离阈值已保存', context: context);
      } else {
        debugPrint('距离阈值上传失败: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('上传距离阈值失败: $e');
    }
  }
}