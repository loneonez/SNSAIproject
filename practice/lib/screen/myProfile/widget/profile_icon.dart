import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:practice/screen/common_widget/my_follow_user.dart'; // 動作：フォロー一覧画面への遷移で使用

class ProfileIcon extends StatefulWidget {
  const ProfileIcon({super.key});

  @override
  State<ProfileIcon> createState() => _ProfileIconState();
}

class _ProfileIconState extends State<ProfileIcon> {
  @override
  Widget build(BuildContext context) {
    // 💡 動作①：まずは一番外側で、自分の「基本情報（名前・自己紹介・アイコンURL）」をリアルタイム監視
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc('my_profile')
          .snapshots(),
      builder: (context, userSnapshot) {
        // 動作：データが届くまでの初期値（セーフティネット）
        String userName = '読み込み中';
        String introduceText = '自己紹介がありません';
        String iconUrl = 'https://robohash.org/my_user';

        // 動作：基本情報データが安全に届いたら変数の中身を更新
        if (userSnapshot.hasData && userSnapshot.data!.exists) {
          final data = userSnapshot.data!.data() as Map<String, dynamic>;
          userName = data['user_name'] ?? '名前未設定';
          introduceText = data['introduce'] ?? '自己紹介がありません';
          iconUrl = data['user_icon_url'] ?? iconUrl;
        }

        // 💡 動作②：次に内側で、自分の「following（フォロー中）」コレクションをリアルタイム監視
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc('my_profile')
              .collection('following')
              .snapshots(),
          builder: (context, followingSnapshot) {
            int followingCount = 0;
            if (followingSnapshot.hasData) {
              // 動作：フォロー中のドキュメント数をカウント
              followingCount = followingSnapshot.data!.docs.length;
            }

            // 💡 動作③：さらに内側で、自分の「followers（フォロワー）」コレクションをリアルタイム監視
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc('my_profile')
                  .collection('followers')
                  .snapshots(),
              builder: (context, followerSnapshot) {
                int followerCount = 0;
                if (followerSnapshot.hasData) {
                  // 動作：フォロワーのドキュメント数をカウント
                  followerCount = followerSnapshot.data!.docs.length;
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white12,
                            backgroundImage: NetworkImage(
                              iconUrl,
                            ), // 動作：最新のプロフィール画像を表示
                          ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '大阪経済大学 / 2年生',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 動作：自己紹介文の表示
                      Text(
                        introduceText,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          // --- フォロー数の数字 ---
                          Text(
                            '$followingCount', // 動作：リアルタイムにカウントされた数字を反映
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            child: const Text(
                              'フォロー',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            onTap: () {
                              // 動作：タップしたらフォロー一覧画面へ遷移
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MyFollowUser(),
                                ),
                              );
                            },
                          ),

                          const SizedBox(width: 20),

                          // --- フォロワー数の数字 ---
                          Text(
                            '$followerCount', // 動作：リアルタイムにカウントされた数字を反映
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            child: const Text(
                              'フォロワー',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            onTap: () {
                              // 動作：タップしたらフォロワー一覧画面へ遷移
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MyFollowUser(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ); // 💡 動作：④のレイアウトの閉じ括弧
              },
            ); // 💡 動作：③のフォロワー監視の閉じ括弧
          },
        ); // 💡 動作：②のフォロー中監視の閉じ括弧
      },
    ); // 💡 動作：①のユーザー基本情報監視の閉じ括弧
  }
}
