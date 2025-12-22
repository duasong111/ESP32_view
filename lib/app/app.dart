// lib/app.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_pages.dart';
import '../app/api/services/auth_service.dart';

class App extends StatelessWidget {
  const App({super.key});
  // 初始化服务
  Future<void> initServices() async {
    // 如果AuthService已经存在，就不再初始化，避免热重载时重置登录状态
    if (!Get.isRegistered<AuthService>()) {
      // 设置permanent: true确保服务在整个应用生命周期中保持存在，避免热重载时丢失
      await Get.putAsync(() => AuthService().init(), permanent: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initServices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final authService = Get.find<AuthService>();
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            // 根据用户登录状态动态设置初始路由
            initialRoute: authService.isLoggedIn.value ? AppRoutes.home : AppRoutes.login,
            getPages: AppRoutes.routes,
            unknownRoute: GetPage(
              name: '/notfound',
              page: () => Scaffold(
                appBar: AppBar(title: Text('页面未找到')),
                body: Center(child: Text('页面不存在')),
              ),
            ),
            // 路由观察器
            // routingCallback: (routing) {
            //   if (routing != null) {
            //     print('路由变化: ${routing.previous} -> ${routing.current}');
            //   }
            // },
          );
        }
        // 加载中显示加载界面
        return MaterialApp(
          home: Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }
}