import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class CommonButton extends StatelessWidget {
  final String text;
  final VoidCallback onPresser;
  const CommonButton({super.key, required this.text, required this.onPresser});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: ElevatedButton(onPressed: onPresser, child: Text(text),),
    );
  }
}
