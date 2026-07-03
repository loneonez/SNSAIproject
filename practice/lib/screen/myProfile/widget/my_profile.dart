import 'package:flutter/material.dart';
import 'package:practice/screen/Home/widget/post_card.dart';
import 'package:practice/screen/myProfile/widget/my_tab.dart';
import 'package:practice/screen/myProfile/widget/profile_icon.dart';
import 'package:practice/screen/myProfile/widget/empty_state_view.dart';

// 💡 動作：各設定画面のファイルをインポートします
import 'package:practice/screen/myProfile/widget/settings/user_icon_setting.dart';
import 'package:practice/screen/myProfile/widget/settings/user_introduce_setting.dart';
import 'package:practice/screen/myProfile/widget/settings/user_name_setting.dart';

// 動作：マイプロフィール画面（いいねした投稿などを表示する）
class MyProfile extends StatelessWidget {
  // 動作：いいねされた「投稿データのリスト」を受け取る窓口
  final List<Map<String, dynamic>> likedPosts;

  // 動作：いいねや各アクションが起こったときに、親画面のリストも更新するための関数
  final Function(Map<String, dynamic>) onFavoriteToggle;
  final Function(Map<String, dynamic>) onShareToggle;
  final Function(Map<String, dynamic>) onChatBubbleOutline;

  // 動作：コンストラクタで、上のデータを必須（required）で受け取る
  const MyProfile({
    super.key,
    required this.likedPosts,
    required this.onFavoriteToggle,
    required this.onShareToggle,
    required this.onChatBubbleOutline,
  });

  // 💡 動作：画面右上の「歯車ボタン」が押されたときに、設定メニューを下からフワッと引き出す関数
  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 動作：全画面表示を有効にする設定です
      useSafeArea: true, // 💡 動作：全画面になっても、スマホのステータスバー（ノッチ）の下から表示するように守ります！
      backgroundColor: Colors.transparent, // 背景を透明にして下のContainerの角丸を活かします
      builder: (context) {
        // 💡 動作：全体を SafeArea で包むことで、上端のバッテリーや時計の表示部分と絶対に被らないようにします
        return SafeArea(
          child: Container(
            height:
                MediaQuery.of(context).size.height *
                1.0, // 動作：高さを100%にして、前の画面のぞき見えを防止します
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              color: Color(0xFF161616), // 設定画面の背景色
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(0),
              ), // 動作：全画面なので角丸はフラットに
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent, // 背景はContainerの色を活かす
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text(
                  'プロフィール設定',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  // 動作：バツボタンを押したら、設定のボトムシートを pop（閉じる）して元のプロフ画面に戻ります
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. アイコン設定
                    const Text(
                      '📸 アイコンの変更',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const UserIconSetting(),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: Colors.white12),
                    ),

                    // 2. 名前設定
                    const Text(
                      '👤 名前の変更',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const UserNameSetting(),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: Colors.white12),
                    ),

                    // 3. 自己紹介設定
                    const Text(
                      '📝 自己紹介の変更',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const UserIntroduceSetting(),
                    const SizedBox(height: 40),
                  ],
                ),
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
          // 動作：画面左上に戻るボタン
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context), // 動作：ホーム画面に戻る
        ),
        // 🔥 動作スッキリ：右側には、上で定義した _showSettingsBottomSheet を呼び出すだけのシンプルな処理に！
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => _showSettingsBottomSheet(
              context,
            ), // 💡 動作：これだけで上で作った全画面設定が綺麗に開きます！
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

                        // 動作：共通のPostCardを使って表示する
                        return PostCard(
                          post: post,
                          onFavoriteTap: () => onFavoriteToggle(post),
                          onShareTap: () => onShareToggle(post),
                          onCommentTap: () => onChatBubbleOutline(post),
                          onUserTap: () {},
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
