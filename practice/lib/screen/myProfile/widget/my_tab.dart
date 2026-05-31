import 'package:flutter/material.dart';
import 'package:practice/screen/myProfile/widget/profile_icon.dart';

class MyTab extends StatelessWidget {
  const MyTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabBar(
      indicatorColor: Colors.blueAccent, // 選択中の線の色
      labelColor: Colors.white, // 選択中の文字色
      unselectedLabelColor: Colors.grey, // 選択してない文字色
      tabs: [
        Tab(text: '投稿'),
        Tab(text: 'コメント'),
        Tab(text: 'いいね'),
      ],
    );
  }
}
