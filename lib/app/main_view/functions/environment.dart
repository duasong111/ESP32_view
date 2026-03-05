import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../api/services/environment_service.dart';
import '../../api/services/setting_service.dart';

class EnvironmentPage extends StatefulWidget {
  const EnvironmentPage({super.key});

  @override
  State<EnvironmentPage> createState() => _EnvironmentPageState();
}

class _EnvironmentPageState extends State<EnvironmentPage> {
  final EnvironmentService envService = Get.find<EnvironmentService>();
  final SettingService settingService = Get.find<SettingService>();
  
  late bool _alertEnabled;
  late double _temperatureThreshold;
  late double _humidityThreshold;
  
  @override
  void initState() {
    super.initState();
    _alertEnabled = settingService.temperatureAlertEnabled;
    _temperatureThreshold = settingService.temperatureThreshold;
    _humidityThreshold = 80.0; // 默认湿度阈值 80%
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TDNavBar(title: '环境监测'),
      body: Obx(() {
        final temperature = envService.temperature;
        final humidity = envService.humidity;
        final hasData = envService.hasData;
        
        // 检查是否超过阈值
        final isTempAlert = hasData && _alertEnabled && temperature > _temperatureThreshold;
        final isHumidityAlert = hasData && _alertEnabled && humidity > _humidityThreshold;
        
        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // 实时数据卡片
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildDataItem(
                            icon: Icons.thermostat_outlined,
                            iconColor: isTempAlert ? Colors.red : Colors.orange,
                            value: hasData ? '${temperature.toStringAsFixed(1)}°C' : '--.-°C',
                            label: '温度',
                            isAlert: isTempAlert,
                          ),
                          _buildDataItem(
                            icon: Icons.water_drop_outlined,
                            iconColor: isHumidityAlert ? Colors.red : Colors.blue,
                            value: hasData ? '${humidity.toStringAsFixed(0)}%' : '--%',
                            label: '湿度',
                            isAlert: isHumidityAlert,
                          ),
                        ],
                      ),
                      if (envService.lastUpdateTime != null) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          '更新时间: ${_formatTime(envService.lastUpdateTime!)}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              // 预警状态提示
              if (isTempAlert || isHumidityAlert)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isTempAlert && isHumidityAlert
                              ? '温度和湿度均超过阈值！'
                              : isTempAlert
                                  ? '温度超过阈值 ${_temperatureThreshold.toStringAsFixed(1)}°C'
                                  : '湿度超过阈值 ${_humidityThreshold.toStringAsFixed(0)}%',
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 20),
              
              // 预警控制卡片
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
                            '预警设置',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Switch(
                            value: _alertEnabled,
                            onChanged: (value) {
                              setState(() {
                                _alertEnabled = value;
                              });
                              settingService.setTemperatureAlertEnabled(value);
                            },
                            activeColor: TDTheme.of(context).brandColor8,
                          ),
                        ],
                      ),
                      
                      if (_alertEnabled) ...[
                        const SizedBox(height: 20),
                        
                        // 温度阈值
                        _buildThresholdSlider(
                          title: '温度阈值',
                          value: _temperatureThreshold,
                          min: 0,
                          max: 50,
                          unit: '°C',
                          color: Colors.orange,
                          onChanged: (value) {
                            setState(() {
                              _temperatureThreshold = value;
                            });
                          },
                          onChangeEnd: (value) {
                            settingService.setTemperatureThreshold(value);
                          },
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // 湿度阈值
                        _buildThresholdSlider(
                          title: '湿度阈值',
                          value: _humidityThreshold,
                          min: 0,
                          max: 100,
                          unit: '%',
                          color: Colors.blue,
                          onChanged: (value) {
                            setState(() {
                              _humidityThreshold = value;
                            });
                          },
                          onChangeEnd: (value) {
                            // 保存湿度阈值（如果需要持久化，需要在 SettingService 中添加）
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              if (!hasData)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('等待数据中...', style: TextStyle(color: Colors.grey)),
                ),
            ],
          ),
        );
      }),
    );
  }
  
  Widget _buildDataItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    bool isAlert = false,
  }) {
    return Column(
      children: [
        Icon(icon, size: 48, color: iconColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: isAlert ? Colors.red : null,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
  
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
  
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }
}