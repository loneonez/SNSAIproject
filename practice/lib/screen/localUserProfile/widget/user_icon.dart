import 'package:flutter/material.dart';

// 動作：ユーザーの丸型アイコンを表示する「見た目専用」の共通Widget
class UserIcon extends StatelessWidget {
  // 動作：外部からユーザーのデータ（画像URLなど）を受け取るための変数
  final Map<String, dynamic> userData;

  // 動作：コンストラクタ
  const UserIcon({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    // 動作：AIから届いた画像URLを取得
    final String? iconUrl = userData['icon'];

    return CircleAvatar(
      radius: 20, // 動作：タイムラインに最適なサイズ20
      backgroundColor: Colors.grey, // 動作：読み込み前の背景色
      // 動作：丸い形からはみ出さないように画像をクリップ（切り抜き）するWidget
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          20,
        ), // 動作：CircleAvatarのradiusと同じにして丸くする
        child: iconUrl != null && iconUrl.isNotEmpty
            ? Image.network(
                iconUrl,
                width: 40, // 動作：直径（20 × 2）に合わせる
                height: 40, // 動作：直径（20 × 2）に合わせる
                fit: BoxFit.cover, // 動作：隙間なく綺麗に画像をフィットさせる
                // 動作：ネットから画像をダウンロードしている間のローディング表示
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ), // 動作：読み込み中の小さなぐるぐる
                  );
                },
                // 動作：画像の読み込みに失敗した時のエラー表示
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.person,
                    color: Colors.white,
                  ); // 動作：代わりに人型アイコンを出す
                },
              )
            : const Icon(
                Icons.person,
                color: Colors.white,
              ), // 動作：URLが空だった場合の人型アイコン
      ),
    );
  }
}
