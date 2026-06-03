import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 動作：名前を保存するためにFirestoreをインポート

// 💡 動作：ユーザーの名前を変更するための設定画面（ボトムシートの中身）
class UserNameSetting extends StatefulWidget {
  const UserNameSetting({super.key}); // 🔥 修正点：余計な引数をすべて無くして、シンプルに呼び出せるようにしました！

  @override
  State<UserNameSetting> createState() => _UserNameSettingState();
}

class _UserNameSettingState extends State<UserNameSetting> {
  // 動作：名前の入力欄を管理するためのコントローラー
  final TextEditingController _nameController = TextEditingController();

  // 動作：保存処理中にボタンを連打できないようにするための状態管理フラグ
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // 💡 動作：画面が開いたときに、すでに登録されている名前があればFirestoreから読み込みます
    _loadCurrentName();
  }

  @override
  void dispose() {
    // 動作：画面が閉じられるときにコントローラーを安全に破棄してメモリを解放します
    _nameController.dispose();
    super.dispose();
  }

  // 💡 動作：現在登録されているユーザー名をFirestoreから安全に読み込む関数
  Future<void> _loadCurrentName() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc('my_profile')
          .get();

      if (doc.exists && doc.data()?['user_name'] != null) {
        setState(() {
          // 動作：Firestoreから取得した現在の名前を入力欄に初期値としてセットします
          _nameController.text = doc.data()?['user_name'];
        });
      }
    } catch (e) {
      print('現在の名前の読み込みエラー: $e');
    }
  }

  // 💡 動作：決定ボタンが押された時に、新しく入力された名前をFirestoreに保存する関数
  Future<void> _saveUserName() async {
    final String newName = _nameController.text.trim();
    if (newName.isEmpty) return; // 動作：名前が空っぽなら保存しない

    setState(() {
      _isSaving = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('my_profile')
          .set({
            'user_name': newName,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true)); // merge: true でアイコンや自己紹介を消さずに名前だけを上書き

      // 動作：保存が成功したら、下からふわっと出てきた設定シート（ModalBottomSheet）を自動で閉じます
      Navigator.pop(context);

      // 動作：保存成功のポップアップ（スナックバー）を画面下に表示します
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('名前を更新しました！')));
    } catch (e) {
      print('名前の保存エラー: $e');
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
      // 動作：文字入力時にキーボードが下からズリ上がってきても、入力欄が隠れないように自動でパディングを調整します
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 動作：中身の高さに合わせてシートのサイズを自動調整します
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              '名前設定',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 💡 動作：名前を入力するテキストフィールド
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            maxLength: 20, // 動作：名前は最大20文字までに制限
            decoration: InputDecoration(
              labelText: '新しいユーザー名',
              labelStyle: const TextStyle(color: Colors.grey),
              hintText: '表示したい名前を入力してね',
              hintStyle: const TextStyle(color: Colors.white24),
              counterStyle: const TextStyle(color: Colors.white54),
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
              onPressed: _isSaving ? null : _saveUserName,
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
                      'この名前に決定する',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
