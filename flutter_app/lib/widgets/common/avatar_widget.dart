import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../core/constants.dart';

class AvatarWidget extends StatelessWidget {
  final User user;
  final double size;

  const AvatarWidget({super.key, required this.user, this.size = 22});

  @override
  Widget build(BuildContext context) {
    final color =
        Color(avatarPaletteValues[user.id % avatarPaletteValues.length]);
    final initials = user.name
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.42,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
