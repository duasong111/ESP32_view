// lib/modules/auth/views/login_view.dart
import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../main_view/login/register_form.dart';
import '../main_view/login/login_form.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TDTheme(
      data: TDThemeData.defaultData(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: TDNavBar(
          backgroundColor: Colors.white,
          title: '登录 / 注册',
          centerTitle: true,
        ),
        body: Column(
          children: [
            const SizedBox(height: 60),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF07C160),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(TDIcons.loading, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 40),
            const Text(
              'ESP32终端测试机1',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            // 选项卡
            TDTabBar(
              controller: _tabController, // 绑定 controller
              tabs: const [
                TDTab(text: '登录'),
                TDTab(text: '注册'),
              ],
            ),

            // 用户注册登录表单切换
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [LoginForm(), RegisterForm()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
