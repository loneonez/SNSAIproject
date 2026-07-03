import 'package:flutter/material.dart';
import 'package:flutter_liquid_glass_plus/flutter_liquid_glass.dart';

class ScreenBottomBar extends StatelessWidget {
  const ScreenBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    // 画面の一番下に配置するために、全体をPaddingやAlignで調整します
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30), // 左右と下に余白を作って浮かせます
      child: LiquidGlassLayer(
        settings: const LiquidGlassSettings(
          thickness: 15,
          blur: 15,
        ), // 厚みとボケ具合を調整
        child: LiquidStretch(
          stretch: 0.2, // 押し込みの強さを調整
          interactionScale: 1.02, // 触った時の拡大率
          child: LiquidGlass(
            shape: LiquidRoundedSuperellipse(borderRadius: 25), // 角丸の設定
            child: GlassGlow(
              glowColor: Colors.white10,
              glowRadius: 0.5,
              child: Container(
                height: 70, // バーの高さ
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 左側：メッセージ
                    _buildNavIcon(Icons.mail_outline, "メッセージ"),
                    // 右側：ホーム
                    _buildNavIcon(Icons.home, "ホーム"),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 共通のアイコンボタン作成
  Widget _buildNavIcon(IconData icon, String label) {
    return InkWell(
      onTap: () => print('$labelが押されたよ'),
      child: Icon(icon, color: Colors.white.withOpacity(0.8), size: 28),
    );
  }
}
