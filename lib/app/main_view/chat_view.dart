// lib/modules/home/views/chat_view.dart
import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../models/contact.dart';
import '../models/chat_message.dart';


class ChatView extends StatefulWidget {
  final Contact contact;

  const ChatView({super.key, required this.contact});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final List<ChatMessage> _messages = [
    ChatMessage(text: '你好啊！', isMe: false, time: DateTime.now()),
    ChatMessage(text: '测试消息内容', isMe: true, time: DateTime.now()),
    ChatMessage(text: '哇嘿', isMe: false, time: DateTime.now()),
  ];

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add(ChatMessage(
          text: _messageController.text.trim(),
          isMe: true,
          time: DateTime.now(),
        ));
      });
      _messageController.clear();
      
      // 自动滚动到底部
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  // 底部输入栏 - 完美复刻微信 + 纯 TDesign 实现
Widget _buildInputBar() {
  return Container(
    constraints: const BoxConstraints(minHeight: 50),
    decoration: const BoxDecoration(
      color: Color(0xFFF5F5F5), // 微信经典底色
      border: Border(top: BorderSide(color: Color(0xFFDDDDDD), width: 0.5)),
    ),
    padding: EdgeInsets.only(
      left: 12,
      right: 12,
      top: 8,
      bottom: 8 + MediaQuery.of(context).viewInsets.bottom, // 自动顶起键盘
    ),
    child: Row(
      children: [
        const SizedBox(width: 8),
        // 主输入框 - 使用 TDInput（最像微信）
        Expanded(
          child: TDInput(
            controller: _messageController,
            hintText: '输入消息...',
            backgroundColor: Colors.white,
 
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            onChanged: (value) {
              setState(() {}); // 触发重建，控制发送按钮状态
            },
            onSubmitted: (_) => _sendMessage(),
          ),
        ),

        const SizedBox(width: 8),
        if (_messageController.text.trim().isEmpty) ...[
          _buildInputIconButton(TDIcons.add),
        ] else ...[
          TDButton(
            text: '发送',
            size: TDButtonSize.small,
            theme: TDButtonTheme.primary,
            style: TDButtonStyle(
              backgroundColor: const Color.fromARGB(255, 104, 227, 163), // 微信绿

            ),
            onTap: _sendMessage,
          ),
        ],
      ],
    ),
  );
}

// 封装一个小图标按钮（复用）
Widget _buildInputIconButton(IconData icon) {
  return GestureDetector(
    onTap: () {
      if (icon == TDIcons.add) {
        TDToast.showText('打开更多面板', context: context);
      }
    },
    child: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFDDDDDD), width: 0.5),
      ),
      child: Icon(icon, size: 22, color: Colors.grey[700]),
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 8),
            Text(
              widget.contact.name,
               style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      
      body: Column(
        children: [
          // 消息列表
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isMe = message.isMe;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            // 对方头像
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(widget.contact.avatar),
              onBackgroundImageError: (exception, stackTrace) {
                // 如果头像加载失败，显示默认头像
                return;
              },
            ),
            const SizedBox(width: 8),
          ],
          
          // 聊天气泡
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? Colors.green : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          
          if (isMe) ...[
            const SizedBox(width: 8),
            // 我的头像
            const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
}