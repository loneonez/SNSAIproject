import 'package:flutter/material.dart';
import 'package:practice/screen/Home/home_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  // 1. finalを外して、後で値を変更できるようにする
  bool _isVisible = false;

  // 2. initStateを使って、画面が表示された瞬間に実行する
  @override
  void initState() {
    super.initState();
    // 画面が描画された直後に実行されるように少しだけ待つ（0.1秒とか）
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        // 画面がまだ存在しているか確認
        setState(() {
          _isVisible = true; // ここで表示をONにする！
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() => _isVisible = true);
      }
    });

    //3秒後に画面をhome_screen.dartに遷移させる
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // 画面の幅を取得（スペルミスがあったから直しておいたよ！）
    final width = MediaQuery.of(context).size.width;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2196F3), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // 背景を透過させてグラデーションを見せる
        body: Center(
          // 文字を中央に置くためにCenterで囲む
          child: AnimatedOpacity(
            opacity: _isVisible ? 1.0 : 0.0,
            duration: const Duration(seconds: 2), // 2秒かけてゆっくり出す
            curve: Curves.easeIn,
            child: const Text(
              'こんにちは',
              style: TextStyle(
                fontSize: 50,
                color: Colors.white, // 青背景に合うように白文字に
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
