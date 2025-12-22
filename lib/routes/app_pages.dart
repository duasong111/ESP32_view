// lib/routes/app_pages.dart
import 'package:get/get.dart';
import '../app/main_view/login_view.dart';
import '../app/main_view/main_table_view.dart';
import '../app/main_view/chat/chat_view.dart';
import '../app/models/contact.dart';
import 'auth_guard.dart';
class AppRoutes {
  static const login = '/login';
  static const home = '/home';
  static const profile = '/profile';
  static const chat = '/chat';
  static const function = '/function';
  
  static final routes = [
    GetPage(
      name: login,
      page: () => LoginView(),
      // 可以在这里添加过渡动画
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: home,
      page: () => MainTabView(),
      middlewares: [AuthGuard()], // 添加路由守卫
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: chat,
      page: () => ChatView(contact: Get.arguments as Contact),
      transition: Transition.fadeIn,
    ),
  ];
}