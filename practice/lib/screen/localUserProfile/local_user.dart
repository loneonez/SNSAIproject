import 'package:flutter/material.dart';
import 'package:practice/screen/DMscreen/dm_screen.dart';
import 'package:practice/screen/localUserProfile/widget/poset_dm_tab.dart';
import 'package:practice/screen/localUserProfile/widget/user_icon.dart';
import 'package:practice/screen/localUserProfile/widget/user_introduction.dart';

class LocalUser extends StatelessWidget {
  final Map<String, dynamic> userData;

  const LocalUser({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- プロフィール基本情報エリア ---
          GestureDetector(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  UserIcon(userData: userData),
                  const SizedBox(width: 20),
                  Expanded(child: UserIntroduction(userData: userData)),
                ],
              ),
            ),
            onTap: () {
              // 動作：Navigator.push ではなく showDialog を使ってポップアップを表示！
              showDialog(
                context: context,
                barrierDismissible: true, // 動作：背景（暗い部分）をタップしたら閉じる
                builder: (BuildContext context) {
                  return Center(
                    child: Dialog(
                      backgroundColor:
                          Colors.transparent, // 動作：背景を透明にして丸い画像だけを目立たせる
                      elevation: 0,
                      child: GestureDetector(
                        onTap: () =>
                            Navigator.pop(context), // 動作：大きく表示された画像をもう一度タップで閉じる
                        child: Container(
                          width: 260, // 動作：中央に大きく表示するサイズ
                          height: 260,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, // 動作：真ん丸にする
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ), // 動作：白いフチを付ける
                            image: DecorationImage(
                              image: NetworkImage(
                                userData['icon'] ?? '',
                              ), // 動作：AIから届いたURLを表示
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 10),

          // 「投稿」という見出しだけをシンプルに配置
          // --- 動作：プロフィール画面の見出しとDMボタンの配置エリア ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: PosetDmTab(userData: userData),
          ),

          const Divider(color: Colors.white24, height: 1), // 区切り線
          // --- コンテンツエリア（投稿リストのみ！） ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  color: Colors.white10,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      userData['content'] ?? '過去の投稿はありません',
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
