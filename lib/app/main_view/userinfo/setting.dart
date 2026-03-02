import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../api/services/setting_service.dart';

class SettingView extends StatefulWidget {
  const SettingView({super.key});

  @override
  State<SettingView> createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> {
  final SettingService _settingService = Get.find<SettingService>();
  
  late bool _temperatureAlertEnabled;
  late double _temperatureThreshold;
  late bool _distanceAlertEnabled;
  late double _distanceThreshold;

  @override
  void initState() {
    super.initState();
    _temperatureAlertEnabled = _settingService.temperatureAlertEnabled;
    _temperatureThreshold = _settingService.temperatureThreshold;
    _distanceAlertEnabled = _settingService.distanceAlertEnabled;
    _distanceThreshold = _settingService.distanceThreshold;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TDNavBar(
        title: '设置',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 温度提醒设置
          _buildSectionHeader('温度提醒'),
          _buildSettingCard(
            children: [
              _buildSwitchTile(
                title: '启用温度提醒',
                subtitle: '当温度超过阈值时显示提醒消息',
                value: _temperatureAlertEnabled,
                onChanged: (value) {
                  setState(() {
                    _temperatureAlertEnabled = value;
                  });
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
                  divisions: 50,
                  unit: '℃',
                  onChanged: (value) {
                    setState(() {
                      _temperatureThreshold = value;
                    });
                  },
                  onChangeEnd: (value) {
                    _settingService.setTemperatureThreshold(value);
                  },
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 24),
          
          // 距离提醒设置
          _buildSectionHeader('距离提醒'),
          _buildSettingCard(
            children: [
              _buildSwitchTile(
                title: '启用距离提醒',
                subtitle: '当距离小于阈值时显示提醒消息',
                value: _distanceAlertEnabled,
                onChanged: (value) {
                  setState(() {
                    _distanceAlertEnabled = value;
                  });
                  _settingService.setDistanceAlertEnabled(value);
                },
              ),
              if (_distanceAlertEnabled) ...[
                const TDDivider(),
                _buildSliderTile(
                  title: '距离阈值',
                  value: _distanceThreshold,
                  min: 10,
                  max: 500,
                  divisions: 49,
                  unit: 'cm',
                  onChanged: (value) {
                    setState(() {
                      _distanceThreshold = value;
                    });
                  },
                  onChangeEnd: (value) {
                    _settingService.setDistanceThreshold(value);
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildSettingCard({required List<Widget> children}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: children,
      ),
    );
  }
  
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: TDTheme.of(context).brandColor8,
    );
  }
  
  Widget _buildSliderTile({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String unit,
    required ValueChanged<double> onChanged,
    required ValueChanged<double> onChangeEnd,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              Text(
                '${value.toStringAsFixed(1)} $unit',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
            activeColor: TDTheme.of(context).brandColor8,
          ),
        ],
      ),
    );
  }
}