// lib/app/main_tab_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'home_view.dart';
import 'contact_view.dart';
import 'my_view.dart';
import 'login_view.dart';
// 作用就是功能栏之间的切换步骤等
class MainTabController extends GetxController {
  var currentIndex = 0.obs;  // 当前选中的 tab

  final pages = [
    // LoginView(),
    const HomeView(),
    const ContactView(),
    const ProfileView(),
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
            label: '聊天',
          ),
          BottomNavigationBarItem(
            icon: Icon(TDIcons.app),
            label: '联系人',
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