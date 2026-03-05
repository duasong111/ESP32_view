import 'package:get/get.dart';

class EnvironmentService extends GetxService {
  static EnvironmentService get to => Get.find();
  
  // 温度数据
  final RxDouble _temperature = 0.0.obs;
  double get temperature => _temperature.value;
  
  // 湿度数据
  final RxDouble _humidity = 0.0.obs;
  double get humidity => _humidity.value;
  
  // 时间数据
  final Rx<DateTime?> _lastUpdateTime = Rx<DateTime?>(null);
  DateTime? get lastUpdateTime => _lastUpdateTime.value;
  
  // 是否有数据
  final RxBool _hasData = false.obs;
  bool get hasData => _hasData.value;
  
  /// 更新环境数据
  void updateEnvironment({
    required double temperature,
    required double humidity,
    required DateTime time,
  }) {
    _temperature.value = temperature;
    _humidity.value = humidity;
    _lastUpdateTime.value = time;
    _hasData.value = true;
  }
  
  /// 重置数据
  void reset() {
    _temperature.value = 0.0;
    _humidity.value = 0.0;
    _lastUpdateTime.value = null;
    _hasData.value = false;
  }
}