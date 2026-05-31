import 'package:flutter/material.dart';
import 'package:practice/screen/common_widget/my_follow_user.dart';

class ProfileIcon extends StatefulWidget {
  const ProfileIcon({super.key});

  @override
  State<ProfileIcon> createState() => _ProfileIconState();
}

class _ProfileIconState extends State<ProfileIcon> {
  // 画面の見た目を動かすためのデータ（ダミー）
  int followingCount = 1; // フォロー数
  int followerCount = 1; // フォロワー数（AIにフォローされると増える想定）

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // アイコンと名前・大学情報の行
          Row(
            children: [
              // 左側に大きなアイコン
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: Text(
                  'ゆうた',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
              const SizedBox(width: 20),
              // その横にネームと所属
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'name',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '大阪経済大学 / 2年生',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 新設：フォロー・フォロワー数表示エリア
          Row(
            children: [
              // フォロー数の表示
              GestureDetector(
                child: Text(
                  '$followingCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(width: 4),

              GestureDetector(
                child: Text(
                  'フォロー',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyFollowUser()),
                  );
                },
              ),

              const SizedBox(width: 20),

              // フォロワー数の表示
              Text(
                '$followerCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                child: Text(
                  'フォロワー',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyFollowUser()),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 15),

          // 動作確認用のテストボタン（見た目だけ動かす用）
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                // ボタンを押したら、AIからフォローされた想定でフォロワーが増える
                followerCount++;
              });
              // 画面の下にポップアップを出す
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🤖 AIユーザーにフォローされました！')),
              );
            },
            icon: const Icon(Icons.bolt),
            label: const Text('【テスト】AIからフォローされる'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
