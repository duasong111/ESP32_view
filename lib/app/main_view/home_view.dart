// lib/modules/home/views/home_view.dart
import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../models/contact.dart';
import 'chat_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // 模拟联系人数据
    final List<Contact> contacts = [
      Contact(
        id: '1',
        name: '张三',
        avatar: '',
        lastMessage: '测试消息',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
        unreadCount: 2,
      ),
      Contact(
        id: '2',
        name: '测试2',
        avatar: 'https://via.placeholder.com/150/2196F3/FFFFFF?text=李',
        lastMessage: '内容测试',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
        unreadCount: 0,
      ),
      Contact(
        id: '3',
        name: '王五',
        avatar: 'https://via.placeholder.com/150/FF9800/FFFFFF?text=王',
        lastMessage: '列表内容',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 3)),
        unreadCount: 1,
      ),
      Contact(
        id: '4',
        name: '小红',
        avatar: 'https://via.placeholder.com/150/9C27B0/FFFFFF?text=赵',
        lastMessage: '➕',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
        unreadCount: 0,
      ),
      
    ];

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
      
      body: ListView.builder(
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