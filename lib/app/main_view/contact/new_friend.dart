import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../api/client/dio_client.dart';
import '../../api/endpoints.dart';
import '../../api/services/auth_service.dart';

enum FriendRequestType {
  received,
  sent,
}

class FriendRequest {
  final int id; // 添加后端返回的id字段
  final String username;
  final String avatar;
  final DateTime time;
  final FriendRequestType type;
  final bool isHandled;

  FriendRequest({
    required this.id,
    required this.username,
    required this.avatar,
    required this.time,
    required this.type,
    this.isHandled = false,
  });
}

class NewFriendView extends StatefulWidget {
  const NewFriendView({super.key});

  @override
  State<NewFriendView> createState() => _NewFriendViewState();
}

class _NewFriendViewState extends State<NewFriendView> {
  List<FriendRequest> friendRequests = [];

  // 统一的头像
  Widget _avatarIcon(String avatarUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        avatarUrl,
        width: 52,
        height: 52,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.person, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  // 点击进来首先刷新到是好友的申请的请求记录
  Future<void> _refreshFriendRequest() async {
    try {
      final response = await DioClient().get(
        Endpoints.refreshOfFriends,
      );
      print('查看好友列表详情: $response');
      
      if (response.statusCode == 200 && response.data != null) {
        // 解析后端返回的数据
        final List<dynamic> data = response.data['data'];
        setState(() {
          friendRequests = data.map((item) => FriendRequest(
            id: item['id'],
            username: item['from_user'], // 使用后端返回的from_user作为用户名
            avatar: 'https://randomuser.me/api/portraits/men/32.jpg', // 临时头像
            time: DateTime.parse(item['timestamp']), // 解析后端返回的时间戳
            type: FriendRequestType.received,
            isHandled: false,
          )).toList();
        });
      } else {
        TDToast.showText('获取好友请求失败', context: context);
      }
    } catch (error) {
      print('获取好友请求失败: $error');
      TDToast.showText('网络错误，请稍后重试', context: context);
    }
  }

  // 接受好友邀请
  Future<void> _acceptFriendInvitation(String user_id) async {
    try {
      final response = await DioClient().post(
        Endpoints.acceptOfFriends,
        data: {
          'request_id': user_id,
        },
      );
      print('接受好友邀请响应: $response');
      if (response.statusCode == 200) {
        TDToast.showText('已同意好友邀请', context: context);
      } else {
        TDToast.showText('接受好友邀请失败', context: context);
      }
    } catch (error) {
      print('接受好友邀请失败: $error');
      TDToast.showText('网络错误，请稍后重试', context: context);
    }
  }

  // 拒绝好友邀请-----后端还没有写
  Future<void> _rejectFriendInvitation(String user_id) async {
    try {
      // 如果后端有拒绝API，这里调用
      // 暂时只显示提示
      TDToast.showText('已拒绝好友邀请', context: context);
    } catch (error) {
      print('拒绝好友邀请失败: $error');
      TDToast.showText('网络错误，请稍后重试', context: context);
    }
  }

  // 这个类似于vue的onMounted
  @override
  void initState() {
    super.initState();
    _refreshFriendRequest();
  }

  // 处理请求
  void _handleRequest(FriendRequest request, bool accept) {
    setState(() {
      final i = friendRequests.indexOf(request);
      if (i != -1) {
        friendRequests[i] = FriendRequest(
          id: request.id,
          username: request.username,
          avatar: request.avatar,
          time: request.time,
          type: request.type,
          isHandled: true,
        );
        
        // 调用对应的API
        if (accept) {
          _acceptFriendInvitation(request.id.toString());
        } else {
          _rejectFriendInvitation(request.id.toString());
        }
      }
    });
  }

  // 顶部搜索栏（仅用于搜索本地记录，不带加号）
  Widget _buildTopSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: GestureDetector(
        onTap: () {
          // 可选：点击弹出搜索页面或本地过滤
          TDToast.showText('点击搜索添加记录', context: context);
        },
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.search, color: Colors.grey, size: 20),
              SizedBox(width: 8),
              Text(
                '搜索历史添加记录',
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestItem(FriendRequest request) {
    final isReceived = request.type == FriendRequestType.received;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _avatarIcon(request.avatar),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 左侧信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.username,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${request.time.month}月${request.time.day}日 ${request.time.hour.toString().padLeft(2, '0')}:${request.time.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                // 右侧按钮或状态
                if (isReceived)
                  request.isHandled
                      ? const Text('已处理',
                          style: TextStyle(color: Colors.grey, fontSize: 14))
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TDButton(
                              text: '同意',
                              size: TDButtonSize.small,
                              theme: TDButtonTheme.primary,
                              type: TDButtonType.fill,
                              onTap: () => _handleRequest(request, true),
                            ),
                            const SizedBox(width: 8),
                            TDButton(
                              text: '拒绝',
                              size: TDButtonSize.small,
                              theme: TDButtonTheme.light,
                              type: TDButtonType.outline,
                              onTap: () => _handleRequest(request, false),
                            ),
                          ],
                        )
                else
                  const Text('已添加',
                      style: TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TDTheme(
      data: TDThemeData.defaultData(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: TDNavBar(
          title: '新的朋友',
          backgroundColor: Colors.white,
        ),
        body: Column(
          children: [
            // 顶部搜索栏（居中，微信风格）
            _buildTopSearchBar(),

            // 间隔
            Container(height: 10, color: const Color(0xFFF5F5F5)),

            // 列表
            Expanded(
              child: ListView.separated(
                itemCount: friendRequests.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 1), // 每项之间细线
                itemBuilder: (context, index) =>
                    _buildRequestItem(friendRequests[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
