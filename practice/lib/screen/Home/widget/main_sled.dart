import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:practice/screen/Home/AIpronpt/ai_profiles.dart';

class MainSled extends StatefulWidget {
  const MainSled({Key? key}) : super(key: key);

  @override
  State<MainSled> createState() => MainSledState();
}

class MainSledState extends State<MainSled> {
  // 投稿データの中に、個別の「いいね状態」を持たせるように変更
  // 型を List<Map<String, dynamic>> にすることで bool 値も扱えるようにします
  final List<Map<String, dynamic>> _posts = [];

  Future<void> generativeAipost() async {
    final character = aiCharacters[Random().nextInt(aiCharacters.length)];

    const apikey =
        'AIzaSyAsXpi7IBGIJLZ63cltS1s3IiT6d0P226I'; // セキュリティのため、実際は環境変数などが推奨されます
    final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apikey);

    final prompt =
        '''
あなたは以下のSNSユーザーになりきって投稿してください。
名前：${character.name}
設定：${character.role}

【条件】
・今の気持ちや出来事を140文字以内で1つ呟いてください。
・絵文字も使ってください。
・挨拶から始めず、自然な呟きにしてください。
''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);

      setState(() {
        _posts.insert(0, {
          'user': character.name, // 選ばれたキャラの名前
          'content': response.text ?? '（通信失敗にゃ）',
          'icon': character.icon, // 選ばれたキャラのアイコン
          'isFavorite': false,
        });
      });
    } catch (e) {
      print('エラーが発生したよ: $e');
    }
  }

  // main_sled.dart の MainSledState の中
  @override
  void initState() {
    super.initState();
    // アプリが立ち上がったらすぐにAI投稿を実行する
    generativeAipost();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 動作確認用に投稿ボタンを配置（もし必要なら）
        ElevatedButton(onPressed: generativeAipost, child: const Text('AIで投稿')),
        Expanded(
          child: ListView.separated(
            itemCount: _posts.length,
            itemBuilder: (context, index) {
              final post = _posts[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.black.withOpacity(0.85),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue[50],
                        child: Text(post['icon']!),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post['user']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              post['content']!,
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildIconButton(
                                  Icons.chat_bubble_outline,
                                  Colors.grey[600]!,
                                  () {},
                                ),
                                _buildIconButton(
                                  Icons.repeat,
                                  Colors.grey[600]!,
                                  () {},
                                ),
                                // ハートボタン：状態によってアイコンと色を変える
                                _buildIconButton(
                                  post['isFavorite']
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  post['isFavorite']
                                      ? Colors.pink
                                      : Colors.grey[600]!,
                                  () {
                                    // 押された時の処理
                                    setState(() {
                                      post['isFavorite'] = !post['isFavorite'];
                                    });
                                  },
                                ),
                                _buildIconButton(
                                  Icons.share_outlined,
                                  Colors.grey[600]!,
                                  () {},
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return const Divider(
                color: Colors.white10,
                thickness: 1, //線の太さ
                indent: 20, //左端の余白
                endIndent: 20, //右端の余白
              );
            },
          ),
        ),
      ],
    );
  }

  // タップできるように IconButton を使った補助関数に変更
  Widget _buildIconButton(IconData icon, Color color, VoidCallback onPressed) {
    return IconButton(
      constraints: const BoxConstraints(), // 余白を詰める
      padding: EdgeInsets.zero,
      icon: Icon(icon, size: 18, color: color),
      onPressed: onPressed,
    );
  }
}
