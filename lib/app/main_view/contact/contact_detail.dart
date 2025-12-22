import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
// 导入聊天页面
import '../chat/chat_view.dart';
import '../../models/contact.dart';

class ContactDetailView extends StatelessWidget {
  final dynamic contact;

  const ContactDetailView({super.key, required this.contact});

  // 构建头部信息区域
  Widget _buildHeaderSection(BuildContext context) {
    // 安全获取数据
    String username = contact['username'] ?? '未知用户';
    String nickname = contact['nickname'] ?? username;
    String avatarUrl = contact['avatar'] ?? '';
    String status = contact['status'] ?? 'offline';
    String signature = contact['signature'] ?? '';
    bool isOnline = status == 'online';

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: avatarUrl.isNotEmpty
                ? Image.network(
                    avatarUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultAvatar();
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      );
                    },
                  )
                : _buildDefaultAvatar(),
          ),
          const SizedBox(height: 16),
          Text(
            nickname,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            isOnline ? '在线' : '离线',
            style: TextStyle(
              fontSize: 14,
              color: isOnline ? Colors.green : Colors.grey,
            ),
          ),
          if (signature.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 32, right: 32),
              child: Text(
                signature,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  // 构建默认头像
  Widget _buildDefaultAvatar() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.person, color: Colors.white, size: 40),
    );
  }

  // 构建操作按钮区域
  Widget _buildActionButtons(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Row(
        children: [
          Expanded(
            child: TDButton(
              text: '发消息',
              theme: TDButtonTheme.primary,
              size: TDButtonSize.large,
              onTap: () {
                // 将dynamic类型的contact转换为Contact对象
                Contact chatContact = Contact(
                  id: contact['id']?.toString() ?? '',
                  name: contact['nickname'] ?? contact['username'] ?? '未知用户',
                  avatar: contact['avatar'] ?? '',
                  lastMessage: '', // 初始化为空
                  lastMessageTime: DateTime.now(), // 当前时间
                  unreadCount: 0, // 初始化为0
                  publicKey: contact['public_key'], // 添加公钥信息
                );
                
                // 跳转到聊天页面
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatView(contact: chatContact),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TDButton(
              text: '视频通话',
              theme: TDButtonTheme.light,
              type: TDButtonType.outline,
              size: TDButtonSize.large,
              onTap: () {
                TDToast.showText('视频通话功能开发中', context: context);
              },
            ),
          ),
        ],
      ),
    );
  }

  // 构建详细信息区域
  Widget _buildDetailInfo(BuildContext context) {
    // 安全获取数据
    String username = contact['username'] ?? '未知用户';
    String userId = contact['id']?.toString() ?? '未知';
    String lastLogin = contact['last_login'] ?? '未知';

    return TDCellGroup(
      theme: TDCellGroupTheme.cardTheme,
      cells: [
        TDCell(
          title: '用户名',
          description: username,
          arrow: false,
        ),
        TDCell(
          title: 'ID',
          description: userId,
          arrow: false,
        ),
        if (contact['last_login'] != null)
          TDCell(
            title: '最后登录',
            description: lastLogin,
            arrow: false,
          ),
      ],
    );
  }


   @override
  Widget build(BuildContext context) {
    return TDTheme(
      data: TDThemeData.defaultData(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: TDNavBar(
          title: '联系人详情',
          backgroundColor: Colors.white,
        ),
        body: ListView(
          padding: const EdgeInsets.only(bottom: 20), // 底部留白
          children: [
            // 头部信息区域
            _buildHeaderSection(context),
            const SizedBox(height: 10),
            
           
            // 详细信息区域
            _buildDetailInfo(context),
            const SizedBox(height: 10),
             // 操作按钮区域
            _buildActionButtons(context),
            const SizedBox(height: 10),
            
            
          ],
        ),
      ),
    );
  }

}