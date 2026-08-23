import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:practice/screen/Home/widget/post_card.dart';
import 'package:practice/screen/Home/service/post_service.dart';

class MainSled extends StatefulWidget {
  const MainSled({super.key});

  @override
  State<MainSled> createState() => MainSledState();
}

class MainSledState extends State<MainSled> {
  // 動作：Firebaseから読み込んだ最新の投稿データを保持するリスト
  List<Map<String, dynamic>> posts = [];

  // 💡 動作：新しく切り出したPostServiceの実体を作成（Firebaseの命令は全部これに丸投げします）
  final PostService _postService = PostService();

  // 動作：いいねされた投稿だけをその場で抽出してリストにして返すゲッター関数
  List<Map<String, dynamic>> get favoritePosts {
    return posts.where((post) => post['isFavorite'] == true).toList();
  }

  // 💡 動作：特定の投稿の「いいね」状態を切り替える関数（中身をService呼び出しにリファクタ！）
  void toggleFavorite(Map<String, dynamic> targetPost) async {
    final bool currenStatus = targetPost['isFavorite'] ?? false;
    await _postService.toggleFavorite(targetPost, currenStatus);
  }

  // 動作：特定の投稿の「共有」状態とカウント数を切り替える関数（※メモリ内処理なので現状維持）
  void toggleShare(Map<String, dynamic> targetPost) {
    setState(() {
      if (targetPost['shareCount'] == null) {
        targetPost['shareCount'] = 0;
      }

      if (targetPost['isShared'] == true) {
        targetPost['isShared'] = false;
        targetPost['shareCount']--;
      } else {
        targetPost['isShared'] = true;
        targetPost['shareCount']++;
      }
    });
  }

  // 動作：try-catch を使ってコメント処理のエラー検知とデータ変化をログ出力する関数
  void toggleCommentDummy(Map<String, dynamic> targetPost) {
    try {
      // 動作：処理開始をデバッグログに出力
      print('🔍 [DEBUG 1] コメントボタンが押されました: ${targetPost['id']}');

      setState(() {
        // 動作：コメントフラグを true に更新
        targetPost['isCommented'] = true;

        // 動作：コメント数を1加算（未設定の場合は0として処理）
        targetPost['commentCount'] = (targetPost['commentCount'] ?? 0) + 1;

        // 動作：吹き出しアイコンの表示切り替え
        targetPost['isChatBubbleOutline'] =
            !(targetPost['isChatBubbleOutline'] ?? false);
      });

      // 動作：更新完了後の投稿データをログに出力して確認
      print('✅ [DEBUG 2] 更新後の投稿データ: $targetPost');
    } catch (e, stackTrace) {
      // 動作：万が一エラーが発生した場合、エラー内容と発生場所をログに出力
      print('❌ [ERROR] toggleCommentDummy でエラーが発生しました: $e');
      print('❌ [STACKTRACE]: $stackTrace');
    }
  }

  // 💡 動作：新しくAIの投稿を生成して、Firebaseに保存する関数（Serviceを呼び出す形に変更！）
  Future<void> fetchNewPost() async {
    // 動作：PostServiceの関数を呼び出して、AI投稿の生成と保存を行わせます
    await _postService.fetchAndSaveNewAiPost();
  }

  @override
  void initState() {
    super.initState();
    // 動作：アプリ起動時に自動で1個目の投稿を読み込むように走らせます
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
            onPressed: fetchNewPost,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('AIに呟かせる'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
            ),
          ),
        ),

        // 動作：タイムラインのリスト表示エリア
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            // 💡 動作：FirebaseFirestore.instanceを直接書くのをやめ、Serviceからストリームを貰う形に変更！
            stream: _postService.getPostsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.blueAccent),
                );
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'データの読み込みに失敗しました。',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'まだ投稿がありません',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              final docs = snapshot.data!.docs;

              // 動作：Firebaseから取得した生データを、Flutterで扱いやすい「posts」リストに詰め替えます
              posts = docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return {
                  "id": doc.id,
                  "user": data['user'] ?? '不明なユーザー',
                  "icon": data['icon'] ?? '',
                  "content": data['content'] ?? '',
                  "role": data['role'] ?? '',
                  "isFavorite": data['isFavorite'] ?? false,
                  "isShared": data['isShared'] ?? false,
                  "shareCount": data['shareCount'] ?? 0,

                  // 💡 動作追加：コメント状態・カウントも Firebase または初期値から読み込むように設定！
                  "isCommented": data['isCommented'] ?? false,
                  "commentCount": data['commentCount'] ?? 0,

                  "createdAt": data['createdAt'],
                };
              }).toList();

              // 動作：投稿をタイムスタンプ（createdAt）が「新しい順」に並び替えます
              posts.sort((a, b) {
                final aTime = a['createdAt'] as Timestamp?;
                final bTime = b['createdAt'] as Timestamp?;
                if (aTime == null) return 1;
                if (bTime == null) return -1;
                return bTime.compareTo(aTime);
              });

              return RefreshIndicator(
                color: Colors.blueAccent,
                backgroundColor: Colors.grey,
                onRefresh: () async {
                  await fetchNewPost();
                },
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];

                    return PostCard(
                      post: post,
                      onFavoriteTap: () => toggleFavorite(post),
                      onShareTap: () => toggleShare(post),

                      // 💡 動作変更：吹き出しアイコンをタップした時に toggleCommentDummy を実行する！
                      onCommentTap: () {
                        toggleCommentDummy(post);
                        print('${post['user']} さんの投稿にコメントしたフラグを立てたよ！');
                      },

                      onUserTap: () {
                        print('${post['user']} さんのプロフ画面へ遷移するよ！');
                      },
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const Divider(color: Colors.white10),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
