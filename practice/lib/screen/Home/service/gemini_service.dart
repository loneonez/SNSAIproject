import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  // 動作：文章生成用のGemini 2.5 Flashを設定（画像URLの組み立てもこれ1つでやるよ！）
  final _textModel = GenerativeModel(
    model: 'gemini-2.5-flash',
    apiKey: 'AQ.Ab8RN6JrPIwaHSs75s1j9zJOlPaYLM4Whdx_N9u49GBBsGLtOw',
  );

  // 💡 動作：特定の指示書（プロンプト）をGeminiに送り、返ってきた返信テキストを返す関数
  Future<String?> askGemini(String prompt) async {
    try {
      print("Geminiに返信をリクエスト中...");

      // 動作：引数で受け取ったprompt（指示書）を、Geminiが扱えるContent型に変換します
      final content = [Content.text(prompt)];

      // 動作：Geminiモデルを呼び出して、文章を生成します（2.5-flashが走ります）
      final response = await _textModel.generateContent(content);

      // 動作：生成されたテキストを取り出します
      final responseText = response.text;

      if (responseText != null) {
        print("Geminiからの返信生成に成功しました！");
        return responseText.trim(); // 動作：前後の余計な空白を削って返します
      }
    } catch (e) {
      // 動作：APIキーの期限切れや通信エラーなどのトラブルが起きた場合、ログを出します
      print("Gemini APIエラー: $e");
    }
    return null; // 動作：エラーが起きた場合は空（null）を返します
  }

  // 動作：AI投稿と画像アイコンのURLを同時に生成する関数
  Future<Map<String, dynamic>?> generateAiPost() async {
    print("AI投稿と最適な画像URLを生成中...");

    const textPrompt = """
あなたはSNSのユーザーです。学校生活や日常の出来事について、様々なキャラクターになりきって10〜100文字以内で呟いてください。

また、そのキャラクターの見た目や個性に最もマッチするアバターの「ジャンル（avatar_set）」と「識別番号（seed_number）」を厳選してください。

【アバターのジャンル基準】
・set1: 王道のロボット、メカニック、硬派なキャラ
・set2: ちょっと不気味で可愛いモンスター、異世界系のキャラ
・set3: サイボーグ、近未来、クールなAI・電子系のキャラ
・set4: 可愛い猫、動物、癒やし系、ゆるふわなキャラ

【重要】
出力は、必ず以下のJSON形式のみで返してください。余計な説明や装飾（```json など）は一切不要です。

{
  "name": "名前またはハンドルネーム",
  "role": "性格や背景設定（短く）",
  "post": "投稿内容（なりきった口調）",
  "avatar_set": "上記の基準から厳選した 'set1' 'set2' 'set3' 'set4' のいずれか1つ",
  "seed_number": 厳選した1〜1000の間の整数数字
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

        final String userName = data['name']?.toString() ?? 'user';
        final String iconUrl = _buildAvatarUrl(
          userName: userName,
          avatarSet: data['avatar_set'],
          seedNumber: data['seed_number'],
        );

        print(
          "生成完了！ avatar_set=${data['avatar_set']}, seed=${data['seed_number']}, URL: $iconUrl",
        );

        // 動作：Flutterの画面（MainSled）に渡すデータを返す
        return {
          "name": data['name'],
          "role": data['role'],
          "post": data['post'],
          "icon_url": iconUrl,
        };
      }
    } catch (e) {
      print("GeminiServiceエラー: $e");
    }
    return null;
  }

  // 動作：Geminiが返した avatar_set / seed_number から robohash のURLを組み立てる
  String _buildAvatarUrl({
    required String userName,
    required dynamic avatarSet,
    required dynamic seedNumber,
  }) {
    const validSets = {'set1', 'set2', 'set3', 'set4'};
    var set = avatarSet?.toString().trim() ?? 'set1';
    if (!validSets.contains(set)) {
      set = 'set1';
    }

    int seed;
    if (seedNumber is int) {
      seed = seedNumber;
    } else {
      seed = int.tryParse(seedNumber?.toString() ?? '') ??
          (userName.hashCode.abs() % 1000) + 1;
    }
    seed = seed.clamp(1, 1000);

    // 動作：名前とseedを組み合わせ、同じseedでも別キャラなら別アイコンになるようにする
    final hashSeed = '${userName}_$seed';
    return 'https://robohash.org/$hashSeed?set=$set';
  }
}
