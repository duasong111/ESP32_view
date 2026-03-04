import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

class InteractionPage extends StatelessWidget {
  const InteractionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TDNavBar(title: '互动模式'),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text("声控状态: 待机"),
          const SizedBox(height: 20),
          TDButton(
            text: "测试灯光",
            onTap: () {},
          ),
        ],
      ),
    );
  }
}