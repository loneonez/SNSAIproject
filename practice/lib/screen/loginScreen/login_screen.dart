import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// 動作：ログイン・会員登録を行うための仮画面ウィジェット
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 動作：メールアドレスの入力値を管理するコントローラー
  final TextEditingController _emailController = TextEditingController();
  // 動作：パスワードの入力値を管理するコントローラー
  final TextEditingController _passwordController = TextEditingController();
  // 動作：処理中（ぐるぐる表示）かどうかを保持するフラグ
  bool _isLoading = false;

  // 動作：既存アカウントでログインする処理
  Future<void> _signIn() async {
    // 動作：処理を開始するので読み込み状態にする
    setState(() => _isLoading = true);
    try {
      // 動作：入力されたメール・パスワードで Firebase にログインを試みる
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // 動作：ログイン成功したら前の画面へ戻る
      if (mounted) Navigator.pop(context);
    } catch (e) {
      // 動作：失敗した場合は画面下にエラーメッセージを表示する
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ログインエラー: $e')),
        );
      }
    } finally {
      // 動作：処理が終わったら読み込み状態を解除する
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 動作：新しいアカウントを作成する処理
  Future<void> _signUp() async {
    // 動作：処理を開始するので読み込み状態にする
    setState(() => _isLoading = true);
    try {
      // 動作：入力されたメール・パスワードで Firebase に新規アカウントを作る
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // 動作：登録成功したら前の画面へ戻る
      if (mounted) Navigator.pop(context);
    } catch (e) {
      // 動作：失敗した場合は画面下にエラーメッセージを表示する
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('登録エラー: $e')),
        );
      }
    } finally {
      // 動作：処理が終わったら読み込み状態を解除する
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 動作：背景色を黒に設定
      appBar: AppBar(
        title: const Text('ログイン / 会員登録'), // 動作：ヘッダータイトルを設定
        backgroundColor: Colors.transparent, // 動作：アプリバーを透明にする
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // 動作：周囲に余白をつける
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 動作：要素を上下中央に配置
          children: [
            // 動作：メールアドレス入力欄
            TextField(
              controller: _emailController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'メールアドレス',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16), // 動作：入力欄同士のすき間
            // 動作：パスワード入力欄
            TextField(
              controller: _passwordController,
              obscureText: true, // 動作：パスワードを隠し文字にする
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'パスワード',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 32), // 動作：ボタンとのすき間
            // 動作：通信中はインジケーター、通常時はボタンを表示
            _isLoading
                ? const CircularProgressIndicator()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 動作：ログインボタン
                      ElevatedButton(
                        onPressed: _signIn,
                        child: const Text('ログイン'),
                      ),
                      // 動作：新規登録ボタン
                      ElevatedButton(
                        onPressed: _signUp,
                        child: const Text('新規登録'),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}