import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../api/client/dio_client.dart';
import '../../api/endpoints.dart';
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _agreeProtocol = true; // 默认勾选

  void _login() {
    if (!_agreeProtocol) {
      TDToast.showText('请阅读并同意用户协议和隐私政策', context: context);
      return;
    }
    if (_accountController.text.isEmpty || _passwordController.text.isEmpty) {
      TDToast.showText('请填写账号和密码', context: context);
      return;
    }
    //增加用户登录接口
    // final response = await DioClient().post(

    //     Endpoints.loginEndpoint,
    //     data: {
    //       'username': _accountController.text,
    //       'password': _passwordController.text,
    //     },
    //   );



    TDToast.showText('登录成功！', context: context);
    // Navigator.pushReplacementNamed(context, '/home');
  }

  // 显示协议弹窗
  void _showProtocol(String title, String content) {
    Navigator.of(context).push(
      TDSlidePopupRoute(
        slideTransitionFrom: SlideTransitionFrom.bottom,
        // barrierDismissible: false,
        builder: (context) {
          return TDPopupBottomConfirmPanel(
            title: title,
            // showAction: false, // 不显示底部按钮
            child: Container(
              padding: const EdgeInsets.all(20),
              height: 400,
              child: SingleChildScrollView(
                child: Text(
                  content,
                  style: const TextStyle(fontSize: 14, height: 1.8),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // 用户名输入
          TDInput(
            controller: _accountController,
            hintText: '请输入用户名 ',
            leftIcon: const Icon(TDIcons.bad_laugh),
            backgroundColor: Colors.grey[50],
          ),
          const SizedBox(height: 16),
          TDInput(
            controller: _passwordController,
            hintText: '请输入密码',
            leftIcon: const Icon(TDIcons.user_password),
            obscureText: true,
            backgroundColor: Colors.grey[50],
          ),
          const SizedBox(height: 32),
          TDButton(
            text: '登录',
            size: TDButtonSize.large,
            isBlock: true,
            theme: _agreeProtocol
                ? TDButtonTheme.primary
                : TDButtonTheme.defaultTheme,
            onTap: _agreeProtocol ? _login : null, // 不勾选时禁用点击
          ),
          const SizedBox(height: 24),
          // 协议勾选区域
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TDCheckbox(
                checked: _agreeProtocol,
                onCheckBoxChanged: (bool? v) {
                  setState(() {
                    _agreeProtocol = v ?? false;
                  });
                },
              ),
              const SizedBox(width: 8),
              const Text('我已阅读并同意'),
              GestureDetector(
                onTap: () => _showProtocol('用户协议', '''
                《ArrivalAreaChat 用户协议》
                欢迎使用 ArrivalAreaChat！本协议是您与 ArrivalAreaChat（以下简称“我们”）之间关于使用本软件服务的法律协议。
                1. 服务内容
                  我们提供即时通讯、文件传输、群聊等功能。
                2. 用户权利与义务
                  您应保证注册信息真实有效，不得利用本软件从事违法活动。
                3. 隐私保护
                  我们承诺保护您的个人信息安全，除法律要求外不会向第三方泄露。
                4. 协议更新
                  我们有权适时更新本协议，更新后将继续为您提供服务。
                继续使用即视为您已阅读并同意本协议。
                  '''),
                child: const Text(
                  '《用户协议》',
                  style: TextStyle(color: Color(0xFF07C160)),
                ),
              ),
              const Text('和'),

              GestureDetector(
                onTap: () => _showProtocol('隐私政策', '''
                《ArrivalAreaChat 隐私政策》
                我们非常重视您的隐私保护。本政策说明我们如何收集、使用和保护您的个人信息。
                1. 我们收集的信息
                  - 您主动提供的：手机号、昵称、头像等
                  - 自动收集：设备信息、日志信息
                2. 信息使用目的
                  - 提供聊天服务
                  - 改进产品体验
                  - 保障账户安全
                3. 信息共享
                  除以下情况外，我们不会向第三方共享您的个人信息：
                  - 获得您明确同意
                  - 响应法律法规要求
                  - 关联公司间共享（仅限必要范围）
                您使用本软件即表示您已阅读并同意本隐私政策。
                  '''),
                child: const Text(
                  '《隐私政策》',
                  style: TextStyle(color: Color(0xFF07C160)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
