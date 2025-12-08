import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../routes/app_pages.dart';
import '../app/api/services/auth_service.dart';
// auth_guard.dart
class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();

    // 如果用户未登录且要访问的页面不是登录页，重定向到登录页
    if (!authService.isLoggedIn.value && route != AppRoutes.login) {
      return const RouteSettings(name: AppRoutes.login);
    }

    // 如果用户已登录且要访问登录页，重定向到首页
    if (authService.isLoggedIn.value && route == AppRoutes.login) {
      return const RouteSettings(name: AppRoutes.home);
    }

    return null;
  }
  
  @override
  GetPage? onPageCalled(GetPage? page) {
    print('AuthGuard: 正在访问 ${page?.name}');
    return super.onPageCalled(page);
  }
}