import 'package:flutter/material.dart';

class EmptyStateView extends StatelessWidget {
  final String message; // 外からメッセージを受け取れるようにする

  const EmptyStateView({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 16,
        ),
      ),
    );
  }
}