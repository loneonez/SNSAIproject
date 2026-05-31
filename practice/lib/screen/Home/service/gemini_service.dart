import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  // 動作：文章生成用のGemini 2.5 Flashを設定（画像URLの組み立てもこれ1つでやるよ！）
  final _textModel = GenerativeModel(
    model: 'gemini-2.5-flash',
    apiKey: 'AIzaSyA0Z9oAq9ZbFSsFBeB5KZX_rc5friPKt1Y', // 💡 ゆうたくんのAPIキーを入れてね
  );

  // 動作：AI投稿と画像アイコンのURLを同時に生成する関数
  Future<Map<String, dynamic>?> generateAiPost() async {
    print("AI投稿と最適な画像URLを生成中...");

    // 💡 動作：プロンプトの魔改造！GeminiにPicsumの画像ID（1〜1000）をキャラに合わせて選ばせる
    const textPrompt = """
あなたはSNSのユーザーです。学校生活や日常の出来事について、様々なキャラクターになりきって10〜100文字以内で呟いてください。
また、そのキャラクターの見た目（性別、年齢、雰囲気など）に最もマッチする「画像のシリアル番号（1から1000の間の数字）」を1つ厳選してください。
（例：学生っぽい爽やかな人なら1025、犬や動物系なら1062、カフェ好きなら63、などキャラクターの個性に必ず連動させてください）

【重要】
出力は、必ず以下のJSON形式のみで返してください。余計な説明は一切不要です。

{
  "name": "名前またはハンドルネーム",
  "role": "性格や背景設定（短く）",
  "post": "投稿内容（なりきった口調）",
  "image_id": 厳選した1〜1000の数字（※必ず整数で出力してください）
}
""";

    try {
      // 動作：Geminiに投稿のJSONテキストを作らせる
      final textContent = [Content.text(textPrompt)];
      final textResponse = await _textModel.generateContent(textContent);
      final responseText = textResponse.text;

      if (responseText != null) {
        // 動作：マークダウンの不要な飾り（```json）を削る
        final cleanJson = responseText
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();

        // 動作：テキストからJSON（Map型）に変換
        final Map<String, dynamic> data = jsonDecode(cleanJson);

        // 動作：AIが考えてくれた「名前」と「キーワード」を安全に取得
        final String userName = data['name'] ?? 'user';
        final String keyword = data['keyword'] ?? 'cat';

        // 🔥 変更点：名前（userName）とキーワード（keyword）を組み合わせてURLを作る！
        // 💡 仕組み：これで「girl（女の子）」という同じキーワードでも、名前が違えば100%違う見た目の猫ちゃんが生成されるぜ！
        final String roboUrl = 'https://robohash.org/${keyword}_${userName}';

        print("生成完了！ 画像URL: $roboUrl");

        // 動作：Flutterの画面（MainSled）に渡すデータを返す
        return {
          "name": data['name'],
          "role": data['role'],
          "post": data['post'],
          "icon_url": roboUrl, // 動作：名前ごとにユニークになった画像URLをセット！
        };
      }
    } catch (e) {
      print("GeminiServiceエラー: $e");
    }
    return null;
  }
}
