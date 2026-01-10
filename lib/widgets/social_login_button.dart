import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final String asset; // path to icon (png)
  final VoidCallback onTap;
  final double size; // allow customizable circle size

  const SocialLoginButton({
    super.key,
    required this.asset,
    required this.onTap,
    this.size = 48, // default 48x48 circle
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        padding: const EdgeInsets.all(8), // icon padding inside circle
        child: ClipOval(
          child: Image.asset(asset, fit: BoxFit.contain),
        ),
      ),
    );
  }
}