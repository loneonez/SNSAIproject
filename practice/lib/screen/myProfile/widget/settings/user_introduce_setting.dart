import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 動作：自己紹介を保存するためにFirestoreをインポート

class UserIntroduceSetting extends StatefulWidget {
  const UserIntroduceSetting({super.key});

  @override
  State<UserIntroduceSetting> createState() => _UserIntroduceSettingState();
}

class _UserIntroduceSettingState extends State<UserIntroduceSetting> {
  // 動作：自己紹介の入力欄を管理するためのコントローラー
  final TextEditingController _introduceController = TextEditingController();

  // 動作：保存処理中にボタンを連打できないようにするための状態管理フラグ
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // 💡 動作：画面が開いたときに、すでに登録されている自己紹介文があれば読み込む処理を呼び出します
    _loadCurrentIntroduce();
  }

  @override
  void dispose() {
    // 動作：画面が閉じられるときにコントローラーを安全に破棄してメモリを解放します
    _introduceController.dispose();
    super.dispose();
  }

  // 💡 動作：現在登録されている自己紹介文をFirestoreから安全に読み込む関数
  Future<void> _loadCurrentIntroduce() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc('yuta_profile')
          .get();

      if (doc.exists && doc.data()?['introduce'] != null) {
        setState(() {
          // 動作：Firestoreから取得した自己紹介文を入力欄に初期値としてセットします
          _introduceController.text = doc.data()?['introduce'];
        });
      }
    } catch (e) {
      print('現在の自己紹介の読み込みエラー: $e');
    }
  }

  // 💡 動作：決定ボタンが押された時に、新しく入力された自己紹介文をFirestoreに保存する関数
  Future<void> _saveUserIntroduce() async {
    final String newIntroduce = _introduceController.text.trim();

    setState(() {
      _isSaving = true;
    });

    try {
      // 💡 動作：Firestoreの「users/yuta_profile」ドキュメントの「introduce」という項目に保存します
      await FirebaseFirestore.instance
          .collection('users')
          .doc('yuta_profile')
          .set({
            'introduce': newIntroduce,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true)); // merge: true で他の項目（アイコンや名前）を消さずに上書き

      // 動作：保存が成功したら、下からふわっと出てきた設定シート（ModalBottomSheet）を自動で閉じます
      Navigator.pop(context);

      // 動作：保存成功のポップアップ（スナックバー）を画面下に表示します
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('自己紹介を更新しました！')));
    } catch (e) {
      print('自己紹介の保存エラー: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('保存に失敗しました。')));
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // 💡 動作：文字入力時にキーボードが下からズリ上がってきても、入力欄が隠れないように自動でパディングを調整します
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 動作：中身の高さに合わせてシートのサイズを自動調整します
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              '自己紹介設定',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 💡 動作：自己紹介を入力するテキストフィールド（長文対応版）
          TextField(
            controller: _introduceController,
            style: const TextStyle(color: Colors.white),
            maxLines: 4, // 🔥 動作：最大4行まで四角い入力ボックスを縦に広げます
            maxLength: 100, // 🔥 動作：最大100文字までの文字数制限をかけ、右下に「0/100」と自動表示させます
            keyboardType: TextInputType.multiline, // 動作：キーボードに「改行」ボタンを表示させます
            decoration: InputDecoration(
              labelText: '自己紹介文',
              labelStyle: const TextStyle(color: Colors.grey),
              hintText: '趣味や、AI達への挨拶などを自由に書いてね！',
              hintStyle: const TextStyle(color: Colors.white24),
              counterStyle: const TextStyle(
                color: Colors.white54,
              ), // 動作：文字数カウントの文字色
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white24),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 💡 動作：変更を確定して保存するボタン
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveUserIntroduce,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'この内容に決定する',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          const SizedBox(height: 10), // 動作：画面最下部との間に少しだけゆとりを持たせます
        ],
      ),
    );
  }
}
