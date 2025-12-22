// lib/modules/home/views/chat_view.dart
import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:io';
import '../../models/contact.dart';
import '../../models/chat_message.dart';
import '../../api/services/auth_service.dart';
import '../../api/endpoints.dart';
import '../../api/client/dio_client.dart';
import '../../utils/encryption_util.dart';

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
  bool _disposed = false; 

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  WebSocket? _socket;
  late AuthService _authService;
  bool _isSocketConnected = false;
  List<Map<String, dynamic>> _friendPublicKeys = [];

  // 获取好友之间的聊天历史记录
  Future<void> _getFriendChatsHistory() async {
    try {
      final response = await DioClient().get(
        Endpoints.showHistory,
        queryParameters: {
          'friend': widget.contact.name,
        },
      );
      print('获取聊天历史记录响应: $response');
      if (response.statusCode == 200) {
        final data = response.data;
        final messages = data['data'] as List<dynamic>;
        final friendPublicKeys = data['friend_public_keys'] as List<dynamic>;
        
        if (mounted) {
          setState(() {
            // 清空现有消息列表
            _messages.clear();
            
            // 添加历史消息
            for (var message in messages) {
              String encryptedText = message['content'] ?? '';
              String sender = message['sender'] ?? '';
              String timeStr = message['timestamp'] ?? DateTime.now().toIso8601String();
              
              // 判断消息是否加密
              bool isEncrypted = false;
              if (message['encryption_method'] != null) {
                String encryptionMethod = message['encryption_method'].toString().toLowerCase();
                isEncrypted = encryptionMethod.contains('asymmetric') || encryptionMethod.contains('symmetric');
              }
              // 兼容旧的encrypted字段
              else if (message['encrypted'] != null) {
                isEncrypted = message['encrypted'] == true;
              }
              
              // 解密消息
              String decryptedText = encryptedText;
              bool isMe = sender == _authService.currentUser.value;
              
              if (isEncrypted) {
                try {
                  decryptedText = EncryptionUtil.decryptMessage(
                    encryptedText,
                    _authService.privateKey.value,
                  );
                } catch (e) {
                  print('解密消息失败: $e');
                  // 如果解密失败，尝试直接使用明文（可能是自己发送的消息）
                  if (!isMe) {
                    print('尝试使用对方公钥解密...');
                    // 这里可以尝试使用对方公钥解密（如果需要）
                  }
                }
              }
              
              _messages.add(ChatMessage(
                text: decryptedText,
                isMe: sender == _authService.currentUser.value,
                time: DateTime.parse(timeStr),
              ));
            }
            
            // 保存对方的公钥
            _friendPublicKeys = friendPublicKeys.cast<Map<String, dynamic>>();
          });
          
          // 自动滚动到底部
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted && _scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      } else {
        if (mounted) {
          TDToast.showText('获取聊天历史记录失败', context: context);
        }
      }
    } catch (error) {
      print('获取聊天历史记录失败: $error');
      if (mounted) {
        TDToast.showText('获取聊天历史记录失败: $error', context: context);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _authService = Get.find<AuthService>();
    _getFriendChatsHistory();
    _initializeWebSocket();
  }

  @override
  void dispose() {
    _disposed = true; 
    _messageController.dispose();
    _scrollController.dispose();
    // _closeWebSocket();
      _socket?.close();        // 只做释放，不 setState
  _socket = null;
    super.dispose();
  }

  // 初始化WebSocket连接
  void _initializeWebSocket() async {
    try {
      print('=== 开始初始化WebSocket连接 ===');
      
      // 从AuthService获取accessToken
      String accessToken = _authService.token.value;
      print('获取到的accessToken: ${accessToken.isEmpty ? '空' : accessToken}');
      
      if (accessToken.isEmpty) {
        String errorMsg = '未登录或登录已过期';
        if (mounted) {
          TDToast.showText(errorMsg, context: context);
        }
        print('WebSocket连接失败: $errorMsg');
        return;
      }

      // 构建WebSocket连接URL
      String baseUrl = Endpoints.baseUrl;
      print('当前API baseUrl: $baseUrl');
      
      // 将http替换为ws，https替换为wss
      String protocol = baseUrl.startsWith('https') ? 'wss' : 'ws';
      String host = baseUrl.replaceFirst(RegExp(r'^https?://'), '');
      String targetUsername = widget.contact.name;
      String websocketUrl = '$protocol://$host/ws/chat/?friend=$targetUsername&token=$accessToken';
      
      print('构建的WebSocket URL: $websocketUrl');
      print('开始尝试WebSocket连接...');

      // 建立WebSocket连接
      _socket = await WebSocket.connect(websocketUrl);
      
      print('WebSocket连接成功!');
      if (mounted) {
        setState(() {
          _isSocketConnected = true;
        });
        TDToast.showText('WebSocket连接成功', context: context);
      }

      // 监听WebSocket消息
      _socket?.listen(
        (message) {
          print('收到WebSocket消息: $message');
          _handleWebSocketMessage(message);
        },
        onError: (error) {
          _handleWebSocketError(error);
        },
        onDone: () {
          _handleWebSocketDone();
        },
        cancelOnError: true,
      );
    } catch (e, stackTrace) {
      String errorMsg = 'WebSocket连接失败: $e';
      TDToast.showText(errorMsg, context: context);
      print('$errorMsg');
      print('错误堆栈: $stackTrace');
    }
  }

  // 处理WebSocket消息
  void _handleWebSocketMessage(dynamic message) {     if (_disposed || !mounted) return;  // 检查widget是否仍然挂载
    
    try {
      // 解析消息JSON
      Map<String, dynamic> messageData = json.decode(message);
      
      // 统一字段映射，兼容不同的字段名
      String encryptedText = messageData['content'] ?? messageData['text'] ?? '';
      String sender = messageData['sender'] ?? '';
      String timeStr = messageData['timestamp'] ?? messageData['time'] ?? DateTime.now().toIso8601String();
      
      // 判断消息是否加密，兼容不同的字段名和格式
      bool isEncrypted = false;
      if (messageData['encryption_method'] != null) {
        String encryptionMethod = messageData['encryption_method'].toString().toLowerCase();
        isEncrypted = encryptionMethod.contains('asymmetric') || encryptionMethod.contains('symmetric');
      }
      // 兼容旧的encrypted字段
      else if (messageData['encrypted'] != null) {
        isEncrypted = messageData['encrypted'] == true;
      }
      
      print('收到WebSocket消息 - 原始数据: $messageData');
      print('收到WebSocket消息 - 加密文本: $encryptedText');
      print('收到WebSocket消息 - 是否加密: $isEncrypted');
      
      // 解密消息
      String decryptedText = encryptedText;
      if (isEncrypted) {
        try {
          decryptedText = EncryptionUtil.decryptMessage(
            encryptedText,
            _authService.privateKey.value,
          );
          print('WebSocket消息解密成功: $decryptedText');
        } catch (e) {
          print('WebSocket消息解密失败: $e');
          // 解密失败时保留原始文本，方便调试
        }
      } else {
        print('WebSocket消息未加密，直接使用: $decryptedText');
      }
      
      print('收到消息: $encryptedText');
      print('是否加密: $isEncrypted');
      print('解密后的消息: $decryptedText');

      // 检查消息是否来自对方
      if (sender == widget.contact.name) {
        setState(() {
          _messages.add(ChatMessage(
            text: decryptedText,
            isMe: false,
            time: DateTime.parse(timeStr),
          ));
        });

        // 自动滚动到底部
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted && _scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      print('处理WebSocket消息失败: $e');
    }
  }

  // 处理WebSocket错误
  void _handleWebSocketError(dynamic error) {
    if (_disposed || !mounted) return;
    setState(() {
        _isSocketConnected = false;
      });
    // if (mounted) {
      
    //   TDToast.showText('WebSocket连接错误: $error', context: context);
    // }
  }

  // 处理WebSocket连接关闭
  void _handleWebSocketDone() {
    print('WebSocket连接已关闭');
    if (_disposed || !mounted) return;  
     setState(() {
        _isSocketConnected = false;
      });
  }

  // 关闭WebSocket连接
  void _closeWebSocket() {
    _socket?.close();
    _socket = null;
    _isSocketConnected = false;
    // setState(() {
    //   _isSocketConnected = false;
    // });
  }

  void _sendMessage() {
  String messageText = _messageController.text.trim();
  if (messageText.isNotEmpty && _isSocketConnected && _socket != null) {
    if (!mounted) return;
    try {
      // 1. 用对方的公钥加密（给对方看的版本）
      // 获取对方的公钥（优先使用widget.contact中的公钥）
      String friendPublicKey = widget.contact.publicKey ?? '';
      String targetUsername = widget.contact.name;
      
      // 如果widget.contact中没有公钥，尝试从_friendPublicKeys中获取（修复键名匹配问题）
      if (friendPublicKey.isEmpty && _friendPublicKeys.isNotEmpty) {
        Map<String, dynamic>? friendKeyData = _friendPublicKeys.firstWhere(
          (item) => item['username'] == targetUsername, // 使用正确的键名
          orElse: () => {},
        );
        friendPublicKey = friendKeyData?['public_key'] ?? '';
      }
      
      print('获取到的对方公钥: ${friendPublicKey.isEmpty ? '空' : friendPublicKey}');
      print('widget.contact中的公钥: ${widget.contact.publicKey ?? '空'}');
      print('friend_public_keys: $_friendPublicKeys');
      print('目标用户名: $targetUsername');
      print('好友列表中的键名: ${_friendPublicKeys.isNotEmpty ? _friendPublicKeys.first.keys : '空'}');
      print('我的公钥: ${_authService.publicKey.value}');
      print('是否登录: ${_authService.isLoggedIn.value}');
      print('当前用户: ${_authService.currentUser.value}');
      
      String encryptedForReceiver = EncryptionUtil.encryptMessage(
        messageText,
        friendPublicKey,
      );

      // 2. 用自己的公钥加密（给自己保存的版本，用于离线重显）
      String encryptedForSender = EncryptionUtil.encryptMessage(
        messageText,
        _authService.publicKey.value,  // 使用 AuthService 中定义的公钥字段
      );

      // 3. 构造后端期望的格式
      Map<String, dynamic> messagePayload = {
        "message": {
          "content": encryptedForReceiver,        // 接收者解密用的
          "senderEncrypted": encryptedForSender,   // 发送者自己存的加密版
          "encryption_method": "asymmetric",      // 明确指定加密方法
        }
      };

      String jsonMessage = json.encode(messagePayload);
      print('发送的JSON消息（符合后端协议）: $jsonMessage');

      _socket?.add(jsonMessage);

      // 本地显示明文（因为是你自己发的）
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: messageText,
            isMe: true,
            time: DateTime.now(),
          ));
        });
        _messageController.clear();
      }

      // 滚动到底部
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && _scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e, stackTrace) {
      print('发送消息失败: $e\n$stackTrace');
      if (mounted) {
        TDToast.showText('发送失败: $e', context: context);
      }
    }
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                backgroundColor:
                    const Color.fromARGB(255, 104, 227, 163), // 微信绿
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

  // 使用websocket去进行连接
  
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
        actions: [
          // WebSocket连接状态指示器
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _isSocketConnected ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  _isSocketConnected ? '在线' : '离线',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isSocketConnected ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
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
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            // 对方头像
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[300],
              backgroundImage: widget.contact.avatar.isNotEmpty
                  ? NetworkImage(widget.contact.avatar)
                  : null,
              child: widget.contact.avatar.isEmpty
                  ? const Icon(Icons.person, color: Colors.white, size: 20)
                  : null,
              // 只有当backgroundImage不为null时才设置onBackgroundImageError
              onBackgroundImageError: widget.contact.avatar.isNotEmpty
                  ? (exception, stackTrace) {
                      // 如果头像加载失败，会自动显示默认头像
                      return;
                    }
                  : null,
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