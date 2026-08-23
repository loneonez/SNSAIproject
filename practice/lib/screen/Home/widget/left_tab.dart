import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:practice/screen/myProfile/widget/my_profile.dart';

// 動作：画面の左側からスライドして出てくるメニュー（ドロワー）Widget
class LeftTab extends StatefulWidget {
  // 動作：MyProfileへ受け渡すためのデータを大元から受け取る窓口
  final List<Map<String, dynamic>> likedPosts;
  final List<Map<String, dynamic>> commentedPosts;
  final Function(Map<String, dynamic>) onFavoriteToggle;
  final Function(Map<String, dynamic>) onShareToggle; // 動作：追加
  final Function(Map<String, dynamic>) onChatBubbleOutline; // 動作：追加
  final Function(Map<String, dynamic>) destination; // 動作：追加

  // 動作：コンストラクタで、上の変数を必須（required）で受け取るようにする
  const LeftTab({
    super.key,
    required this.likedPosts,
    required this.commentedPosts,
    required this.onFavoriteToggle,
    required this.onShareToggle, // 動作：追加
    required this.onChatBubbleOutline, // 動作：追加
    required this.destination,
  });

  @override
  State<LeftTab> createState() => _LefttabState();
}

class _LefttabState extends State<LeftTab> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black.withOpacity(0.9), // 動作：背景を少し透過させた黒に
      child: Column(
        children: [
          // 💡 動作：Firestoreの 'users/my_profile' をリアルタイムで監視するStreamBuilder
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc('my_profile')
                .snapshots(),
            builder: (context, snapshot) {
              // 動作：データ取得中のデフォルト名
              String currentName = '読み込み中...';

              if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>?;
                // 💡 動作：Firestoreから最新の 'user_name' を取得
                currentName = data?['user_name'] ?? 'ユーザー';
              }

              // 💡 動作：元のきれいなUserAccountsDrawerHeaderのレイアウトの中に最新の名前を埋め込みます
              return UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Colors.transparent),
                // 動作：丸いアイコン画像枠（名前の先頭1文字を表示）
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    currentName.isNotEmpty ? currentName[0] : 'U',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // 💡 動作：リアルタイムで変更された最新のユーザー名を表示！
                accountName: Text(
                  currentName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                // 動作：所属などのサブ情報
                accountEmail: const Text(
                  '大阪経済大学 / 2年生',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            },
          ), // 動作：プロフィールヘッダー部分
          //UserAccountsDrawerHeader(
          //  decoration: const BoxDecoration(color: Colors.transparent),
          //  currentAccountPicture: const CircleAvatar(
          //    backgroundColor: Colors.white,
          //    child: Text(
          //      ' name',
          //      style: TextStyle(color: Colors.black, fontSize: 12),
          //    ),
          //  ),
          //  accountName: const Text(
          //    'name',
          //    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          //  ),
          //  accountEmail: const Text('大阪経済大学 / 2年生'),
          //),

          // 動作：メニュー項目一覧
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(Icons.person_outline, 'プロフィール'),
                _buildMenuItem(Icons.list_alt_outlined, 'リスト'),
                _buildMenuItem(Icons.bookmark_border, 'ブックマーク'),
                _buildMenuItem(Icons.settings_outlined, '設定とプライバシー'),
              ],
            ),
          ),

          // 動作：下部のログアウトやお知らせ用
          const Divider(color: Colors.white24),
          _buildMenuItem(Icons.exit_to_app, 'ログアウト'),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // 動作：メニュー of 各行を作る補助関数
  Widget _buildMenuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      onTap: () {
        if (title == 'プロフィール') {
          try {
            // 動作：プロフィールボタンが押されたことをログに出力
            print('🔍 [DEBUG 3] プロフィールボタンが押されました');

            // 動作：現在 MyProfile に渡そうとしている commentedPosts の中身と件数をログに出力
            print(
              '🔍 [DEBUG 4] 渡す予定の commentedPosts 件数: ${widget.commentedPosts.length}',
            );
            print('🔍 [DEBUG 5] 渡すデータの中身: ${widget.commentedPosts}');

            // 動作：ドロワー（左メニュー）を閉じる
            Navigator.pop(context);

            // 動作：MyProfile 画面へ遷移してデータを渡す
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyProfile(
                  likedPosts: widget.likedPosts, // 動作：いいねリストを渡す
                  commentedPosts: widget.commentedPosts, // 動作：コメント済みリストを渡す
                  onFavoriteToggle: widget.onFavoriteToggle, // 動作：いいね関数を渡す
                  onShareToggle: widget.onShareToggle, // 動作：共有関数を渡す
                  onChatBubbleOutline:
                      widget.onChatBubbleOutline, // 動作：コメント関数を渡す
                ),
              ),
            );
          } catch (e, stackTrace) {
            // 動作：遷移時にエラーが発生した場合にログへ出力
            print('❌ [ERROR] プロフィール遷移時にエラーが発生しました: $e');
            print('❌ [STACKTRACE]: $stackTrace');
          }
        }
        print('$title が押されました');
      },
    );
  }
}
