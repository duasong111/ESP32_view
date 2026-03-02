import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../main_view/home/time_card.dart';
import '../../shared/widgets/iot_switch_card.dart';
import '../main_view/home/upload_image_card.dart';
import '../api/endpoints.dart';
import '../api/services/setting_service.dart';
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool lightOn = true;
  bool fanOn = false;
  bool otherSwitchOn = false;
  bool buzzerOn = false;
  
  // RGB 控制参数
  String selectedColor = 'blue';
  int brightness = 30;
  
  // 蜂鸣器控制参数
  int buzzerFrequency = 2000;
  int buzzerDuration = 500;
  int buzzerInterval = 200;
  int buzzerCycles = 3;
  
  // 温度提醒消息列表（只保留最近两条）
  final List<String> _temperatureAlerts = [];

  /// 发送 RGB 控制命令
  Future<void> _sendRgbControl(bool isOn) async {
    try {
      final url = Uri.parse('${Endpoints.baseUrl}${Endpoints.rgbControl}');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'state': isOn ? 'on' : 'off',
          'color': selectedColor,
          'brightness': brightness,
        }),
      );
      debugPrint('RGB控制响应: ${response.statusCode}');
      if (response.statusCode == 200) {
        debugPrint('控制成功: ${response.body}');
      } else {
        debugPrint('控制失败: ${response.body}');
      }
    } catch (e) {
      debugPrint('发送控制命令失败: $e');
    }
  }
  
  /// 发送 RGB 参数更新命令
  Future<void> _updateRgbParams() async {
    if (lightOn) {
      await _sendRgbControl(true);
    }
  }
  
  /// 发送蜂鸣器控制命令
  Future<void> _sendBuzzerControl(bool isOn) async {
    try {
      final url = Uri.parse('${Endpoints.baseUrl}${Endpoints.buzzerControl}');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'type': 'buzzer',
          'state': isOn ? 'on' : 'off',
          'frequency': buzzerFrequency,
          'duration': buzzerDuration,
          'interval': buzzerInterval,
          'cycles': buzzerCycles,
        }),
      );
      debugPrint('蜂鸣器控制响应: ${response.statusCode}');
      if (response.statusCode == 200) {
        debugPrint('控制成功: ${response.body}');
      } else {
        debugPrint('控制失败: ${response.body}');
      }
    } catch (e) {
      debugPrint('发送蜂鸣器控制命令失败: $e');
    }
  }
  
  /// 处理温度更新
  void _handleTemperatureUpdate(double temperature, double humidity, DateTime time) {
    final settingService = Get.find<SettingService>();
    
    if (!settingService.temperatureAlertEnabled) {
      return;
    }
    
    if (temperature > settingService.temperatureThreshold) {
      final timeStr = DateFormat('HH:mm:ss').format(time);
      final alertMessage = '[$timeStr] 温度 ${temperature.toStringAsFixed(1)}℃ 超过${settingService.temperatureThreshold.toStringAsFixed(1)}度';
      
      setState(() {
        _temperatureAlerts.insert(0, alertMessage);
        if (_temperatureAlerts.length > 2) {
          _temperatureAlerts.removeLast();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '快捷操作',
          style: TextStyle(fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            // 时间卡片
            TimeCard(
              onTemperatureUpdate: _handleTemperatureUpdate,
            ),
            const SizedBox(height: 16),
            // 消息提醒卡片
            if (_temperatureAlerts.isNotEmpty && Get.find<SettingService>().temperatureAlertEnabled) _buildNoticeBar(),
            const SizedBox(height: 16),
            // 小的功能卡片
            Wrap(
              spacing: 12, // 横向间距
              runSpacing: 12, // 纵向间距
              alignment: WrapAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    _showLightControlDialog();
                  },
                  child: IoTSwitchCard(
                    title: '小灯',
                    value: lightOn,
                    accentColor: Colors.blue,
                    onChanged: (v) {
                      setState(() => lightOn = v);
                      _sendRgbControl(v);
                    },
                  ),
                ),
                IoTSwitchCard(
                  title: '风扇',
                  value: fanOn,
                  accentColor: Colors.green,
                  onChanged: (v) {
                    setState(() => fanOn = v);
                  },
                ),
                IoTSwitchCard(
                  title: '其他开关',
                  value: otherSwitchOn,
                  accentColor: const Color.fromARGB(255, 108, 152, 215),
                  onChanged: (v) {
                    setState(() => otherSwitchOn = v);
                  },
                ),
                 GestureDetector(
                  onTap: () {
                    _showBuzzerControlDialog();
                  },
                  child: IoTSwitchCard(
                    title: '蜂鸣器',
                    value: buzzerOn,
                    accentColor: const Color.fromARGB(255, 207, 88, 19),
                    onChanged: (v) {
                      setState(() => buzzerOn = v);
                      _sendBuzzerControl(v);
                    },
                  ),
                ),
              ],
            ),
            // 上传图片
            const SizedBox(height: 16),
            UploadImageCard(
      onImageSelected: (file) {
        debugPrint('选中的图片路径: ${file.path}');
      },
    ),
          ],
        ),
      ),
    );
  }
  
  /// 根据字符串获取颜色
  Color _getColorFromString(String colorName) {
    switch (colorName) {
      case 'red': return Colors.red;
      case 'green': return Colors.green;
      case 'blue': return Colors.blue;
      case 'yellow': return Colors.yellow;
      case 'purple': return Colors.purple;
      case 'white': return Colors.white;
      default: return Colors.blue;
    }
  }
  
  /// 构建消息提醒卡片
  Widget _buildNoticeBar() {
    final size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: TDNoticeBarStyle.generateTheme(context).backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0d000000),
            blurRadius: 8,
            spreadRadius: 2,
            offset: Offset(0, 2),
          ),
          BoxShadow(
            color: Color(0x0f000000),
            blurRadius: 10,
            spreadRadius: 1,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Color(0x1a000000),
            blurRadius: 5,
            spreadRadius: -3,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: size.width - 32,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            clipBehavior: Clip.hardEdge,
            child: TDNoticeBar(
              content: '温度超过15度提醒',
              prefixIcon: TDIcons.error_circle_filled,
              suffixIcon: TDIcons.chevron_right,
            ),
          ),
          Container(
            width: size.width - 32,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TDTheme.of(context).bgColorContainer,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var alert in _temperatureAlerts)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      alert,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
  
  /// 显示蜂鸣器控制对话框
  void _showBuzzerControlDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('蜂鸣器控制'),
              content: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 开关控制
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('开关'),
                        Switch(
                          value: buzzerOn,
                          onChanged: (v) {
                            setState(() => buzzerOn = v);
                            setStateDialog(() {});
                            _sendBuzzerControl(v);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // 频率调节
                    Text('频率: $buzzerFrequency Hz', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Slider(
                      value: buzzerFrequency.toDouble(),
                      min: 100,
                      max: 10000,
                      divisions: 99,
                      onChanged: (value) {
                        setState(() {
                          buzzerFrequency = value.toInt();
                        });
                        setStateDialog(() {});
                      },
                      onChangeEnd: (value) {
                        setState(() {
                          buzzerFrequency = value.toInt();
                          if (buzzerOn) {
                            _sendBuzzerControl(true);
                          }
                        });
                        setStateDialog(() {});
                      },
                      activeColor: Colors.orange,
                    ),
                    const SizedBox(height: 20),
                    // 持续时间调节
                    Text('持续时间: $buzzerDuration ms', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Slider(
                      value: buzzerDuration.toDouble(),
                      min: 50,
                      max: 2000,
                      divisions: 39,
                      onChanged: (value) {
                        setState(() {
                          buzzerDuration = value.toInt();
                        });
                        setStateDialog(() {});
                      },
                      onChangeEnd: (value) {
                        setState(() {
                          buzzerDuration = value.toInt();
                          if (buzzerOn) {
                            _sendBuzzerControl(true);
                          }
                        });
                        setStateDialog(() {});
                      },
                      activeColor: Colors.orange,
                    ),
                    const SizedBox(height: 20),
                    // 间隔时间调节
                    Text('间隔时间: $buzzerInterval ms', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Slider(
                      value: buzzerInterval.toDouble(),
                      min: 50,
                      max: 1000,
                      divisions: 19,
                      onChanged: (value) {
                        setState(() {
                          buzzerInterval = value.toInt();
                        });
                        setStateDialog(() {});
                      },
                      onChangeEnd: (value) {
                        setState(() {
                          buzzerInterval = value.toInt();
                          if (buzzerOn) {
                            _sendBuzzerControl(true);
                          }
                        });
                        setStateDialog(() {});
                      },
                      activeColor: Colors.orange,
                    ),
                    const SizedBox(height: 20),
                    // 循环次数调节
                    Text('循环次数: $buzzerCycles', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Slider(
                      value: buzzerCycles.toDouble(),
                      min: 1,
                      max: 10,
                      divisions: 9,
                      onChanged: (value) {
                        setState(() {
                          buzzerCycles = value.toInt();
                        });
                        setStateDialog(() {});
                      },
                      onChangeEnd: (value) {
                        setState(() {
                          buzzerCycles = value.toInt();
                          if (buzzerOn) {
                            _sendBuzzerControl(true);
                          }
                        });
                        setStateDialog(() {});
                      },
                      activeColor: Colors.orange,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('确定'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  /// 显示灯光控制对话框
  void _showLightControlDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('小灯控制'),
              content: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 开关控制
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('开关'),
                        Switch(
                          value: lightOn,
                          onChanged: (v) {
                            setState(() => lightOn = v);
                            setStateDialog(() {});
                            _sendRgbControl(v);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // 颜色选择
                    const Text('颜色', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (var color in ['red', 'green', 'blue', 'yellow', 'purple', 'white']) 
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedColor = color;
                                _updateRgbParams();
                              });
                              setStateDialog(() {});
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _getColorFromString(color),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: selectedColor == color ? Colors.black : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // 亮度调节
                    Text('亮度: $brightness%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Slider(
                      value: brightness.toDouble(),
                      min: 0,
                      max: 100,
                      onChanged: (value) {
                        setState(() {
                          brightness = value.toInt();
                        });
                        setStateDialog(() {});
                      },
                      onChangeEnd: (value) {
                        setState(() {
                          brightness = value.toInt();
                          _updateRgbParams();
                        });
                        setStateDialog(() {});
                      },
                      activeColor: Colors.yellow,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('确定'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
