import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../main_view/home/time_card.dart';
import '../../shared/widgets/iot_switch_card.dart';
import '../main_view/home/upload_image_card.dart';
import '../api/endpoints.dart';
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
            TimeCard(),
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
        // 这里以后可以：
        // 1. 上传服务器
        // 2. WebSocket 发送
        // 3. ESP32 显示
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
