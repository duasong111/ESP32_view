import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../api/client/dio_client.dart';
import '../api/endpoints.dart';
import '../api/services/auth_service.dart';
import './contact/new_friend.dart';
import './contact/contact_detail.dart';
// 通讯录
// 作用是进行声明和被引入
class ContactView extends StatefulWidget {
  const ContactView({super.key});

  @override
  State<ContactView> createState() => _ContactViewState();
}

// 好友列表吧
class _ContactViewState extends State<ContactView> {
  // 存储好友列表数据
  List<dynamic> friends = [];

  Widget _buildContactTop() {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.001;

    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10.0),
      child: Column(
        children: [
          // 第一行 - 蓝色背景
          _customCell(
            title: '新的朋友',
            background: Colors.blue,
            textColor: Colors.white,
          ),
          _customCell(
            title: '群聊',
            background: const Color.fromARGB(255, 115, 202, 100),
            textColor: Colors.white,
          ),
          _customCell(
            title: '公众号',
            background: const Color.fromARGB(255, 240, 240, 240),
            textColor: const Color.fromARGB(255, 111, 151, 183),
          ),
        ],
      ),
    );
  }

  // 自定义 cell（替代 TDCell）
  Widget _customCell({
    required String title,
    Color background = Colors.white,
    Color textColor = Colors.black,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15), // ← 这里控制占屏 96%
      child: Container(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        margin: const EdgeInsets.only(bottom: 5),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 56,
            child: Row(
              children: [
                // 左侧部分：标题区域，占80%宽度
                Expanded(
                  flex: 4,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      // 左侧点击：显示添加好友弹出框
                      if (title == '新的朋友') {
                        _buildPopFromCenterWithUnderClose(context);
                      }
                    },
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(title, style: TextStyle(color: textColor, fontSize: 16)),
                    ),
                  ),
                ),
                // 右侧部分：图标区域，占20%宽度
                Expanded(
                  flex: 1,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      // 右侧点击：跳转到新的朋友页面
                      if (title == '新的朋友') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NewFriendView()),
                        );
                      }
                    },
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: Icon(Icons.chevron_right, color: textColor, size: 24),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 添加水平分割线
  Widget _verticalTextDivider(BuildContext context) {
    return const Wrap(
      runSpacing: 20,
      children: [
        TDDivider(
          text: '好友列表',
          alignment: TextAlignment.left,
        ),
      ],
    );
  }
  // 发送好友申请
  Future<void> _friendRequest(String username) async {
    try {
      final response = await DioClient().post(
        Endpoints.applyOfFriends,
        data: {
          'to_username': username,
        },
      );
      if (response.statusCode == 200) {
        TDToast.showText('好友申请发送成功', context: context);
      } else {
        TDToast.showText('好友申请发送失败', context: context);
      }
    } catch (error) {
      TDToast.showText('网络错误，请稍后重试', context: context);
    }
  }

  // 刷新好友列表
  Future<void> _refreshFriendList() async {
    try {
      final response = await DioClient().get(Endpoints.getFriendsList);
      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          // 解析后端返回的数据，使用data字段中的好友列表
          friends = response.data['data'] as List<dynamic>;
        });
      } else {
        TDToast.showText('刷新好友列表失败', context: context);
      }
    } catch (error) {
      TDToast.showText('网络错误，请稍后重试', context: context);
    }
  }
  
  // 一进来就刷新好友列表
  @override
  void initState() {
    super.initState();
    _refreshFriendList();
  }

  // 好友列表卡片
  Widget _buildContactList() {
  if (friends.isEmpty) {
    return const Center(child: Text('暂无好友'));
  }

  return ListView.builder(
    shrinkWrap: true,  // 重要：因为嵌在外层 ListView 里
    physics: const NeverScrollableScrollPhysics(),  // 禁用内部滚动，让外层统一滚动
    itemCount: friends.length,
    itemBuilder: (context, index) {
      final friend = friends[index];
      String displayName = friend['username'] ?? '未知用户';

      return ListTile(
        leading: _avatarIcon(),  // 复用你现有的头像
        title: Text(displayName),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContactDetailView(contact: friend),
            ),
          );
        },
      );
    },
  );
}
  // 统一的头像组件
  Widget _avatarIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(Icons.person, color: Colors.white),
    );
  }

  // 顶部搜索栏
  Widget _buildFocusSearchBar(BuildContext context) {
    // 获取屏幕宽度
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.03;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: TDSearchBar(
        placeHolder: '搜索', // 占位符改为“搜索”
        needCancel: true,
        autoFocus: false,
      ),
    );
  }

  // 弹出框
  void _buildPopFromCenterWithUnderClose(BuildContext context) {
    final TextEditingController usernameController = TextEditingController();
    Navigator.of(context).push(
      TDSlidePopupRoute(
          isDismissible: false,
          slideTransitionFrom: SlideTransitionFrom.center,
          builder: (context) {
            return TDPopupCenterPanel(
              closeUnderBottom: true,
              closeClick: () {
                Navigator.maybePop(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: 300,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 标题
                      const Text(
                        '添加新朋友',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // 输入框
                      TDInput(
                        controller: usernameController,
                        hintText: '请输入用户名',
                        rightWidget: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => usernameController.clear(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // 按钮行
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // 取消按钮
                          TDButton(
                            text: '取消',
                            theme: TDButtonTheme.defaultTheme,
                            type: TDButtonType.outline,
                            onTap: () {
                              Navigator.maybePop(context);
                            },
                          ),
                          
                          // 确定按钮
                          TDButton(
                            text: '确定',
                            theme: TDButtonTheme.primary,
                            type: TDButtonType.fill,
                            onTap: () {
                              // 这里可以处理输入的用户名
                              String username = usernameController.text;
                              if (username.isNotEmpty) {
                                // 执行添加好友的逻辑
                                _friendRequest(username);
                                // 关闭对话框
                                Navigator.maybePop(context);
                              } else {
                                // 显示提示信息
                                TDToast.showText('请输入用户名', context: context);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final verticalSpacerHeight = MediaQuery.of(context).size.height * 0.01;
    return TDTheme(
      data: TDThemeData.defaultData(),
      child: Scaffold(
        appBar: TDNavBar(
          title: '通讯录',
        ),
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(height: verticalSpacerHeight),
            // 搜索栏
            _buildFocusSearchBar(context),

            // 功能栏
            _buildContactTop(),
            //水平分割线
            // _verticalTextDivider(context),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Text('好友列表', style: TextStyle(fontSize: 14, color: Colors.grey)),
            ),
            // 好友列表
            _buildContactList(),
          ],
        ),
      ),
    );
  }
}
