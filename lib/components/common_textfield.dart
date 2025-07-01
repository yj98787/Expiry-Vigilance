import 'package:flutter/material.dart';

class CommonTextfield extends StatelessWidget {
  final String labelText;
  final String hintText;
  final IconData suffixIcon;
  final bool obscureText;
  final TextEditingController controller;
  final VoidCallback? onSuffixTap;

  const CommonTextfield({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.suffixIcon,
    this.obscureText=false,
    required this.controller,
    this.onSuffixTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
            suffixIcon: GestureDetector(
                child: Icon(
                    suffixIcon,
                ),
              onTap: onSuffixTap,
            ),
            label: Text(labelText),
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            )
        ),
      ),
    );
  }
}
