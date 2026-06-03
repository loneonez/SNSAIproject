import 'package:flutter/material.dart';
import 'package:practice/screen/Home/widget/post_card.dart';
import 'package:practice/screen/myProfile/widget/my_tab.dart';
import 'package:practice/screen/myProfile/widget/profile_icon.dart';
import 'package:practice/screen/myProfile/widget/empty_state_view.dart';

// 💡 動作：各設定画面のファイルをインポートします（ファイル名は実際のフォルダ構造に合わせているよ！）
import 'package:practice/screen/myProfile/widget/settings/user_icon_setting.dart';
import 'package:practice/screen/myProfile/widget/settings/user_introduce_setting.dart';
import 'package:practice/screen/myProfile/widget/settings/user_name_setting.dart';

// 動作：マイプロフィール画面（いいねした投稿などを表示する）
class MyProfile extends StatelessWidget {
  // 動作：いいねされた「投稿データのリスト」を受け取る窓口
  final List<Map<String, dynamic>> likedPosts;

  // 動作：いいねを解除したときに、親画面のリストも更新するための関数
  final Function(Map<String, dynamic>) onFavoriteToggle;
  final Function(Map<String, dynamic>) onShareToggle; // 動作：追加
  final Function(Map<String, dynamic>) onChatBubbleOutline;

  // 動作：コンストラクタで、上のデータを必須（required）で受け取る
  const MyProfile({
    super.key,
    required this.likedPosts,
    required this.onFavoriteToggle,
    required this.onShareToggle, // 動作：追加
    required this.onChatBubbleOutline,
  });

  // 💡 動作：画面右上の「歯車ボタン」が押されたときに、設定メニューを下からフワッと引き出す関数
  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 動作：キーボードが出たときに設定画面が上にずり上がって潰れないようにする
      backgroundColor: const Color(0xFF161616), // 動作：高級感のあるダークグレーの背景色
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ), // 動作：シートの上の角を丸くする
      ),
      builder: (context) {
        // 動作：キーボードに隠れないように下部に余白を自動追加
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 動作：シートの一番上のバー（引っ張って閉じる用のインジケータ風デザイン）
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Center(
                    child: Text(
                      'プロフィール設定',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 💡 動作：レイアウトを任せてもらったので、崩れないように設定項目を「縦1列」にゆったり並べました！
                  // 1. アイコン設定エリア
                  const Text(
                    '📸 アイコンの変更',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const UserIconSetting(), // 動作：アルバムから選ぶ写真設定Widget

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: Colors.white12), // 動作：区切り線
                  ),

                  // 2. 名前設定エリア
                  const Text(
                    '👤 名前の変更',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const UserNameSetting(), // 動作：20文字制限の名前設定Widget

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: Colors.white12), // 動作：区切り線
                  ),

                  // 3. 自己紹介設定エリア
                  const Text(
                    '📝 自己紹介の変更',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const UserIntroduceSetting(), // 動作：100文字制限の自己紹介設定Widget

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

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
        // 🔥 動作追加：AppBarの右側（actions）に設定用の歯車マークを設置！
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () =>
                _showSettingsBottomSheet(context), // 動作：タップしたら設定シートを開く
          ),
          const SizedBox(width: 8), // 動作：右端のちょっとした余白調整
        ],
      ),
      body: DefaultTabController(
        length: 3, // 動作：「投稿」「コメント」「いいね」の3つ
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- プロフィール基本情報エリア ---
            const ProfileIcon(),

            // 💡 動作変更：画面がガチャガチャに崩れていた設定エリアを丸ごと消去し、スッキリした元のレイアウトに戻しました！
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
                  // 動作：Collection-If を使って、受け取ったいいねリストが空かどうかで綺麗に分岐！
                  if (likedPosts.isEmpty)
                    const EmptyStateView(
                      message: 'まだいいねがありません',
                    ) // 動作：いいねした投稿が0件のとき
                  else
                    ListView.builder(
                      itemCount: likedPosts.length, // 動作：いいねされた件数を指定
                      itemBuilder: (context, index) {
                        // 動作：いいねしたリストの中から、現在の順番のデータを取り出す
                        final post = likedPosts[index];

                        // 動作：共通のPostCardを使って表示する（窓口をすべて埋める）
                        return PostCard(
                          post: post,
                          onFavoriteTap: () => onFavoriteToggle(post),
                          onShareTap: () => onShareToggle(post), // 動作：追加
                          onCommentTap: () =>
                              onChatBubbleOutline(post), // 動作：名前を合わせて修正
                          onUserTap: () {
                            // 動作：自分のアイコンタップ時の動き
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
