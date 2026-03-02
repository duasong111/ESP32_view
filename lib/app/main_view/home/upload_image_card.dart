import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../api/endpoints.dart';

class UploadImageCard extends StatefulWidget {
  final void Function(File image)? onImageSelected;

  const UploadImageCard({
    super.key,
    this.onImageSelected,
  });

  @override
  State<UploadImageCard> createState() => _UploadImageCardState();
}

class _UploadImageCardState extends State<UploadImageCard> {
  final TextEditingController _textController = TextEditingController();
  int _duration = 10;
  bool _scroll = true;
  int _fontSize = 11;
  String _textColor = '#FFBF00';
  String _backgroundColor = '#121212';

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();

    try {
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (file != null) {
        widget.onImageSelected?.call(File(file.path));
      }
    } catch (e) {
      debugPrint('Pick image error: $e');
    }
  }

  Future<void> _sendTextToScreen() async {
    try {
      final url = Uri.parse('${Endpoints.baseUrl}${Endpoints.modifyScreenText}');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'type': 'text',
          'text': _textController.text,
          'duration': _duration,
          'scroll': _scroll,
          'font_size': _fontSize,
          'text_color': _textColor,
          'background_color': _backgroundColor,
        }),
      );
      debugPrint('文字上传响应: ${response.statusCode}');
      if (response.statusCode == 200) {
        debugPrint('文字上传成功: ${response.body}');
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        debugPrint('文字上传失败: ${response.body}');
      }
    } catch (e) {
      debugPrint('发送文字失败: $e');
    }
  }

  void _showTextUploadDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('上传文字'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        labelText: '输入文字',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('滚动'),
                        Switch(
                          value: _scroll,
                          onChanged: (value) {
                            setStateDialog(() {
                              _scroll = value;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('持续时间: $_duration 秒'),
                    Slider(
                      value: _duration.toDouble(),
                      min: 1,
                      max: 60,
                      divisions: 59,
                      onChanged: (value) {
                        setStateDialog(() {
                          _duration = value.toInt();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Text('字体大小: $_fontSize'),
                    Slider(
                      value: _fontSize.toDouble(),
                      min: 8,
                      max: 32,
                      divisions: 24,
                      onChanged: (value) {
                        setStateDialog(() {
                          _fontSize = value.toInt();
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () {
                    if (_textController.text.isNotEmpty) {
                      _sendTextToScreen();
                    }
                  },
                  child: const Text('发送'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showUploadOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('选择上传类型'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.text_fields),
                title: const Text('上传文字'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showTextUploadDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('上传图片'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _showUploadOptions(),
      child: Container(
        width: 380,
        height: 160,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: theme.dividerColor.withOpacity(0.3),
          ),
        ),
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 标题
            Text(
              '上传',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const Spacer(),

            /// 图标 + 提示
            Row(
              children: [
                Container(
                  width: 6,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.upload_outlined,
                  size: 26,
                  color: Colors.purple,
                ),
                const SizedBox(width: 8),
                Text(
                  '选择上传类型',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
