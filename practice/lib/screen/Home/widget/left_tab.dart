import 'package:flutter/material.dart';
import 'package:practice/screen/myProfile/my_profile.dart';

class LeftTab extends StatefulWidget {
  const LeftTab({super.key});

  @override
  State<LeftTab> createState() => _LefttabState();
}

class _LefttabState extends State<LeftTab> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black.withOpacity(0.9), // 背景を少し透過させた黒に
      child: Column(
        children: [
          // プロフィールヘッダー部分
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.transparent),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                'ゆうた',
                style: TextStyle(color: Colors.black, fontSize: 12),
              ),
            ),
            accountName: const Text(
              'ゆうたくん',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: const Text('大阪経済大学 / 2年生'), // 状況に合わせて変更してね
          ),

          // メニュー項目一覧
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

          // 下部のログアウトやお知らせ用（必要なら）
          const Divider(color: Colors.white24),
          _buildMenuItem(Icons.exit_to_app, 'ログアウト'),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // メニューの各行を作る補助関数
  Widget _buildMenuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      onTap: () {
        if (title == 'プロフィール') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyProfile()),
          );
        }
        print('$title が押されました');
      },
    );
  }
}
