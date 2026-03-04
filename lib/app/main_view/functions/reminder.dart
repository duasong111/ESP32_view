import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

class ReminderPage extends StatelessWidget {
  const ReminderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TDNavBar(title: '智能提醒'),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text("距离触发状态: 正常"),
          const SizedBox(height: 20),
          TDButton(
            text: "开启提醒",
            onTap: () {},
          ),
        ],
      ),
    );
  }
}