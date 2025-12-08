// lib/app.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_pages.dart';
import '../app/api/services/auth_service.dart';

class App extends StatelessWidget {
  const App({super.key});
  // 初始化服务
  Future<void> initServices() async {
    await Get.putAsync(() => AuthService().init());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initServices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            initialRoute: AppRoutes.login,
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