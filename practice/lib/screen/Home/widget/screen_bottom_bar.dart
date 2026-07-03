import 'package:flutter/material.dart';
// 動作：リキッドグラスのパッケージをインポート
import 'package:flutter_liquid_glass_plus/flutter_liquid_glass.dart';

class ScreenBottomBar extends StatelessWidget {
  // 動作：外部からタップイベントを受け取る窓口
  final VoidCallback onHomeTap;
  final VoidCallback onPostTap;
  final VoidCallback onNotification;
  final VoidCallback onDmTap;

  const ScreenBottomBar({
    super.key,
    required this.onHomeTap,
    required this.onPostTap,
    required this.onNotification,
    required this.onDmTap,
  });

  @override
  Widget build(BuildContext context) {
    // 動作：最下部のバーとめり込むのを防ぐSafeArea
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12), // 動作：下に絶妙な隙間を作って浮かせる
        child: LiquidGlassLayer(
          // 💡 動作修正：エラーの原因になる「settings:」は一切書かずに、直接childを繋ぎます！
          child: LiquidStretch(
            stretch: 0.2, // 動作：押し込みの強さ
            interactionScale: 1.02, // 動作：触った時の拡大率
            child: LiquidGlass(
              shape: LiquidRoundedSuperellipse(borderRadius: 25), // 動作：角丸スーパー楕円
              child: GlassGlow(
                glowColor: Colors.white10,
                glowRadius: 0.5,
                child: Container(
                  height: 70, // 動作：バーの高さ
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly, // 動作：3つのボタンを均等配置
                    children: [
                      // 1. 左側：ホームボタン
                      IconButton(
                        icon: const Icon(
                          Icons.home_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: onHomeTap,
                      ),

                      // 2. 中央：投稿ボタン（ガラスの上に浮かぶ青い丸）
                      GestureDetector(
                        onTap: onPostTap,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [],
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.notification_add,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: onHomeTap,
                      ),

                      // 3. 右側：DMボタン
                      IconButton(
                        icon: const Icon(
                          Icons.mail_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                        onPressed: onDmTap,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
