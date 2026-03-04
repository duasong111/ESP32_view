import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

class EnvironmentPage extends StatelessWidget {
  const EnvironmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TDNavBar(title: '环境监测'),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text("温度: 25°C", style: TextStyle(fontSize: 24)),
          const Text("湿度: 60%", style: TextStyle(fontSize: 24)),
          const SizedBox(height: 20),
          TDButton(
            text: "自动模式",
            onTap: () {},
          ),
        ],
      ),
    );
  }
}