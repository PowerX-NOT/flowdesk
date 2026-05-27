import 'package:flutter/material.dart';

/// FlowDesk brand mark — matches launcher icon (`assets/images/app_icon.png`).
class FlowDeskLogo extends StatelessWidget {
  const FlowDeskLogo({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.27),
      child: Image.asset(
        'assets/images/app_icon.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}
