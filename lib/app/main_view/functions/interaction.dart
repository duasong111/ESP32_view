import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../api/endpoints.dart';
import '../../api/services/auth_service.dart';

class InteractionPage extends StatefulWidget {
  const InteractionPage({super.key});

  @override
  State<InteractionPage> createState() => _InteractionPageState();
}

class _InteractionPageState extends State<InteractionPage> {
  final TextEditingController _deviceIdController = TextEditingController(text: 'esp32_001');
  
  // 蜂鸣器控制状态
  bool _buzzerOn = false;
  int _buzzerFrequency = 2000;
  int _buzzerDuration = 1000;
  int _buzzerCycles = 3;
  
  // LED 控制状态
  bool _ledOn = false;
  String _ledColor = 'yellow';
  int _ledBrightness = 80;
  String _ledMode = 'blink';
  
  final List<String> _colors = ['red', 'green', 'blue', 'yellow', 'purple', 'white'];
  final List<String> _modes = ['static', 'blink', 'fade'];

  @override
  void dispose() {
    _deviceIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TDNavBar(title: '设备自检'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // 设备编号输入
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '设备自检',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _deviceIdController,
                      decoration: const InputDecoration(
                        labelText: '设备编号',
                        hintText: '例如: esp32_001',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 蜂鸣器控制卡片
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
                        Row(
                          children: [
                            Icon(Icons.notifications_active, color: Colors.orange),
                            const SizedBox(width: 8),
                            const Text(
                              '蜂鸣器控制',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Switch(
                          value: _buzzerOn,
                          onChanged: (value) {
                            setState(() {
                              _buzzerOn = value;
                            });
                            _sendControlCommand();
                          },
                          activeColor: Colors.orange,
                        ),
                      ],
                    ),
                    
                    if (_buzzerOn) ...[
                      const SizedBox(height: 16),
                      _buildSlider(
                        title: '频率',
                        value: _buzzerFrequency.toDouble(),
                        min: 100,
                        max: 10000,
                        unit: 'Hz',
                        color: Colors.orange,
                        onChanged: (value) {
                          setState(() {
                            _buzzerFrequency = value.toInt();
                          });
                        },
                        onChangeEnd: (double _) => _sendControlCommand(),
                      ),
                      const SizedBox(height: 12),
                      _buildSlider(
                        title: '持续时间',
                        value: _buzzerDuration.toDouble(),
                        min: 100,
                        max: 5000,
                        unit: 'ms',
                        color: Colors.orange,
                        onChanged: (value) {
                          setState(() {
                            _buzzerDuration = value.toInt();
                          });
                        },
                        onChangeEnd: (double _) => _sendControlCommand(),
                      ),
                      const SizedBox(height: 12),
                      _buildSlider(
                        title: '循环次数',
                        value: _buzzerCycles.toDouble(),
                        min: 1,
                        max: 10,
                        unit: '次',
                        color: Colors.orange,
                        onChanged: (value) {
                          setState(() {
                            _buzzerCycles = value.toInt();
                          });
                        },
                        onChangeEnd: (double _) => _sendControlCommand(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // LED 控制卡片
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
                        Row(
                          children: [
                            Icon(Icons.lightbulb, color: Colors.yellow),
                            const SizedBox(width: 8),
                            const Text(
                              'LED 控制',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Switch(
                          value: _ledOn,
                          onChanged: (value) {
                            setState(() {
                              _ledOn = value;
                            });
                            _sendControlCommand();
                          },
                          activeColor: Colors.yellow,
                        ),
                      ],
                    ),
                    
                    if (_ledOn) ...[
                      const SizedBox(height: 16),
                      
                      // 颜色选择
                      const Text('颜色', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _colors.map((color) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _ledColor = color;
                              });
                              _sendControlCommand();
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _getColorFromString(color),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _ledColor == color ? Colors.black : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // 亮度调节
                      _buildSlider(
                        title: '亮度',
                        value: _ledBrightness.toDouble(),
                        min: 0,
                        max: 100,
                        unit: '%',
                        color: Colors.yellow,
                        onChanged: (value) {
                          setState(() {
                            _ledBrightness = value.toInt();
                          });
                        },
                        onChangeEnd: (double _) => _sendControlCommand(),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // 模式选择
                      const Text('模式', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _modes.map((mode) {
                          return ChoiceChip(
                            label: Text(_getModeText(mode)),
                            selected: _ledMode == mode,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _ledMode = mode;
                                });
                                _sendControlCommand();
                              }
                            },
                            selectedColor: Colors.yellow.withOpacity(0.3),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 一键控制按钮
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TDButton(
                      text: '全部开启',
                      theme: TDButtonTheme.primary,
                      onTap: () {
                        setState(() {
                          _buzzerOn = true;
                          _ledOn = true;
                        });
                        _sendControlCommand();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TDButton(
                      text: '全部关闭',
                      theme: TDButtonTheme.danger,
                      onTap: () {
                        setState(() {
                          _buzzerOn = false;
                          _ledOn = false;
                        });
                        _sendControlCommand();
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider({
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
            Text(title, style: const TextStyle(fontSize: 14)),
            Text(
              '${value.toInt()} $unit',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
          onChangeEnd: onChangeEnd,
          activeColor: color,
        ),
      ],
    );
  }

  Color _getColorFromString(String colorName) {
    switch (colorName) {
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'yellow':
        return Colors.yellow;
      case 'purple':
        return Colors.purple;
      case 'white':
        return Colors.white;
      default:
        return Colors.grey;
    }
  }

  String _getModeText(String mode) {
    switch (mode) {
      case 'static':
        return '常亮';
      case 'blink':
        return '闪烁';
      case 'fade':
        return '渐变';
      default:
        return mode;
    }
  }

  /// 发送控制命令到后端
  Future<void> _sendControlCommand() async {
    try {
      final authService = Get.find<AuthService>();
      final jwtToken = authService.token.value;

      if (jwtToken.isEmpty) {
        debugPrint('JWT token 为空，无法发送控制命令');
        return;
      }

      final controls = <Map<String, dynamic>>[];

      // 添加蜂鸣器控制
      controls.add({
        'type': 'buzzer',
        'state': _buzzerOn ? 'on' : 'off',
        'frequency': _buzzerFrequency,
        'duration': _buzzerDuration,
        'cycles': _buzzerCycles,
      });

      // 添加 LED 控制
      controls.add({
        'type': 'led',
        'state': _ledOn ? 'on' : 'off',
        'color': _ledColor,
        'brightness': _ledBrightness,
        'mode': _ledMode,
      });

      final apiUrl = Uri.parse('${Endpoints.baseUrl}${Endpoints.controlSelfThreshold}');
      final response = await http.post(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({
          'device_id': _deviceIdController.text.trim(),
          'controls': controls,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('控制命令发送成功: ${response.body}');
        TDToast.showText('控制命令已发送', context: context);
      } else {
        debugPrint('控制命令发送失败: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('发送控制命令失败: $e');
    }
  }
}