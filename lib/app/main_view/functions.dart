import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
// 功能栏
class ContactView extends StatefulWidget {
  const ContactView({super.key});

  @override
  State<ContactView> createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {
  @override
  Widget build(BuildContext context) {
    return TDTheme(
      data: TDThemeData.defaultData(),
      child: Scaffold(
        appBar: TDNavBar(
          title: '功能栏',
        ),
        body: const Center(
          child: Text('功能栏内容'),
        ),
      ),
    );
  }
}
