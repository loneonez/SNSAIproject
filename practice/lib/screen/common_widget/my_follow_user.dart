import 'package:flutter/material.dart';
import 'package:practice/screen/localUserProfile/local_user.dart';
// ゆうたくんのプロジェクトのパスに合わせてインポートしてね！
// import 'package:practice/widgets/common_widget.dart';

class MyFollowUser extends StatelessWidget {
  const MyFollowUser({super.key});

  @override
  Widget build(BuildContext context) {
    // 動作確認用のダミーデータ（フォロワー1人のリスト）
    final List<Map<String, dynamic>> dummyFollowers = [
      {
        "user": "AIアシスタントにゃん",
        "icon": "🐱",
        "role": "ゆうたくんを応援するAI",
        "content": "今日もFlutterの勉強お疲れ様だにゃ！",
      },
      {
        "user": "ガジェットオタク🤖",
        "icon": "📱",
        "role": "新しい物好きな大学生",
        "content": "iPhone17のカメラマジで最高すぎるわ。",
      },
      {
        "user": "筋トレ部マッスル💪",
        "icon": "🏋️",
        "role": "バルクアップ中の熱血トレーナー",
        "content": "今日もプロテイン飲んだか！？大胸筋を愛せ！",
      },
    ];

    // 空っぽのフォロー中リスト
    final List<Map<String, dynamic>> dummyFollowing = [];

    return DefaultTabController(
      length: 2, // 「フォロー中」「フォロワー」の2つのタブ
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          title: const Text(
            'name',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          // 上部のタブバー
          bottom: const TabBar(
            indicatorColor: Colors.blueAccent,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'フォロー中'),
              Tab(text: 'フォロワー'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // --- 1. フォロー中のリスト ---
            _buildUserList(dummyFollowing, 'まだ誰もフォローしていません'),

            // --- 2. フォロワーのリスト ---
            _buildUserList(dummyFollowers, 'フォロワーはいません'),
          ],
        ),
      ),
    );
  }

  // もしフォロー・フォロワーがいない場合に表示するテキスト
  Widget _buildUserList(List<Map<String, dynamic>> users, String emptyMessage) {
    if (users.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          //ユーザーのアイコン表示
          leading: CircleAvatar(
            backgroundColor: const Color(0xFF2196F3),
            child: Text(
              user['icon'] ?? '👤',
              style: const TextStyle(fontSize: 20),
            ),
          ),
          title: Text(
            user['user'] ?? '不明なユーザー',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            user['role'] ?? '',
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
          // 行全体をタップしたら、そのAIユーザーのプロフ画面に飛ぶ！
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LocalUser(userData: user),
              ),
            );
            print('${user['user']} のプロフへ飛びます');
          },
        );
      },
    );
  }
}
