import 'package:flutter/material.dart';
import 'package:practice/screen/DMscreen/dm_screen.dart';

class PosetDmTab extends StatelessWidget {
  final Map<String, dynamic> userData;
  const PosetDmTab({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Row(
      // 縦方向は中央揃えにして、見た目を綺麗に整える
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 左側：「投稿」の文字
        const Text(
          '投稿',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const Spacer(),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DmScreen(userData: userData),
              ),
            );
            print('DM画面への遷移処理をここに書く予定！');
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blueAccent, // ボタンの背景色（青）
              borderRadius: BorderRadius.circular(20), // 丸みをつけてSNSっぽく
            ),
            child: const Row(
              children: [
                Icon(Icons.send, color: Colors.white, size: 16), // 紙飛行機アイコン
                SizedBox(width: 6),
                Text(
                  'DM',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
