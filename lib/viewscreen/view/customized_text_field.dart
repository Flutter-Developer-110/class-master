import 'package:flutter/material.dart';

class CustomizedTextField extends StatelessWidget {
  final String hintText;
  final String labelText;
  final TextEditingController controller;
  final bool isPassword;
  final IconData suffixIcon;
  final VoidCallback iconPressed;

  const CustomizedTextField({
    Key? key,
    required this.hintText,
    required this.labelText,
    required this.controller,
    required this.isPassword,
    required this.suffixIcon,
    required this.iconPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText, 
        suffixIcon: IconButton(onPressed:iconPressed , icon: Icon(suffixIcon)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
