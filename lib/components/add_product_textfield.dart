import 'package:flutter/material.dart';

class AddProductTextField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final TextEditingController controller;
  final IconData? suffixIcon;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool enabled;
  final bool readOnly;
  final int maxLines;

  const AddProductTextField(
      {super.key,
        required this.labelText,
        required this.hintText,
        required this.controller,
        this.suffixIcon,
        this.onPressed,
        this.icon,
        this.enabled = true,
        this.readOnly = false,
        this.maxLines = 1,
      });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        maxLines: 1,
        readOnly: readOnly,
        controller: controller,
        decoration: InputDecoration(
          label: Text(labelText),
          hintText: hintText,
          enabled: enabled,
          suffixIcon: suffixIcon != null
              ? Icon(suffixIcon)
              : icon != null
              ? IconButton(
            onPressed: onPressed,
            icon: Icon(icon),
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),

        ),
      ),
    );
  }
}

