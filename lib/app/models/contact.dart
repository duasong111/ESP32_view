// lib/app/models/contact.dart
/// 联系人数据模型
/// 用于存储联系人的基本信息，包括ID、姓名、头像、最后消息等
class Contact {
  final String id;
  final String name;
  final String avatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  Contact({
    required this.id,
    required this.name,
    required this.avatar,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });
}