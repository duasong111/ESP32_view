import 'dart:async';
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
  String _deviceId = 'esp32_001';
  bool _isGlobalLoading = false; // 全局按钮加载状态
  
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

  // 防抖计时器
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadBoundDevices();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel(); // 销毁时取消计时器
    super.dispose();
  }

  /// 加载绑定的设备
  Future<void> _loadBoundDevices() async {
    // 逻辑保持不变，实际建议调用 API
    setState(() {
      _deviceId = 'esp32_001'; 
    });
  }

  /// 统一的防抖发送入口
  /// [immediate] 如果为 true，则立即发送（如开关切换），否则延迟发送（如滑块）
  void _handleControlUpdate({bool immediate = false}) {
    _debounceTimer?.cancel();
    if (immediate) {
      _sendControlCommand();
    } else {
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        _sendControlCommand();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TDTheme.of(context).grayColor1, // 使用 TDesign 背景色
      appBar: const TDNavBar(title: '设备自检'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildDeviceInfoCard(),
            const SizedBox(height: 16),
            _buildBuzzerCard(),
            const SizedBox(height: 16),
            _buildLedCard(),
            const SizedBox(height: 24),
            _buildActionButtons(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // --- UI 组件拆分 ---

  Widget _buildDeviceInfoCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.developer_board, color: TDTheme.of(context).brandColor8),
        title: const Text('当前在线设备', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(_deviceId),
        // trailing: TDTag('运行中', theme: TDTagTheme.success, shape: TDTagShape.rounded),
      ),
    );
  }

  Widget _buildBuzzerCard() {
    return _buildControlContainer(
      title: '蜂鸣器控制',
      icon: Icons.notifications_active,
      iconColor: Colors.orange,
      value: _buzzerOn,
      onChanged: (val) {
        setState(() => _buzzerOn = val);
        _handleControlUpdate(immediate: true);
      },
      children: _buzzerOn ? [
        _buildSlider(
          title: '频率',
          value: _buzzerFrequency.toDouble(),
          min: 100, max: 10000, unit: 'Hz', color: Colors.orange,
          onChanged: (v) => setState(() => _buzzerFrequency = v.toInt()),
          onChangeEnd: (v) => _handleControlUpdate(),
        ),
        _buildSlider(
          title: '持续时间',
          value: _buzzerDuration.toDouble(),
          min: 100, max: 5000, unit: 'ms', color: Colors.orange,
          onChanged: (v) => setState(() => _buzzerDuration = v.toInt()),
          onChangeEnd: (v) => _handleControlUpdate(),
        ),
        _buildSlider(
          title: '循环次数',
          value: _buzzerCycles.toDouble(),
          min: 1, max: 10, unit: '次', color: Colors.orange,
          onChanged: (v) => setState(() => _buzzerCycles = v.toInt()),
          onChangeEnd: (v) => _handleControlUpdate(),
        ),
      ] : [],
    );
  }

  Widget _buildLedCard() {
    return _buildControlContainer(
      title: 'LED 控制',
      icon: Icons.lightbulb,
      iconColor: Colors.yellow.shade700,
      value: _ledOn,
      onChanged: (val) {
        setState(() => _ledOn = val);
        _handleControlUpdate(immediate: true);
      },
      children: _ledOn ? [
        const Text('灯光颜色', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          children: _colors.map((c) => _buildColorPicker(c)).toList(),
        ),
        const SizedBox(height: 16),
        _buildSlider(
          title: '亮度',
          value: _ledBrightness.toDouble(),
          min: 0, max: 100, unit: '%', color: Colors.yellow.shade700,
          onChanged: (v) => setState(() => _ledBrightness = v.toInt()),
          onChangeEnd: (v) => _handleControlUpdate(),
        ),
        const SizedBox(height: 16),
        const Text('显示模式', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _modes.map((m) => ChoiceChip(
            label: Text(_getModeText(m)),
            selected: _ledMode == m,
            onSelected: (s) {
              if (s) {
                setState(() => _ledMode = m);
                _handleControlUpdate(immediate: true);
              }
            },
          )).toList(),
        ),
      ] : [],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TDButton(
              text: '全开',
              theme: TDButtonTheme.primary,
              onTap: () async {
                setState(() { _buzzerOn = true; _ledOn = true; });
                await _sendControlCommand();
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TDButton(
              text: '全关',
              theme: TDButtonTheme.danger,
              onTap: () async {
                setState(() { _buzzerOn = false; _ledOn = false; });
                await _sendControlCommand();
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- 辅助构建私有方法 ---

  Widget _buildControlContainer({
    required String title, required IconData icon, required Color iconColor,
    required bool value, required ValueChanged<bool> onChanged, required List<Widget> children
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [Icon(icon, color: iconColor), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]),
                Switch(value: value, onChanged: onChanged, activeColor: iconColor),
              ],
            ),
            if (children.isNotEmpty) ...[const Divider(), ...children],
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker(String colorName) {
    bool isSelected = _ledColor == colorName;
    return GestureDetector(
      onTap: () {
        setState(() => _ledColor = colorName);
        _handleControlUpdate(immediate: true);
      },
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: _getColorFromString(colorName),
          shape: BoxShape.circle,
          border: Border.all(color: isSelected ? Colors.black : Colors.grey.shade300, width: isSelected ? 3 : 1),
          boxShadow: isSelected ? [BoxShadow(color: Colors.black26, blurRadius: 4)] : null,
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String title, required double value, required double min, required double max,
    required String unit, required Color color, required ValueChanged<double> onChanged, required ValueChanged<double> onChangeEnd,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Text('${value.toInt()}$unit', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(value: value, min: min, max: max, onChanged: onChanged, onChangeEnd: onChangeEnd, activeColor: color),
      ],
    );
  }

  // --- 逻辑处理 ---

  Color _getColorFromString(String colorName) {
    switch (colorName) {
      case 'red': return Colors.red;
      case 'green': return Colors.green;
      case 'blue': return Colors.blue;
      case 'yellow': return Colors.yellow;
      case 'purple': return Colors.purple;
      case 'white': return Colors.white;
      default: return Colors.grey;
    }
  }

  String _getModeText(String mode) {
    final map = {'static': '常亮', 'blink': '闪烁', 'fade': '渐变'};
    return map[mode] ?? mode;
  }
 Future<void> _sendControlCommand() async {
  try {
    final authService = Get.find<AuthService>();
    final String jwtToken = authService.token.value;

    // --- 准备请求数据 ---
    final String apiUrl = '${Endpoints.baseUrl}${Endpoints.controlSelfThreshold}';
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $jwtToken', // 注意：Bearer 后面必须有一个空格
    };

    final Map<String, dynamic> body = {
      'device_id': _deviceId,
      'controls': [
        {
          'type': 'buzzer',
          'state': _buzzerOn ? 'on' : 'off',
          'frequency': _buzzerFrequency,
          'duration': _buzzerDuration,
          'cycles': _buzzerCycles,
        },
        {
          'type': 'led',
          'state': _ledOn ? 'on' : 'off',
          'color': _ledColor,
          'brightness': _ledBrightness,
          'mode': _ledMode,
        }
      ],
    };

    // --- 核心调试日志：打印请求头 ---
    debugPrint('🚀 [HTTP Request Start]');
    debugPrint('📍 URL: $apiUrl');
    debugPrint('📝 Method: POST');
    debugPrint('🔑 Headers:');
    headers.forEach((key, value) {
      // 隐藏 Token 中间部分保护安全，但保留头尾确认格式
      String displayValue = value;
      if (key == 'Authorization' && value.length > 20) {
        displayValue = '${value.substring(0, 15)}...${value.substring(value.length - 5)}';
      }
      debugPrint('   - $key: $displayValue');
    });
    debugPrint('📦 Body: ${jsonEncode(body)}');
    debugPrint('--------------------------');

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: jsonEncode(body),
    );

    // --- 响应日志 ---
    debugPrint('📥 [HTTP Response]');
    debugPrint('🔢 Status Code: ${response.statusCode}');
    debugPrint('📄 Body: ${response.body}');
    debugPrint('🚀 [HTTP Request End]');

    if (!mounted) return;

    if (response.statusCode == 200) {
      TDToast.showSuccess('控制成功', context: context);
    } else {
      // 这里的错误处理会自动弹出后端返回的 "未提供 token"
      final errorMsg = jsonDecode(response.body)['message'] ?? '请求失败';
      TDToast.showText(errorMsg, context: context);
    }
  } catch (e) {
    debugPrint('Error: $e');
    if (mounted) TDToast.showText('网络异常', context: context);
  }
}
  
}