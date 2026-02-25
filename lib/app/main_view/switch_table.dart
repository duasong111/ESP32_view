// lib/app/main_tab_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'home.dart';
import 'functions.dart';
import 'user_info.dart';
import 'login.dart';
class MainTabController extends GetxController {
  var currentIndex = 0.obs;  

  final pages = [
    // LoginView(),
    const HomeView(),
    const ContactView(),
    const MyView(),
  ];

  void changeTab(int index) {
    currentIndex.value = index;
  }
}

class MainTabView extends StatelessWidget {
  const MainTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MainTabController());  // 注入控制器

    return Scaffold(
      body: Obx(() => controller.pages[controller.currentIndex.value]),

      // 底部导航栏（用 TDesign 风格）
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: controller.currentIndex.value,
        onTap: controller.changeTab,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: TDTheme.of(context).brandNormalColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(TDIcons.chat_bubble),
            label: '首界面',
          ),
          BottomNavigationBarItem(
            icon: Icon(TDIcons.app),
            label: '功能栏',
          ),
          BottomNavigationBarItem(
            icon: Icon(TDIcons.user),
            label: '我的',
          ),
        ],
      )),
    );
  }
}