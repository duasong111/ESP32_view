// lib/widgets/function_lists.dart
import 'package:flutter/material.dart';
// import 'package:tdesign_flutter/tdesign_flutter.dart'; // 一定要加这行！
// 自定义封装，用户传输 功能名称即可
class FunctionLists extends StatelessWidget {
  final List<FunctionItem> items;
  final EdgeInsetsGeometry? padding;

  const FunctionLists({
    super.key,
    required this.items,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        children: items.map((item) => _buildCell(item)).toList(),
      ),
    );
  }

  Widget _buildCell(FunctionItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        margin: const EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          color: item.background,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          // ← 新增：左侧图标
          leading: item.icon != null
              ? Icon(
                  item.icon!,
                  size: 24,
                  color: item.textColor,
                )
              : null,

          title: Text(
            item.title,
            style: TextStyle(
              color: item.textColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),

          trailing: Icon(
            Icons.chevron_right,
            color: item.textColor.withOpacity(0.6),
          ),

          onTap: item.onTap,
        ),
      ),
    );
  }
}

/// 单条数据模型（新增 icon 参数，可选）
class FunctionItem {
  final String title;
  final Color background;
  final Color textColor;
  final IconData? icon;           
  final VoidCallback? onTap;

  FunctionItem({
    required this.title,
    required this.background,
    required this.textColor,
    this.icon,                   
    this.onTap,
  });
}