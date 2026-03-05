import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../api/endpoints.dart';
import '../../api/services/environment_service.dart';

class TimeCard extends StatefulWidget {
  final void Function(double temperature, double humidity, DateTime time)? onTemperatureUpdate;

  const TimeCard({super.key, this.onTemperatureUpdate});

  @override
  State<TimeCard> createState() => _TimeCardState();
}

class _TimeCardState extends State<TimeCard> {
  WebSocket? _socket;

  String _timeText = '--:--:--';
  String _dateText = '----年--月--日';

  double? _temperature;
  double? _humidity;

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  @override
  void dispose() {
    _socket?.close();
    super.dispose();
  }

  /// =======================
  /// WebSocket 连接
  /// =======================
  Future<void> _connectWebSocket() async {
    final url = '${Endpoints.wsBaseUrl}${Endpoints.esp32Data}';
    try {
      _socket = await WebSocket.connect(
        url,
      ).timeout(const Duration(seconds: 5));
      _socket!.listen(
        _handleMessage,
        onError: (error, stackTrace) {
          debugPrint('Error: $error');
          if (stackTrace != null) {
            debugPrint('StackTrace: $stackTrace');
          }
        },
        onDone: () {
          debugPrint(
            'WebSocket closed '
            '(code=${_socket?.closeCode}, '
            'reason=${_socket?.closeReason})',
          );
        },
        cancelOnError: true,
      );
    } catch (e, stack) {
      debugPrint('Exception: $e');
      debugPrint('StackTrace: $stack');
    }
  }

  /// =======================
  /// 处理消息
  /// =======================
  void _handleMessage(dynamic message) {
    try {
      if (message is! String) {
        debugPrint('Message is not String, ignore');
        return;
      }

      /// 外层 JSON
      final Map<String, dynamic> outer = jsonDecode(message);
      
      Map<String, dynamic> payload;
      
      // 支持两种数据格式
      if (outer.containsKey('payload')) {
        /// payload 二次解析
        final payloadRaw = outer['payload'];
        payload = jsonDecode(payloadRaw);
      } else if (outer.containsKey('time') && outer.containsKey('temperature')) {
        /// 直接使用外层数据
        payload = outer;
      } else {
        debugPrint('数据格式不正确: $outer');
        return;
      }

      /// 时间
      final DateTime time = DateTime.parse(payload['time']);

      /// 温湿度
      final double temperature =
          (payload['temperature'] as num).toDouble();
      final double humidity =
          (payload['humidity'] as num).toDouble();

      if (!mounted) return;

      setState(() {
        _timeText = DateFormat('HH:mm:ss').format(time);
        _dateText = DateFormat('yyyy年MM月dd日').format(time);
        _temperature = temperature;
        _humidity = humidity;
      });
      
      // 更新全局环境数据
      final environmentService = Get.find<EnvironmentService>();
      environmentService.updateEnvironment(
        temperature: temperature,
        humidity: humidity,
        time: time,
      );
      
      widget.onTemperatureUpdate?.call(temperature, humidity, time);
      
      debugPrint('环境数据已更新: 温度=$temperature°C, 湿度=$humidity%');
    } catch (e, stack) {
      debugPrint('Exception: $e');
      debugPrint('StackTrace: $stack');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return SizedBox(
      width: size.width * 0.98,
      height: size.height * 0.12,
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surfaceVariant,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              /// 左侧条
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 20),

              /// 时间
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _timeText,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _dateText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              /// 分割线
              Container(
                width: 1,
                height: 48,
                color: theme.dividerColor.withOpacity(0.4),
              ),

              const SizedBox(width: 20),

              /// 温湿度
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _temperature != null
                        ? '🌡 ${_temperature!.toStringAsFixed(1)}℃'
                        : '🌡 --.-℃',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _humidity != null
                        ? '💧 ${_humidity!.toStringAsFixed(0)}%'
                        : '💧 --%',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
