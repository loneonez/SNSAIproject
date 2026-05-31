import 'package:flutter/material.dart';
import 'package:practice/screen/Home/widget/left_tab.dart';
import 'package:practice/screen/Home/widget/main_sled.dart';
import 'package:practice/screen/common_widget/screen_bottom_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Scaffoldを操作するためのキー（これがあるとプログラムからDrawerを開けます）
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<MainSledState> _mainSledKey = GlobalKey<MainSledState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // キーをセット
      backgroundColor: Colors.black,

      // 1. ここにLeftTabをセットすると、左からスライドできるようになります
      drawer: const LeftTab(),

      // 2. 左上にアイコンを表示するためのAppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 背景を透明に
        elevation: 0, // 影を消す
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              // アイコンをタップした時にDrawerを開く
              _scaffoldKey.currentState?.openDrawer();
            },
            child: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                color: Colors.black,
                size: 20,
              ), // ここを自分のアイコン画像にしてもOK
            ),
          ),
        ),
      ),

      // 3. bodyからは LeftTab() を外して、メインコンテンツだけにします
      // Stackを使って、ボトムバーを上に重ねる形式に調整
      body: Stack(
        children: [
          SafeArea(child: MainSled(key: _mainSledKey)),

          // 前に作ったガラスのボトムバーを一番下に浮かせる
          const Align(
            alignment: Alignment.bottomCenter,
            //child: ScreenBottomBar(),
          ),
        ],
      ),
    );
  }
}
