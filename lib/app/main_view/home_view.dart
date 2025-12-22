// lib/modules/home/views/home_view.dart
import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../models/contact.dart';
import 'chat/chat_view.dart';
import '../api/client/dio_client.dart';
import '../api/endpoints.dart';
import '../api/services/auth_service.dart';
// 首页 - 聊天列表
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // 存储真实好友列表数据
  List<Contact> contacts = [];
  bool isLoading = true;

  // 加载好友列表
  Future<void> _loadFriendsList() async {
    try {
      final response = await DioClient().get(Endpoints.getFriendsList);
      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> friendsData = response.data['data'] as List<dynamic>;
        
        // 将后端返回的好友数据转换为Contact对象列表
        setState(() {
          contacts = friendsData.map((friend) {
            // 获取好友的最后一条消息（这里暂时用mock数据，实际应该从聊天记录获取）
            String lastMessage = friend['last_message'] ?? '';
            
            // 解析最后登录时间（或者最后消息时间）
            DateTime lastMessageTime;
            try {
              lastMessageTime = DateTime.parse(friend['last_login'] ?? DateTime.now().toIso8601String());
            } catch (e) {
              lastMessageTime = DateTime.now();
            }
            
            return Contact(
              id: friend['id']?.toString() ?? '',
              name: friend['username'] ?? friend['nickname'] ?? '未知用户',
              avatar: friend['avatar'] ?? '',
              lastMessage: lastMessage,
              lastMessageTime: lastMessageTime,
              unreadCount: friend['unread_count'] ?? 0,
              publicKey: friend['public_key'] ?? '', // 确保传递公钥信息
            );
          }).toList();
          
          print('从后端获取的好友列表: ${response.data}');
          print('转换后的Contact列表: $contacts');
        });
      } else {
        TDToast.showText('加载好友列表失败', context: context);
      }
    } catch (error) {
      TDToast.showText('网络错误，请稍后重试', context: context);
      print('加载好友列表出错: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadFriendsList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '聊天',
          style: TextStyle(fontSize: 16),
        ),
        // backgroundColor: const Color.fromARGB(255, 159, 224, 163),
        // foregroundColor: Colors.white,
      ),
      
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return _buildContactItem(contact, context);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          TDToast.showText('添加聊天功能', context: context);
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.message, color: Colors.white),
      ),
    );
  }
  
  // 获取好友之间二者的聊天的信息
  Future<void> _getFriendChatsHistory(String friend) async {
    try {
      final response = await DioClient().post(
        Endpoints.showHistory,
        data: {
          'friend': friend,
        },
      );
      print('接受好友邀请响应: $response');
      if (response.statusCode == 200) {
      } else {
      }
    } catch (error) {
      print('接受好友邀请失败: $error');
    }
  }

  Widget _buildContactItem(Contact contact, BuildContext context) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(contact.avatar),
            onBackgroundImageError: (exception, stackTrace) {
              return;
            },
          ),
          if (contact.unreadCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  contact.unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      
      title: Text(
        contact.name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      
      subtitle: Text(
        contact.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTime(contact.lastMessageTime),
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
          if (contact.unreadCount == 0) ...[
            const SizedBox(height: 4),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
      
      onTap: () {
         // 跳转到聊天页面
         Navigator.push(
           context,
           MaterialPageRoute(
             builder: (context) => ChatView(contact: contact),
           ),
         );
       },
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      // 如果是更早的时间，显示具体日期
      return '${dateTime.month}/${dateTime.day}';
    }
  }
}