import 'package:flutter/material.dart';
import 'package:practice/screen/Home/widget/post_card.dart';
import 'package:practice/screen/myProfile/widget/my_tab.dart';
import 'package:practice/screen/myProfile/widget/profile_icon.dart';
import 'package:practice/screen/myProfile/widget/empty_state_view.dart';

// 💡 動作：各設定画面のファイルをインポートします
import 'package:practice/screen/myProfile/widget/settings/user_icon_setting.dart';
import 'package:practice/screen/myProfile/widget/settings/user_introduce_setting.dart';
import 'package:practice/screen/myProfile/widget/settings/user_name_setting.dart';

// 動作：マイプロフィール画面（自分の投稿・コメント・いいねを表示する）
class MyProfile extends StatelessWidget {
  // 動作：自分の投稿データのリストを受け取る窓口
  final List<Map<String, dynamic>> myPosts;

  // 動作：自分がコメントした投稿データのリストを受け取る窓口
  final List<Map<String, dynamic>> commentedPosts;

  // 動作：いいねされた投稿データのリストを受け取る窓口
  final List<Map<String, dynamic>> likedPosts;

  // 動作：いいねや各アクションが起こったときに、親画面のリストも更新するための関数
  final Function(Map<String, dynamic>) onFavoriteToggle;
  final Function(Map<String, dynamic>) onShareToggle;
  final Function(Map<String, dynamic>) onChatBubbleOutline;

  // 動作：コンストラクタで、上のデータを必須（required）で受け取ります
  const MyProfile({
    super.key,
    this.myPosts = const [],
    this.commentedPosts = const [],
    required this.likedPosts,
    required this.onFavoriteToggle,
    required this.onShareToggle,
    required this.onChatBubbleOutline,
  });

  // 💡 動作：画面右上の「歯車ボタン」が押されたときに、設定メニューを下からフワッと引き出す関数
  void _showSettingsBottomSheet(BuildContext context) {
    // 動作：モーダルボトムシートを表示して全画面設定画面を開きます
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 動作：全画面表示を有効にします
      useSafeArea: true, // 動作：ステータスバー（ノッチ）と被らないように保護します
      backgroundColor: Colors.transparent, // 動作：背景を透明にして角丸デザインを活かします
      builder: (context) {
        // 動作：SafeAreaで上端の時計やバッテリー表示との重なりを防ぎます
        return SafeArea(
          child: Container(
            height:
                MediaQuery.of(context).size.height * 1.0, // 動作：高さを100%に設定します
            clipBehavior: Clip.antiAlias, // 動作：はみ出た要素をきれいに切り抜きます
            decoration: const BoxDecoration(
              color: Color(0xFF161616), // 動作：設定画面全体の背景色を設定します
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(0), // 動作：全画面なので角丸はフラットにします
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent, // 動作：背景はContainerの色を透過させます
              appBar: AppBar(
                backgroundColor: Colors.transparent, // 動作：アプリバーの背景を透明に設定します
                elevation: 0, // 動作：アプリバーの影を消します
                title: const Text(
                  'プロフィール設定', // 動作：設定画面のタイトルを表示します
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                centerTitle: true, // 動作：タイトルを中央寄せにします
                leading: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ), // 動作：閉じるアイコンを表示します
                  onPressed: () => Navigator.pop(context), // 動作：タップしたら設定画面を閉じます
                ),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0), // 動作：全体の周りに余白を作ります
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // 動作：左揃えに配置します
                  children: [
                    // 1. アイコン設定の見出し
                    const Text(
                      '📸 アイコンの変更',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8), // 動作：余白を作ります
                    const UserIconSetting(), // 動作：アイコン変更用のコンポーネントを配置します
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: Colors.white12), // 動作：区切り線を表示します
                    ),

                    // 2. 名前設定の見出し
                    const Text(
                      '👤 名前の変更',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8), // 動作：余白を作ります
                    const UserNameSetting(), // 動作：名前変更用のコンポーネントを配置します
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: Colors.white12), // 動作：区切り線を表示します
                    ),

                    // 3. 自己紹介設定の見出し
                    const Text(
                      '📝 自己紹介の変更',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8), // 動作：余白を作ります
                    const UserIntroduceSetting(), // 動作：自己紹介変更用のコンポーネントを配置します
                    const SizedBox(height: 40), // 動作：最下部に十分な余白を作ります
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
      backgroundColor: Colors.black, // 動作：背景色は黒で統一します
      appBar: AppBar(
        backgroundColor: Colors.black, // 動作：アプリバーの背景も黒に設定します
        elevation: 0, // 動作：影を削除します
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ), // 動作：戻るボタンを表示します
          onPressed: () => Navigator.pop(context), // 動作：タップしたら前の画面に戻ります
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
            ), // 動作：歯車（設定）アイコンを表示します
            onPressed: () =>
                _showSettingsBottomSheet(context), // 動作：設定のボトムシートを開きます
          ),
          const SizedBox(width: 8), // 動作：右端の見た目を調整する余白です
        ],
      ),
      body: DefaultTabController(
        length: 3, // 動作：「投稿」「コメント」「いいね」の3つのタブを準備します
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- プロフィール基本情報エリア ---
            const ProfileIcon(), // 動作：アイコンや名前、フォロー数を表示します

            const SizedBox(height: 20), // 動作：タブとの間の余白を作ります
            // --- タブ選択バー ---
            const MyTab(), // 動作：投稿・コメント・いいねのタブボタンを表示します
            // --- コンテンツエリア（タブの中身） ---
            Expanded(
              child: TabBarView(
                children: [
                  // --------------------------------------------------
                  // 1. 【投稿タブ】自分の投稿リスト
                  // --------------------------------------------------
                  if (myPosts.isEmpty)
                    const EmptyStateView(
                      message: 'まだ投稿がありません', // 動作：自分の投稿が0件のときの表示
                    )
                  else
                    ListView.builder(
                      itemCount: myPosts.length, // 動作：自分の投稿件数を指定します
                      itemBuilder: (context, index) {
                        final post =
                            myPosts[index]; // 動作：インデックスに対応する投稿データを取得します
                        return PostCard(
                          post: post, // 動作：投稿カードにデータを渡します
                          onFavoriteTap: () =>
                              onFavoriteToggle(post), // 動作：いいねタップ時の関数を実行します
                          onShareTap: () =>
                              onShareToggle(post), // 動作：共有タップ時の関数を実行します
                          onCommentTap: () =>
                              onChatBubbleOutline(post), // 動作：コメントタップ時の関数を実行します
                          onUserTap: () {}, // 動作：ユーザータップ時の処理（必要に応じて設定）
                        );
                      },
                    ),

                  // --------------------------------------------------
                  // 2. 【コメントタブ】自分がコメントした投稿リスト
                  // --------------------------------------------------
                  if (commentedPosts.isEmpty)
                    const EmptyStateView(
                      message: 'まだコメントがありません', // 動作：コメント履歴が0件のときの表示
                    )
                  else
                    ListView.builder(
                      itemCount: commentedPosts.length, // 動作：コメントした投稿の件数を指定します
                      itemBuilder: (context, index) {
                        final post =
                            commentedPosts[index]; // 動作：インデックスに対応する投稿データを取得します
                        return PostCard(
                          post: post, // 動作：投稿カードにデータを渡します
                          onFavoriteTap: () =>
                              onFavoriteToggle(post), // 動作：いいねタップ時の関数を実行します
                          onShareTap: () =>
                              onShareToggle(post), // 動作：共有タップ時の関数を実行します
                          onCommentTap: () =>
                              onChatBubbleOutline(post), // 動作：コメントタップ時の関数を実行します
                          onUserTap: () {}, // 動作：ユーザータップ時の処理
                        );
                      },
                    ),

                  // --------------------------------------------------
                  // 3. 【いいねタブ】いいねした投稿リスト
                  // --------------------------------------------------
                  if (likedPosts.isEmpty)
                    const EmptyStateView(
                      message: 'まだいいねがありません', // 動作：いいねした投稿が0件のときの表示
                    )
                  else
                    ListView.builder(
                      itemCount: likedPosts.length, // 動作：いいねした件数を指定します
                      itemBuilder: (context, index) {
                        final post =
                            likedPosts[index]; // 動作：インデックスに対応する投稿データを取得します
                        return PostCard(
                          post: post, // 動作：共通のPostCardを使って表示します
                          onFavoriteTap: () =>
                              onFavoriteToggle(post), // 動作：いいねタップ時の関数を実行します
                          onShareTap: () =>
                              onShareToggle(post), // 動作：共有タップ時の関数を実行します
                          onCommentTap: () =>
                              onChatBubbleOutline(post), // 動作：コメントタップ時の関数を実行します
                          onUserTap: () {}, // 動作：ユーザータップ時の処理
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
