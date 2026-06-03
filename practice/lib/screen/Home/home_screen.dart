import 'package:flutter/material.dart';
import 'package:practice/screen/Home/widget/left_tab.dart';
import 'package:practice/screen/Home/widget/main_sled.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // 動作：キーを登録
      backgroundColor: Colors.black,

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
      ),

      appBar: AppBar(
        backgroundColor: Colors.transparent, // 動作：背景を透明に
        elevation: 0, // 動作：影を消す
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              // 動作：アイコンをタップした時に、一度画面を再描画してからメニュー（Drawer）を開きます
              // これにより、最新のいいね状態がドロワーメニューにしっかり反映されます
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
      ),

      // 動作：メインコンテンツ（タイムライン表示エリア）
      body: Stack(
        children: [
          // 動作：タイムライン本体。キーをセットしてHomeScreenから中身を触れるようにします
          SafeArea(child: MainSled(key: _mainSledKey)),

          // 動作：前に作ったガラスのボトムバーを一番下に浮かせる（使う場合はコメントアウトを解除してね）
          const Align(
            alignment: Alignment.bottomCenter,
            // child: ScreenBottomBar(),
          ),
        ],
      ),
    );
  }
}
