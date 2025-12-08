// // lib/api/services/chat_service.dart
// import 'package:dio/dio.dart';
// import '../client/dio_client.dart';
// import '../endpoints.dart';
// import '../../models/chat_message.dart';

// class ChatService {
//   final Dio _dio = DioClient().dio;
//   // 获取聊天消息列表
//   Future<List<ChatMessage>> getMessages() async {
//     try {
//       final resp = await _dio.get(Endpoints.chatList);
//       final List data = resp.data['data'] ?? [];
      
//       // 将API返回的数据转换为 ChatMessage 格式
//       return data.map((e) {
//         return ChatMessage(
//           text: e['content'] ?? '',
//           isMe: e['sender'] == 'me', // 根据 sender 判断是否为本人消息
//           time: DateTime.parse(e['timestamp'] ?? DateTime.now().toIso8601String()),
//         );
//       }).toList();
//     } catch (e) {
//       // 如果API调用失败，返回空列表
//       return [];
//     }
//   }

//   // 发送消息
//   Future<void> sendMessage(String content) async {
//     try {
//       await _dio.post(
//         Endpoints.sendMsg,
//         data: {'content': content},
//       );
//     } catch (e) {
//       // 处理发送失败的情况
//       rethrow;
//     }
//   }
// }