import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:practice/screen/Home/service/gemini_service.dart';
import 'package:practice/screen/Home/widget/post_card.dart';

class MainSled extends StatefulWidget {
  const MainSled({super.key});

  @override
  State<MainSled> createState() => MainSledState();
}

class MainSledState extends State<MainSled> {
  // 動作：Firebaseから読み込んだ最新の投稿データを保持するリスト
  List<Map<String, dynamic>> posts = [];

  // 動作：切り出したGeminiサービスの実体を作成
  final GeminiService _geminiService = GeminiService();

  // 動作：いいねされた投稿だけをその場で抽出してリストにして返すゲッター関数
  // 💡 外部（home_screen.dartなど）からアンダーバーなしで安全に呼べるようにしています
  List<Map<String, dynamic>> get favoritePosts {
    return posts.where((post) => post['isFavorite'] == true).toList();
  }

  // 動作：特定の投稿の「いいね」状態をFirebase上で切り替える関数
  // 💡 setStateを使わず、Firebaseを直接更新するだけで、下のStreamBuilderが自動で画面を塗り返してくれます！
  void toggleFavorite(Map<String, dynamic> targetPost) async {
    final String? postId = targetPost['id'];

    if (postId != null) {
      try {
        // 動作：現在のいいねの状態を反転させます
        final bool newFavoriteStatus = !(targetPost['isFavorite'] ?? false);

        // 動作：Firebase（Firestore）の「posts」コレクションの中にあるデータを直接更新します
        await FirebaseFirestore.instance.collection('posts').doc(postId).update(
          {'isFavorite': newFavoriteStatus},
        );

        print("Firebaseのいいね状態を更新しました！");
      } catch (e) {
        print("Firebaseのいいね更新エラー: $e");
      }
    }
  }

  // 動作：特定の投稿の「共有」状態とカウント数を切り替える関数
  // 💡 これも本当はFirebaseを更新するのがベストですが、まずはメモリ上で切り替えます
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

  // 動作：特定の投稿のコメント用のダミー関数
  void toggleCommentDummy(Map<String, dynamic> targetPost) {
    setState(() {
      targetPost['isChatBubbleOutline'] =
          !(targetPost['isChatBubbleOutline'] ?? false);
    });
  }

  // 動作：新しくAIの投稿を生成して、Firebaseに保存する関数
  Future<void> fetchNewPost() async {
    final data = await _geminiService.generateAiPost();

    if (data != null) {
      try {
        // 動作：Firestoreの「posts」というコレクション（フォルダ）にデータを新規保存します
        await FirebaseFirestore.instance.collection('posts').add({
          "user": data['name'],
          "icon": data['icon_url'],
          "content": data['post'],
          "role": data['role'],
          "isFavorite": false, // 動作：いいねの初期状態は未いいね（false）
          "isShared": false,
          "shareCount": 0,
          "createdAt": FieldValue.serverTimestamp(), // 動作：並び替え用のタイムスタンプ
        });
        print("Firebaseへのデータ保存に成功しました！");
      } catch (e) {
        print("Firebase保存エラー: $e");
      }
    }
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

        // 動作：タイムラインのリスト表示エリア（StreamBuilderを使って常にFirebaseを見張ります！）
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            // 💡 動作：Firebaseの「posts」コレクションのデータ更新をリアルタイムに監視する川（Stream）を流します
            stream: FirebaseFirestore.instance.collection('posts').snapshots(),
            builder: (context, snapshot) {
              // 動作：まだ接続中、またはデータが何も届いていない時のローディング表示
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.blueAccent),
                );
              }

              // 動作：もしエラーが発生した場合のエラー表示
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'データの読み込みに失敗しました。',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              }

              // 動作：データが空っぽだった場合の表示
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'まだ投稿がありません',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              // 💡 動作：届いたFirebaseのドキュメント一覧を取得します
              final docs = snapshot.data!.docs;

              // 💡 動作：Firebaseから取得した生データを、Flutterで扱いやすい「posts」リストに詰め替えます
              posts = docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return {
                  "id": doc.id, // 💡 動作：Firebase上のドキュメントID（これがあるからいいねの更新ができます）
                  "user": data['user'] ?? '不明なユーザー',
                  "icon": data['icon'] ?? '',
                  "content": data['content'] ?? '',
                  "role": data['role'] ?? '',
                  "isFavorite":
                      data['isFavorite'] ??
                      false, // 💡 動作：Firebaseに保存されているいいね状態を読み込みます
                  "isShared": data['isShared'] ?? false,
                  "shareCount": data['shareCount'] ?? 0,
                  "createdAt": data['createdAt'],
                };
              }).toList();

              // 💡 動作：投稿をタイムスタンプ（createdAt）が「新しい順」に並び替えます
              posts.sort((a, b) {
                final aTime = a['createdAt'] as Timestamp?;
                final bTime = b['createdAt'] as Timestamp?;
                if (aTime == null) return 1;
                if (bTime == null) return -1;
                return bTime.compareTo(aTime); // 降順
              });

              // 動作：引っ張って更新できるRefreshIndicatorとListViewの組み合わせ
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
                      onCommentTap: () {
                        print('${post['user']} さんの投稿へのコメント画面へ遷移するよ！');
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
