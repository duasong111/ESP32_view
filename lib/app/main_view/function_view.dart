import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

// 作用是进行声明和被引入
class FunctionView extends StatefulWidget {
  const FunctionView({super.key});

  @override
  State<FunctionView> createState() => _FunctionViewState();
}

// 好友列表吧
class _FunctionViewState extends State<FunctionView> {

  Widget _buildContactTop() {
  final screenWidth = MediaQuery.of(context).size.width;
  final horizontalPadding = screenWidth * 0.001;

  return Padding(
    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10.0),
    child: Column(
      children: [
        // 第一行 - 蓝色背景
        _customCell(
          title: '新的朋友',
          background: Colors.blue,
          textColor: Colors.white,
        ),
        _customCell(title: '群聊', background: const Color.fromARGB(255, 115, 202, 100),
          textColor: Colors.white,),
        _customCell(title: '公众号', background: const Color.fromARGB(255, 240, 240, 240),
          textColor: const Color.fromARGB(255, 111, 151, 183),),
      ],
    ),
  );
}

  // 自定义 cell（替代 TDCell）
  Widget _customCell({
  required String title,
  Color background = Colors.white,
  Color textColor = Colors.black,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15), // ← 这里控制占屏 96%
    child: Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 5),
      child: ListTile(
        title: Text(title, style: TextStyle(color: textColor)),
        trailing: Icon(Icons.chevron_right, color: textColor),
        onTap: () {},
      ),
    ),
  );
}

  
  // 添加水平分割线
  Widget _verticalTextDivider(BuildContext context) {
    return const Wrap(
      runSpacing: 20,
      children: [
        TDDivider(
          text: '好友列表',
          alignment: TextAlignment.left,
        ),
      ],
    );
  }

  // 好友列表卡片
Widget _buildContactList() {
  final screenWidth = MediaQuery.of(context).size.width;
  final horizontalPadding = screenWidth * 0.001;

  return Padding(
    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10.0),
    child: TDCellGroup(
      theme: TDCellGroupTheme.cardTheme,
      cells: [
        TDCell(
          title: '张三',
          arrow: true,
          leftIconWidget: _avatarIcon(),
        ),
        TDCell(
          title: '里斯',
          arrow: true,
          leftIconWidget: _avatarIcon(),
        ),
        TDCell(
          title: '小红',
          arrow: true,
          leftIconWidget: _avatarIcon(),
        ),
      ],
    ),
  );
}


// 统一的头像组件
Widget _avatarIcon() {
  return Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: Colors.blueAccent,
      borderRadius: BorderRadius.circular(6),
    ),
    child: const Icon(Icons.person, color: Colors.white),
  );
}


  // 顶部搜索栏
  Widget _buildFocusSearchBar(BuildContext context) {
    // 获取屏幕宽度
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.03; 
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: TDSearchBar( 
        placeHolder: '搜索', // 占位符改为“搜索”
        needCancel: true,
        autoFocus: false, 
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final verticalSpacerHeight = MediaQuery.of(context).size.height * 0.01;
    return TDTheme(
      data: TDThemeData.defaultData(),
      child: Scaffold(
        appBar: TDNavBar(
          title: '通讯录',
        ),
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(height: verticalSpacerHeight),
            // 搜索栏
            _buildFocusSearchBar(context),
            
            // 功能栏
            _buildContactTop(),
            //水平分割线
            // _verticalTextDivider(context),
            // 好友列表
            _buildContactList(), 
          ],
        ),
      ),
    );
  }
}