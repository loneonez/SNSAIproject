import 'package:flutter/material.dart';
import 'package:practice/screen/myProfile/widget/my_profile.dart';

// 動作：画面の左側からスライドして出てくるメニュー（ドロワー）Widget
class LeftTab extends StatefulWidget {
  // 動作：MyProfileへ受け渡すためのデータを大元から受け取る窓口
  final List<Map<String, dynamic>> likedPosts;
  final Function(Map<String, dynamic>) onFavoriteToggle;
  final Function(Map<String, dynamic>) onShareToggle; // 動作：追加
  final Function(Map<String, dynamic>) onChatBubbleOutline; // 動作：追加
  final Function(Map<String, dynamic>) destination; // 動作：追加

  // 動作：コンストラクタで、上の変数を必須（required）で受け取るようにする
  const LeftTab({
    super.key,
    required this.likedPosts,
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
          // 動作：プロフィールヘッダー部分
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.transparent),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                ' name',
                style: TextStyle(color: Colors.black, fontSize: 12),
              ),
            ),
            accountName: const Text(
              'name',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: const Text('大阪経済大学 / 2年生'),
          ),

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
          // 動作：ドロワー（メニュー）を閉じる
          Navigator.pop(context);

          // 動作：画面遷移する時に、親から受け取った本物のデータを MyProfile に全て引き継ぐ！
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyProfile(
                likedPosts: widget.likedPosts,
                onFavoriteToggle: widget.onFavoriteToggle,
                onShareToggle: widget.onShareToggle, // 動作：追加してバトンをつなぐ
                onChatBubbleOutline:
                    widget.onChatBubbleOutline, // 動作：追加してバトンをつなぐ
              ),
            ),
          );
        }
        print('$title が押されました');
      },
    );
  }
}
