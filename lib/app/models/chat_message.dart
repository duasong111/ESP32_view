// lib/app/models/chat_message.dart
/// 聊天消息数据模型
/// 用于存储单条聊天消息的信息，包括文本、发送者身份、时间等
class ChatMessage {
  final String text;
  final bool isMe;
  final DateTime time;

  ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
  });
}