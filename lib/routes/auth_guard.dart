import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../routes/app_pages.dart';
import '../app/api/services/auth_service.dart';
// auth_guard.dart
class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();
    if (!authService.isLoggedIn.value && route != AppRoutes.login) {
      print('AuthGuard: 未登录，重定向到登录页');
      return const RouteSettings(name: AppRoutes.login);
    }
    if (authService.isLoggedIn.value && route == AppRoutes.login) {
      print('AuthGuard: 已登录，重定向到首页');
      return const RouteSettings(name: AppRoutes.home);
    }
    print('AuthGuard: 允许访问');
    return null;
  }
  
  @override
  GetPage? onPageCalled(GetPage? page) {
    print('AuthGuard: 正在访问 ${page?.name}');
    return super.onPageCalled(page);
  }
}