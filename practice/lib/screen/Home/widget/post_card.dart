import 'package:flutter/material.dart';
import 'package:practice/screen/Home/widget/post_card.dart';
import 'package:practice/screen/localUserProfile/local_user.dart';
import 'package:practice/screen/localUserProfile/widget/user_icon.dart';

// 動作：タイムラインに表示する投稿カード1個分の見た目を担当するWidget
class PostCard extends StatelessWidget {
  final Map<String, dynamic> post; // 動作：表示する1件分の投稿データ
  final VoidCallback onFavoriteTap; // 動作：いいねが押された時の処理
  final VoidCallback onUserTap; // 動作：アイコンや名前が押された時の処理

  const PostCard({
    super.key,
    required this.post,
    required this.onFavoriteTap,
    required this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    //いいねが押されていない場合falseにする
    final bool isFavorite = post['isFavorite'] ?? false;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.black.withOpacity(0.85),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 動作：ユーザーアイコン部分（タップしたらプロフ画面に飛べるようにGestureDetectorで囲む）
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LocalUser(userData: post),
                ),
              ),
              child: UserIcon(userData: post), // 🔥 自作のUserIconをここで綺麗に使い回し！
            ),
            const SizedBox(width: 12),

            // 動作：投稿中身エリア
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 動作：ユーザー名の表示（こちらもタップでプロフに飛べるように）
                  GestureDetector(
                    onTap: onUserTap,
                    child: Text(
                      post['user'] ?? '不明なユーザー',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // 動作：投稿本文
                  Text(
                    post['content'] ?? '',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 12),

                  // 動作：SNS風アクションボタンの一覧
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildIconButton(
                        Icons.chat_bubble_outline,
                        Colors.grey,
                        () {},
                      ),
                      _buildIconButton(Icons.repeat, Colors.grey, () {}),
                      // 動作：いいねボタン（状態によってアイコンと色を切り替える）
                      _buildIconButton(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        isFavorite ? Colors.pink : Colors.grey,
                        onFavoriteTap, // 動作：親から渡されたいいね処理を実行
                      ),
                      _buildIconButton(
                        Icons.share_outlined,
                        Colors.grey,
                        () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 動作：アイコンボタンを生成する補助関数
  Widget _buildIconButton(IconData icon, Color color, VoidCallback onPressed) {
    return IconButton(
      constraints: const BoxConstraints(),
      padding: EdgeInsets.zero,
      icon: Icon(icon, size: 18, color: color),
      onPressed: onPressed,
    );
  }
}
