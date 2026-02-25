// lib/routes/app_pages.dart
import 'package:get/get.dart';
import '../app/main_view/login.dart';
import '../app/main_view/switch_table.dart';
import '../app/models/contact.dart';
import 'auth_guard.dart';
class AppRoutes {
  static const login = '/login';
  static const home = '/home';
  static const function = '/function';
  
  static final routes = [
    GetPage(
      name: login,
      page: () => LoginView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: home,
      page: () => MainTabView(),
      middlewares: [AuthGuard()], // 添加路由守卫
      transition: Transition.fadeIn,
    ),
  ];
}