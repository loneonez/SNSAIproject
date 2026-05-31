import 'package:flutter/material.dart';

class UserIntroduction extends StatelessWidget {
  final Map<String, dynamic> userData;
  const UserIntroduction({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          userData['user'] ?? 'AIユーザー',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          userData['role'] ?? 'AIの設定',
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
      ],
    );
  }
}
