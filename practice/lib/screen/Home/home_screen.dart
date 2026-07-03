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
      bottomNavigationBar: ScreenBottomBar(
        // 動作：ホームボタンが押されたとき
        onHomeTap: () {
          // 💡 動作解説：今いる画面が HomeScreen なので、新しく push（開く）するのではなく、
          // もし他の画面から戻ってきた時のために、この中身は一旦空っぽ（または一番上までスクロール等）にするのが自然だよ！
          print("ホーム画面にいるので何もしません");
        },

        // 動作：投稿ボタンが押されたとき
        onPostTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PostScreen(),
          ), // 💡 動作：MaterialPageRoute をここでしっかり閉じます
        ),

        onNotification: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NotificationScreen(),
          ), // 💡 動作：MaterialPageRoute をここでしっかり閉じます
        ),

        // 動作：DMボタンが押されたとき
        onDmTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DmScreen(userData: userData),
          ), // 💡 動作：MaterialPageRoute をここでしっかり閉じます
        ),
      ), // 💡 動作：ScreenBottomBar をここで閉じます
      // 動作：左からスライドして出てくるメニュー（LeftTab）
      drawer: LeftTab(
        // 動作：大元のMainSledが準備できていれば、いいねがついた投稿だけを絞り込んで渡します
        likedPosts: _mainSledKey.currentState != null
            ? _mainSledKey.currentState!.posts
                  .where((post) => post['isFavorite'] == true)
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
        // 💡 動作追加：左側のアイコンエリアの横幅を明示的に指定して、中央のtitleスペースを広く確保します
        leadingWidth: 56,

        // --- 1. 左端のアイコンエリア ---
        leading: Padding(
          padding: const EdgeInsets.only(
            left: 12.0,
            top: 8.0,
            bottom: 8.0,
          ), // 動作：左側に少し余白を作ります
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
        // 💡 動作修正：Rowではなく、直接まとめたクローズドな要素として中央に配置します
        title: SizedBox(
          height: 40, // 動作：AppBarの高さに合わせる
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // 動作：ロゴと文字を中央寄せ
            mainAxisSize: MainAxisSize.min, // 動作：中身のサイズにきゅっと縮める
            children: [
              // 動作：ロゴ画像を表示
              Image.asset(
                'assets/ais_home_logo.png', // 💡 動作：直したファイル名
                width: 30, // 動作：並んだ時にバランスの良いサイズに変更
                height: 30,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 6), // 動作：ロゴと文字の間の隙間
              // 動作：アプリ名「Ais」
              const Text(
                'Ais',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18, // 動作：すっきり見えるフォントサイズ
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true, // 動作：Android・iOS問わず、強制的にtitleを画面中央に固定
      ),

      // 動作：メインコンテンツ（タイムライン表示エリア）
      body: Stack(
        children: [
          // 動作：タイムライン本体。キーをセットしてHomeScreenから中身を触れるようにします
          SafeArea(child: MainSled(key: _mainSledKey)),

          const Align(
            alignment: Alignment.bottomCenter,
            // child: ScreenBottomBar(),
          ),
        ],
      ),
    );
  }
}
