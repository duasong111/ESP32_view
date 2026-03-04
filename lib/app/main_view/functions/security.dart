import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

class SecurityPage extends StatelessWidget {
  const SecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TDNavBar(title: '安防模式'),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text("当前状态: 未布防"),
          const SizedBox(height: 20),
          TDButton(
            text: "启动布防",
            theme: TDButtonTheme.danger,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}