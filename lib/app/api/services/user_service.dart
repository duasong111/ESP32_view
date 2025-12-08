// // lib/app/chat_view.dart
// import 'package:flutter/material.dart';
// import './chat_service.dart';
// import '../../models/chat_message.dart';
// class ChatView extends StatefulWidget {
//   @override
//   State<ChatView> createState() => _ChatViewState();
// }

// class _ChatViewState extends State<ChatView> {
//   final _service = ChatService();
//   List<ChatMessage> _msgs = [];
//   bool _loading = false;

//   @override
//   void initState() {
//     super.initState();
//     _load();
//   }

//   Future<void> _load() async {
//     setState(() => _loading = true);
//     try {
//       _msgs = await _service.getMessages();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('加载失败: $e')),
//       );
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('聊天')),
//       body: _loading
//           ? const Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               itemCount: _msgs.length,
//               itemBuilder: (_, i) => ListTile(
//                 title: Text(_msgs[i].text),
//                 subtitle: Text(_msgs[i].isMe ? '我' : '对方'),
//               ),
//             ),
//     );
//   }
// }