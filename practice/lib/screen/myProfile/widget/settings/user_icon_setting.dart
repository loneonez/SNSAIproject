import 'dart:io'; // 💡 動作：スマホ内の写真ファイルを扱うためにインポート
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // 💡 動作：スマホのアルバムを開くためにインポート
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // 💡 動作：選んだ写真をネット上に保存してURL化するためにインポート

class UserIconSetting extends StatefulWidget {
  const UserIconSetting({super.key});

  @override
  State<UserIconSetting> createState() => _UserIconSettingState();
}

class _UserIconSettingState extends State<UserIconSetting> {
  // 💡 動作変更：外部URLの文字列ではなく、選択されたスマホ内の「写真ファイルそのもの」を保存する変数にします
  File? _imageFile;

  // 動作：すでにFirestoreに保存されている現在のアイコンURLを入れておく変数（初期値は空）
  String? _networkIconUrl;

  // 動作：アルバムを開くためのカメラ・写真ツールを用意
  final ImagePicker _picker = ImagePicker();

  // 動作：保存処理中にボタンを連打できないようにするための状態管理フラグ
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // 💡 動作：画面が開いたときに、すでに登録されているアイコンがあればFirestoreから読み込む処理を呼び出します
    _loadCurrentIcon();
  }

  // 💡 動作：現在登録されているユーザーアイコンをFirestoreから安全に読み込む関数
  Future<void> _loadCurrentIcon() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc('yuta_profile')
          .get();
      if (doc.exists && doc.data()?['user_icon_url'] != null) {
        setState(() {
          _networkIconUrl = doc.data()?['user_icon_url'];
        });
      }
    } catch (e) {
      print('現在のアイコン読み込みエラー: $e');
    }
  }

  // 💡 動作：ボタンを押したときにスマホの「アルバム（ギャラリー）」を開いて写真を選ぶ関数
  Future<void> _pickImageFromGallery() async {
    try {
      // 動作：スマホのアルバム画面を開き、ユーザーが写真を選ぶのを待ちます
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500, // 動作：アプリが重くならないように、画像の横幅を最大500pxに自動で縮小します
        maxHeight: 500, // 動作：画像の縦幅を最大500pxに自動で縮小します
        imageQuality: 80, // 動作：画質を少しだけ落として（80%）容量を軽くします
      );

      // 動作：ユーザーが写真をちゃんと選んでくれた場合、画面を更新してプレビュー表示します
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path); // 動作：選ばれた写真のパスをFile型に変換して保存
        });
      }
    } catch (e) {
      print('アルバムを開く際のエラー: $e');
    }
  }

  // 💡 動作：選んだ写真ファイルをFirebase Storageにアップロードし、そのURLをFirestoreに保存する関数
  Future<void> _saveUserIcon() async {
    // 動作：写真が選ばれていない場合は保存処理を進めない
    if (_imageFile == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // ① 動作：Firebase Storageの中に「user_icons/yuta_profile.jpg」という保存先の箱を作ります
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_icons')
          .child('yuta_profile.jpg');

      // ② 動作：スマホ内の写真ファイルを、先ほど作ったFirebaseの箱へアップロードします
      await storageRef.putFile(_imageFile!);

      // ③ 動作：アップロードが完了した写真の「インターネット上のURL（宝の地図）」をパッと取得します
      final String downloadUrl = await storageRef.getDownloadURL();

      // ④ 動作：取得したURLを、Firestoreの「yuta_profile」ドキュメントにしっかり保存します
      await FirebaseFirestore.instance
          .collection('users')
          .doc('yuta_profile')
          .set({
            'user_icon_url': downloadUrl,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      setState(() {
        _networkIconUrl = downloadUrl; // 動作：画面の表示用URLも最新に更新
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('アルバムの写真にアイコンを変更しました！')));
    } catch (e) {
      print('アイコン保存・アップロードエラー: $e');
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'マイアイコン設定',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // 💡 動作：現在のアイコンプレビュー表示エリア（アルバムの写真か、保存済みのネット画像か、無しのアイコンか）
          GestureDetector(
            onTap:
                _pickImageFromGallery, // 動作：丸いアイコン部分をタップしてもアルバムが開くようにする優しい設計！
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[900],
                border: Border.all(color: Colors.blueAccent, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: _imageFile != null
                    ? Image.file(
                        _imageFile!,
                        fit: BoxFit.cover,
                      ) // 🔥 動作：アルバムから新しく選んだ写真があれば最優先で表示！
                    : _networkIconUrl != null
                    ? Image.network(
                        _networkIconUrl!,
                        fit: BoxFit.cover,
                      ) // 動作：すでに保存済みの写真があればそれを表示
                    : const Icon(
                        Icons.add_a_photo,
                        color: Colors.white54,
                        size: 40,
                      ), // 動作：何もないときはカメラプラスのマーク
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 動作：タップを促す案内テキスト
          TextButton.icon(
            onPressed: _pickImageFromGallery,
            icon: const Icon(Icons.photo_library, color: Colors.blueAccent),
            label: const Text(
              'アルバムから写真を選択',
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
          const SizedBox(height: 24),

          // 💡 動作：変更を確定して保存するボタン（写真が選ばれている時だけ押せます）
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: (_isSaving || _imageFile == null)
                  ? null
                  : _saveUserIcon,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                disabledBackgroundColor:
                    Colors.white12, // 動作：写真を選んでない時はボタンをグレーにして半透明化
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
                      'この写真に決定する',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
