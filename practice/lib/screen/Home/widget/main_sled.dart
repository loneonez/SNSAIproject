import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:practice/screen/Home/service/gemini_service.dart';
import 'package:practice/screen/Home/widget/post_card.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:practice/firebase_options.dart';
import 'package:practice/screen/myProfile/my_profile.dart';

class MainSled extends StatefulWidget {
  const MainSled({super.key});

  @override
  State<MainSled> createState() => MainSledState();
}

class MainSledState extends State<MainSled> {
  // 動作：画面に表示する投稿データのリスト
  final List<Map<String, dynamic>> _posts = [];

  // 動作：切り出したGeminiサービスの実体を作成
  final GeminiService _geminiService = GeminiService();
  void goToFavoriteScreen() {
  // 💡 ここで where を使うよ！
  // 動作：手元にあるすべての投稿（_posts）から、「isFavorite が true」のデータだけを絞り込む
  final List<Map<String, dynamic>> favoritePosts = _posts.where((post) {
    return post['isFavorite'] == true;
  }).toList(); // 動作：絞り込んだ結果をリスト形式に変換する

  // 動作：Navigatorを使って、いいね一覧画面（次の画面）へ画面遷移する
  Navigator.push(
    context,
    MaterialPageRoute(
      // 💡 次の画面の「引数」として、絞り込んだリスト（favoritePosts）をそのまま渡す！
      builder: (context) => MyProfile(likedPosts: [],),
    ),
  );
}

  // 動作：新しくAI投稿を読み込んでリストに追加する関数
  //動作：新しくAIの投稿を生成して、Firebaseに保存する関数
Future<void> fetchNewPost() async {
  // 動作：裏側のGeminiサービスから新しく生成されたAIデータを取得
  final data = await _geminiService.generateAiPost();

  if (data != null) {
    try {
      // 動作：Firestoreの「posts」というコレクション（フォルダ）にデータを新規保存する！
      // 💡 await をつけて、Firebaseへの書き込みが完全に終わるのを待つよ
      await FirebaseFirestore.instance.collection('posts').add({
        "user": data['name'],         // 動作：AIが考えたユーザー名
        "icon": data['icon_url'],     // 動作：アイコンの画像URL
        "content": data['post'],      // 動作：つぶやき本文
        "role": data['role'],         // 動作：キャラクターの性格設定
        "isFavorite": false,          // 動作：いいねの初期状態（お気に入り登録は最初 false）
        // 動作：タイムラインで「新しい順」に並び替えるために、Firebase側のサーバー時間を記録
        "createdAt": FieldValue.serverTimestamp(), 
      });
      
      print("Firebaseへのデータ保存に成功したぜ！");
    } catch (e) {
      // 動作：もしネットに繋がっていないなどの理由で保存できなかったときのエラー表示
      print("Firebase保存エラー: $e");
    }

    // 動作：これまでのアプリ内リストに即時反映させるsetState
    setState(() {
      _posts.insert(0, {
        "user": data['name'],
        "icon": data['icon_url'],
        "content": data['post'],
        "role": data['role'],
        "isFavorite": false,
      });
    });
  }
}

  @override
  void initState() {
    super.initState();
    // 動作：アプリ起動時に自動で1個目の投稿を読み込む
    fetchNewPost();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 動作：AIに呟かせるための最上部の青いボタン
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: ElevatedButton.icon(
            onPressed: fetchNewPost, // 動作：タップでAI生成関数を呼ぶ
            icon: const Icon(Icons.auto_awesome),
            label: const Text('AIに呟かせる'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
            ),
          ),
        ),

        // 動作：タイムラインのリスト表示エリア（Expandedは1つにまとめるよ！）
        Expanded(
          // 🔥 変更点：RefreshIndicator の中に child として ListView を入れる！
          child: RefreshIndicator(
            color: Colors.blueAccent, // 動作：ぐるぐる回るインジケーターの色を青に設定
            backgroundColor: Colors.grey, // 動作：ぐるぐるの背景色をダークモードに合わせる（少し暗くしたよ）
            // 動作：画面を下に引っ張ったときに実行する関数を指定（上のfetchNewPostを呼ぶ）
            onRefresh: () async {
              await fetchNewPost();
            },
            child: ListView.separated(
              // 動作：投稿が少なくても常に引っ張って更新（スクロール）できるようにする設定
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];

                // 🔥 切り出した PostCard を呼び出して組み立てる！
                return PostCard(
                  post: post,
                  // 動作：いいねボタンが押された時の処理をここに書く
                  onFavoriteTap: () {
                    setState(() {
                      post['isFavorite'] = !(post['isFavorite'] ?? false);
                    });
                  },
                  // 動作：アイコンや名前が押されたら、そのAIのプロフ画面へ遷移する処理
                  onUserTap: () {
                    print('${post['user']} さんのプロフ画面へ遷移するよ！');
                    // ここに Navigator.push で LocalUser(userData: post) を呼ぶ処理を書けば繋がるぜ！
                  },
                );
              },
              separatorBuilder: (context, index) =>
                  const Divider(color: Colors.white10),
            ),
          ),
        ),
      ],
    );
  }
}
