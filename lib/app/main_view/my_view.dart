import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:get/get.dart';
import '../../shared/widgets/func_lists.dart';
import '../api/services/auth_service.dart';

// 移除不存在的 import
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  // 构建填充按钮
  TDButton _buildLightFillButton(BuildContext context, String text) {
    return TDButton(
      text: text,
      size: TDButtonSize.medium,
      type: TDButtonType.fill,
      shape: TDButtonShape.rectangle,
      theme: TDButtonTheme.light,
      width: 100,
      onTap: () {},
    );
  }

  // 用户的头像
  Widget _buildImageAvatar(BuildContext context) {
    return const TDAvatar(
      size: TDAvatarSize.large,
      type: TDAvatarType.normal,
      defaultUrl: 'assets/images/avatar.png',
    );
  }

  // 分割线
  Widget _verticalTextDivider(BuildContext context) {
    return const Wrap(
      runSpacing: 20,
      children: [TDDivider(text: '', alignment: TextAlignment.center)],
    );
  }

  // 构建卡片主体：左侧头像，右侧两个按钮
  Widget _buildCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // 垂直居中对齐所有 Row 子项
          children: [
            _buildImageAvatar(context),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end, // 按钮右对齐
              children: [
                _buildLightFillButton(context, '修改资料'),
                const SizedBox(height: 12), // 按钮间的垂直间隔
                _buildLightFillButton(context, '查看主页'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final verticalSpacerHeight = MediaQuery.of(context).size.height * 0.01;
    return TDTheme(
      data: TDThemeData.defaultData(),
      child: Scaffold(
        appBar: const TDNavBar(
          // 改为 const
          title: '我的',
        ),
        // 使用 ListView 代替 Center/Column，更适合滚动和边距控制
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(height: verticalSpacerHeight), // 顶部间隔

            Padding(
              // 假设卡片宽度占据屏幕的 96%，左右各留 2%
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.02,
              ),
              child: Column(
                children: [
                  _buildCard(context),
                  _verticalTextDivider(context),
                  FunctionLists(
                    items: [
                      FunctionItem(
                        title: '设置',
                        background: const Color.fromARGB(255, 71, 144, 226),
                        textColor: Colors.white,
                        icon: TDIcons.setting, // ← 就是这一行！加上图标
                        onTap: () {},
                      ),
                      FunctionItem(
                        title: '朋友圈',
                        background: const Color.fromARGB(255, 240, 240, 240),
                        textColor: const Color.fromARGB(255, 111, 151, 183),
                        icon: TDIcons.anchor,
                      ),
                      FunctionItem(
                        title: '开发记录',
                        background: const Color.fromARGB(255, 240, 240, 240),
                        textColor: const Color.fromARGB(255, 111, 151, 183),
                        icon: TDIcons.adjustment,
                      ),
                      FunctionItem(
                        title: '退出登录',
                        background: const Color.fromARGB(255, 240, 240, 240),
                        textColor: const Color.fromARGB(255, 73, 121, 205),
                        icon: TDIcons.logout,
                        onTap: () {
                          // 使用GetX的默认对话框
                          Get.defaultDialog(
                            title: '退出登录',
                            middleText: '确定要退出当前账号吗？',
                            confirmTextColor: Colors.white,
                            onConfirm: () async {
                              // 调用退出登录方法
                              await Get.find<AuthService>().logout();
                              // 导航到登录页面
                              Get.offAllNamed('/login');
                            },
                            onCancel: () {
                              // 关闭对话框
                              Get.back();
                            },
                            textConfirm: '确定',
                            textCancel: '取消',
                          );
                        },
                      ),
                    ],
                    
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}