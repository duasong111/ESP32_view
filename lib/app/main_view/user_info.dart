import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:get/get.dart';
import '../../shared/widgets/func_lists.dart';
import '../api/services/auth_service.dart';
import 'userinfo/setting.dart';
class MyView extends StatefulWidget {
  const MyView({super.key});

  @override
  State<MyView> createState() => _MyViewState();
}

class _MyViewState extends State<MyView> {
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
              crossAxisAlignment: CrossAxisAlignment.end, 
              children: [
                _buildLightFillButton(context, '修改资料'),
                const SizedBox(height: 12), 
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
          title: '我的',
        ),
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(height: verticalSpacerHeight), // 顶部间隔
            Padding(
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
                        icon: TDIcons.setting, 
                        onTap: () {
                          Get.to(() => const SettingView());
                        },
                      ),
                      FunctionItem(
                        title: '添加记录',
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
                          Get.defaultDialog(
                            title: '退出登录',
                            middleText: '确定要退出当前账号吗？',
                            confirmTextColor: Colors.white,
                            onConfirm: () async {
                              await Get.find<AuthService>().logout();
                              Get.offAllNamed('/login');
                            },
                            onCancel: () {
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