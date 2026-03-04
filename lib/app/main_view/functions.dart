import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../main_view/functions/environment.dart';
import '../main_view/functions/reminder.dart';
import '../main_view/functions/interaction.dart';
import '../main_view/functions/security.dart';

class ContactView extends StatefulWidget {
  const ContactView({super.key});

  @override
  State<ContactView> createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {

  void _go(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  Widget buildCard(String title, String desc, IconData icon, Widget page, Color color) {
    return GestureDetector(
      onTap: () => _go(page),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TDNavBar(title: '功能栏'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                '自定义功能',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // 功能卡片网格
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  buildCard(
                    "环境监测",
                    "温湿度 + RGB 联动",
                    Icons.thermostat,
                    const EnvironmentPage(),
                    Colors.blue,
                  ),
                  buildCard(
                    "智能提醒",
                    "距离触发 + 语音",
                    Icons.notifications_active,
                    const ReminderPage(),
                    Colors.green,
                  ),
                  buildCard(
                    "互动模式",
                    "声控 + 灯效",
                    Icons.touch_app,
                    const InteractionPage(),
                    const Color.fromARGB(255, 108, 152, 215),
                  ),
                  buildCard(
                    "安防模式",
                    "异常检测 + 报警",
                    Icons.security,
                    const SecurityPage(),
                    const Color.fromARGB(255, 207, 88, 19),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}