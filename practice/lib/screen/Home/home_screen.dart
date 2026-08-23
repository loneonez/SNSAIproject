import 'package:flutter/material.dart';
import 'package:practice/screen/DMscreen/dm_screen.dart';
import 'package:practice/screen/Home/widget/left_tab.dart';
import 'package:practice/screen/Home/widget/main_sled.dart';
import 'package:practice/screen/Home/widget/screen_bottom_bar.dart';
import 'package:practice/screen/Notification/Notification_screen.dart';
import 'package:practice/screen/Post/post_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 動作：MainSledState（タイムライン画面の状態）を外から操作・参照するためのキー
  final GlobalKey<MainSledState> _mainSledKey = GlobalKey<MainSledState>();

  // 動作：Scaffold（メニューの開閉など）をプログラムから操作するためのキー
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // 💡 動作：DmScreenに渡すための、ログインしている自分自身のユーザーデータを用意します
  final Map<String, dynamic> userData = {
    'uid': 'my_user_id_123', // 動作：自分の固有ID（Firebase等と連携する時に識別用として使います）
    'name': 'ゆうたくん', // 動作：DM画面で自分の名前に使う表示名
    'iconUrl': 'assets/images/my_icon.png', // 動作：自分のアイコン画像のパス（アセットにある画像など）
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // 動作：キーを登録
      backgroundColor: Colors.black,

      // 💡 動作：画面右下に配置する丸い「新規投稿（＋）」ボタン
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent, // 動作：ボタンの背景色（青色）
        shape: const CircleBorder(), // 動作：丸い形状にセット
        onPressed: () {
          // 動作：ボタンを押したら投稿作成画面（PostScreen）へ移動
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PostScreen()),
          );
        },
        child: const Icon(
          Icons.add, // 動作：プラスアイコン
          color: Colors.white,
          size: 28,
        ),
      ),

      bottomNavigationBar: ScreenBottomBar(
        // 動作：ホームボタンが押されたとき
        onHomeTap: () {
          print("ホーム画面にいるので何もしません");
        },

        // 動作：投稿ボタンが押されたとき
        onPostTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PostScreen()),
        ),

        onNotification: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NotificationScreen()),
        ),

        // 動作：DMボタンが押されたとき
        onDmTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DmScreen(userData: userData)),
        ),
      ),

      // 動作：左からスライドして出てくるメニュー（LeftTab）
      drawer: LeftTab(
        // 動作：大元のMainSledが準備できていれば、いいねがついた投稿だけを絞り込んで渡します
        likedPosts: _mainSledKey.currentState != null
            ? _mainSledKey.currentState!.posts
                  .where((post) => post['isFavorite'] == true)
                  .toList()
            : [],

        commentedPosts: _mainSledKey.currentState != null
            ? _mainSledKey.currentState!.posts
                  .where(
                    (post) =>
                        (post['commentCount'] ?? 0) > 0 ||
                        post['isCommented'] == true,
                  )
                  .toList()
            : [],

        // 動作：お気に入りボタンが押されたとき、大元の toggleFavorite を実行して再描画します
        onFavoriteToggle: (post) {
          _mainSledKey.currentState?.toggleFavorite(post);
          setState(() {});
        },

        // 動作：共有ボタンが押されたとき、大元の toggleShare を実行して再描画します
        onShareToggle: (post) {
          _mainSledKey.currentState?.toggleShare(post);
          setState(() {});
        },

        // 動作：コメント用のダミー関数を実行して再描画します
        onChatBubbleOutline: (post) {
          _mainSledKey.currentState?.toggleCommentDummy(post);
          setState(() {});
        },
        destination: (post) {
          _mainSledKey.currentState?.toggleCommentDummy(post);
          setState(() {});
        },
      ),

      appBar: AppBar(
        backgroundColor: Colors.transparent, // 動作：背景を透明に
        elevation: 0, // 動作：影を消す
        leadingWidth: 56, // 動作：左側のアイコンエリアの幅を確保
        // --- 1. 左端のアイコンエリア ---
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0, top: 8.0, bottom: 8.0),
          child: GestureDetector(
            onTap: () {
              // 動作：アイコンをタップした時にメニュー（Drawer）を開きます
              setState(() {
                _scaffoldKey.currentState?.openDrawer();
              });
            },
            child: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.black, size: 20),
            ),
          ),
        ),

        // --- 2. 中央のロゴ＆アプリ名エリア ---
        title: SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/ais_home_logo.png',
                width: 30,
                height: 30,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 6),
              const Text(
                'Ais',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),

      // 動作：メインコンテンツ（タイムライン表示エリア）
      body: Stack(
        children: [
          SafeArea(child: MainSled(key: _mainSledKey)),
          const Align(alignment: Alignment.bottomCenter),
        ],
      ),
    );
  }
}
