import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:flutter/material.dart';

class PrimaryStrokeButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String text;
  
  const PrimaryStrokeButton({
    super.key,
    this.onTap,
    this.text = '描边按钮',
  });

  @override
  Widget build(BuildContext context) {
    return TDButton(
      text: text,
      size: TDButtonSize.large,
      type: TDButtonType.outline,
      shape: TDButtonShape.rectangle,
      theme: TDButtonTheme.primary,
      onTap: onTap 
    );
  }
}