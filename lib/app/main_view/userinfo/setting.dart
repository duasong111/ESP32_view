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
  late String _notificationType;
  late String _notificationUrl;
  final TextEditingController _urlController = TextEditingController();
  bool _isNotificationExpanded = false;

  @override
  void initState() {
    super.initState();
    _temperatureAlertEnabled = _settingService.temperatureAlertEnabled;
    _temperatureThreshold = _settingService.temperatureThreshold;
    _distanceAlertEnabled = _settingService.distanceAlertEnabled;
    _distanceThreshold = _settingService.distanceThreshold;
    _notificationType = _settingService.notificationType;
    _notificationUrl = _settingService.notificationUrl;
    _urlController.text = _notificationUrl;
    _isNotificationExpanded = _notificationType != 'none';
  }
  
  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
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
          
          // 自定义通知设置
          _buildSectionHeader('自定义通知'),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: const Text(
                    '通知设置',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    _getNotificationSubtitle(),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  leading: Icon(
                    Icons.notifications_active_outlined,
                    color: TDTheme.of(context).brandColor8,
                  ),
                  trailing: Icon(
                    _isNotificationExpanded 
                        ? Icons.expand_less 
                        : Icons.expand_more,
                  ),
                  onTap: () {
                    setState(() {
                      _isNotificationExpanded = !_isNotificationExpanded;
                    });
                  },
                ),
                if (_isNotificationExpanded) ...[
                  const TDDivider(),
                  _buildRadioTile(
                    title: '钉钉机器人',
                    subtitle: '通过钉钉机器人发送通知',
                    value: 'dingtalk',
                    groupValue: _notificationType,
                    onChanged: (value) {
                      setState(() {
                        _notificationType = value!;
                        _notificationUrl = _settingService.notificationUrl;
                        _urlController.text = _notificationUrl;
                      });
                      _settingService.setNotificationType(value!);
                    },
                  ),
                  const TDDivider(),
                  _buildRadioTile(
                    title: 'Bark 提醒',
                    subtitle: '通过 Bark 推送通知',
                    value: 'bark',
                    groupValue: _notificationType,
                    onChanged: (value) {
                      setState(() {
                        _notificationType = value!;
                        _notificationUrl = _settingService.notificationUrl;
                        _urlController.text = _notificationUrl;
                      });
                      _settingService.setNotificationType(value!);
                    },
                  ),
                  const TDDivider(),
                  _buildRadioTile(
                    title: '不通知',
                    subtitle: '关闭自定义通知',
                    value: 'none',
                    groupValue: _notificationType,
                    onChanged: (value) {
                      setState(() {
                        _notificationType = value!;
                      });
                      _settingService.setNotificationType(value!);
                    },
                  ),
                  if (_notificationType != 'none') ...[
                    const TDDivider(),
                    _buildUrlInput(),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _getNotificationSubtitle() {
    switch (_notificationType) {
      case 'dingtalk':
        return '已启用钉钉机器人';
      case 'bark':
        return '已启用 Bark 提醒';
      default:
        return '未启用自定义通知';
    }
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
  
  Widget _buildRadioTile({
    required String title,
    required String subtitle,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    return RadioListTile<String>(
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: TDTheme.of(context).brandColor8,
    );
  }
  
  Widget _buildUrlInput() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _notificationType == 'dingtalk' ? '钉钉机器人 Webhook URL' : 'Bark 推送 URL',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _urlController,
            autofocus: false,
            decoration: InputDecoration(
              hintText: _notificationType == 'dingtalk' 
                  ? 'https://oapi.dingtalk.com/robot/send?access_token=...'
                  : 'https://api.day.app/YOUR_KEY/',
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: (value) {
              _notificationUrl = value;
              _settingService.setNotificationUrl(value);
            },
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 8),
          Text(
            _notificationType == 'dingtalk' 
                ? '请在钉钉群设置中获取机器人 Webhook 地址'
                : '请在 Bark 应用中获取推送 URL',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}