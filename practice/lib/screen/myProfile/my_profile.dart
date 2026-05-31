import 'package:flutter/material.dart';
import 'package:practice/screen/Home/widget/post_card.dart';
import 'package:practice/screen/myProfile/widget/my_tab.dart';
import 'package:practice/screen/myProfile/widget/profile_icon.dart';
import 'package:practice/screen/myProfile/widget/empty_state_view.dart';

// 💡 動作：マイプロフィール画面（いいねした投稿などを表示する）
class MyProfile extends StatelessWidget {
  // 🔥 変更点1：いいねされた「投稿データのリスト」を受け取る窓口を作る！
  final List<Map<String, dynamic>> likedPosts;


  // 🔥 変更点2：いいねを解除したときに、親画面のリストも更新するための関数（コールバック）を受け取る窓口を作る！
  final Function(Map<String, dynamic>) onFavoriteToggle;

  // 動作：コンストラクタで、上の2つのデータを必須（required）で受け取るようにする
  const MyProfile({
    super.key,
    required this.likedPosts,
    required this.onFavoriteToggle,
    
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 動作：背景は黒で統一
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          // 動作：画面左上に戻るボタン追加
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context), // 動作：前の画面に戻る
        ),
      ),
      body: DefaultTabController(
        length: 3, // 動作：「投稿」「コメント」「いいね」の3つ
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- プロフィール基本情報エリア ---
            const ProfileIcon(),

            const SizedBox(height: 20),

            // --- タブ選択バー ---
            const MyTab(),

            // --- コンテンツエリア（タブの中身） ---
            Expanded(
              child: TabBarView(
                children: [
                  const EmptyStateView(message: 'まだ投稿がありません'), // 動作：投稿用の中身（仮）
                  const EmptyStateView(
                    message: 'まだコメントがありません',
                  ), // 動作：コメント用の中身（仮）
                  // 🔥 変更点3：Collection-If を使って、受け取ったいいねリストが空かどうかで綺麗に分岐！
                  if (favoritePosts.isEmpty)
                    const EmptyStateView(
                      message: 'まだいいねがありません',
                    ) // 動作：いいねした投稿が0件のとき
                  else
                    ListView.builder(
                      itemCount: favoritePosts.length, // 動作：いいねされた件数を指定
                      itemBuilder: (context, index) {
                        // 動作：いいねしたリストの中から、現在の順番のデータを取り出す
                        final post = favoritePosts[index];

                        // 動作：共通のPostCardを使って表示する
                        return PostCard(
                          post: post,
                          // 🔥 変更点4：いいねボタンが押されたら、親から渡された解除用関数を実行する！
                          onFavoriteTap: () => onFavoriteToggle(post),
                          onUserTap: () {
                            // 動作：自分のアイコンタップ時の動き（必要であればここにプロフィールを開くなどの処理を書くよ）
                          },
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
