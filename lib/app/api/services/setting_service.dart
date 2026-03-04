import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingService extends GetxService {
  static SettingService get to => Get.find();
  
  final _storage = const FlutterSecureStorage();
  
  // 温度提醒开关
  final _temperatureAlertEnabled = true.obs;
  bool get temperatureAlertEnabled => _temperatureAlertEnabled.value;
  
  // 温度阈值
  final _temperatureThreshold = 15.0.obs;
  double get temperatureThreshold => _temperatureThreshold.value;
  
  // 距离提醒开关
  final _distanceAlertEnabled = true.obs;
  bool get distanceAlertEnabled => _distanceAlertEnabled.value;
  
  // 距离阈值（单位：厘米）
  final _distanceThreshold = 100.0.obs;
  double get distanceThreshold => _distanceThreshold.value;
  
  // 通知类型：dingtalk（钉钉机器人）、bark（Bark提醒）、none（不通知）
  final _notificationType = 'none'.obs;
  String get notificationType => _notificationType.value;
  
  // 通知 URL
  final _notificationUrl = ''.obs;
  String get notificationUrl => _notificationUrl.value;
  
  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }
  
  /// 加载设置
  Future<void> _loadSettings() async {
    try {
      final tempEnabled = await _storage.read(key: 'temperature_alert_enabled');
      final tempThreshold = await _storage.read(key: 'temperature_threshold');
      final distEnabled = await _storage.read(key: 'distance_alert_enabled');
      final distThreshold = await _storage.read(key: 'distance_threshold');
      final notificationType = await _storage.read(key: 'notification_type');
      final notificationUrl = await _storage.read(key: 'notification_url');
      
      if (tempEnabled != null) {
        _temperatureAlertEnabled.value = tempEnabled == 'true';
      }
      if (tempThreshold != null) {
        _temperatureThreshold.value = double.tryParse(tempThreshold) ?? 15.0;
      }
      if (distEnabled != null) {
        _distanceAlertEnabled.value = distEnabled == 'true';
      }
      if (distThreshold != null) {
        _distanceThreshold.value = double.tryParse(distThreshold) ?? 100.0;
      }
      if (notificationType != null) {
        _notificationType.value = notificationType;
      }
      if (notificationUrl != null) {
        _notificationUrl.value = notificationUrl;
      }
    } catch (e) {
      print('加载设置失败: $e');
    }
  }
  
  /// 保存温度提醒开关
  Future<void> setTemperatureAlertEnabled(bool enabled) async {
    try {
      await _storage.write(key: 'temperature_alert_enabled', value: enabled.toString());
      _temperatureAlertEnabled.value = enabled;
    } catch (e) {
      print('保存温度提醒开关失败: $e');
    }
  }
  
  /// 保存温度阈值
  Future<void> setTemperatureThreshold(double threshold) async {
    try {
      await _storage.write(key: 'temperature_threshold', value: threshold.toString());
      _temperatureThreshold.value = threshold;
    } catch (e) {
      print('保存温度阈值失败: $e');
    }
  }
  
  /// 保存距离提醒开关
  Future<void> setDistanceAlertEnabled(bool enabled) async {
    try {
      await _storage.write(key: 'distance_alert_enabled', value: enabled.toString());
      _distanceAlertEnabled.value = enabled;
    } catch (e) {
      print('保存距离提醒开关失败: $e');
    }
  }
  
  /// 保存距离阈值
  Future<void> setDistanceThreshold(double threshold) async {
    try {
      await _storage.write(key: 'distance_threshold', value: threshold.toString());
      _distanceThreshold.value = threshold;
    } catch (e) {
      print('保存距离阈值失败: $e');
    }
  }
  
  /// 保存通知类型
  Future<void> setNotificationType(String type) async {
    try {
      await _storage.write(key: 'notification_type', value: type);
      _notificationType.value = type;
    } catch (e) {
      print('保存通知类型失败: $e');
    }
  }
  
  /// 保存通知 URL
  Future<void> setNotificationUrl(String url) async {
    try {
      await _storage.write(key: 'notification_url', value: url);
      _notificationUrl.value = url;
    } catch (e) {
      print('保存通知 URL 失败: $e');
    }
  }
}