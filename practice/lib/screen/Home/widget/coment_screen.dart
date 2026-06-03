import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:practice/screen/Home/service/gemini_service.dart';

// 動作：特定の投稿に対するコメント一覧の表示と、AIキャラからの返信機能を持つ画面
class CommentScreen extends StatefulWidget {
  final Map<String, dynamic> post; // 💡 動作：タイムラインから渡された親投稿のデータ（idやroleが入っています）

  const CommentScreen({super.key, required this.post});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  // 動作：コメント入力欄をコントロールするためのコントローラー
  final TextEditingController _commentController = TextEditingController();

  // 動作：Geminiサービスを呼び出してAIコメントを生成するための実体
  final GeminiService _geminiService = GeminiService();

  // 動作：送信処理中で連打できないようにするための状態フラグ
  bool _isSending = false;

  // 動作：ユーザーが入力したコメントを保存し、その後AIからの返信を自動トリガーする関数
  Future<void> _sendComment() async {
    final String commentText = _commentController.text.trim();
    if (commentText.isEmpty) return; // 動作：文字が空なら何もしない

    setState(() {
      _isSending = true;
    });

    _commentController.clear(); // 動作：入力欄をクリアする

    final String? postId = widget.post['id'];
    if (postId == null) return;

    try {
      // 💡 1. ユーザー自身のコメントをFirestoreのサブコレクション「comments」に保存します
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .add({
            'user': 'name', // 動作：ログイン中のユーザー名（仮で固定）
            'content': commentText,
            'createdAt': FieldValue.serverTimestamp(),
            'isAi': false, // 動作：ユーザー自身なのでAIフラグはfalse
          });

      // 💡 2. 投稿主であるAIキャラクターのプロンプト（role）を使って、Geminiで自動返信を作成します
      final String aiRole = widget.post['role'] ?? 'フレンドリーな大学生。優しく接してね。';
      final String aiName = widget.post['user'] ?? 'AIアシスタント';

      // 💡 Geminiに送るための指示メッセージ（プロンプト）を作ります
      // キャラクターの個性が活きるよう、キャラクター設定（role）をGeminiに流し込みます
      final String aiPrompt =
          '''
あなたはSNSアプリのキャラクター「$aiName」です。
あなたの性格設定は以下の通りです：
$aiRole

ユーザー（nameくん）から、あなたの投稿に対して以下のコメントが届きました：
「$commentText」

このコメントに対して、あなたのキャラクターの口調や性格を100%守って、優しく自然な短いお返事を1文〜2文で作成してください。
SNSの返信なので、丁寧すぎるよりは、フランクで友達に話しかけるような親近感のある言葉遣いにしてください。
絵文字なども適度に使ってください。
''';

      // 💡 3. GeminiServiceを使って、設定に沿った返信テキストを作ってもらいます
      final String? aiReply = await _geminiService.askGemini(aiPrompt);

      if (aiReply != null) {
        // 💡 4. 生成されたAIの返信を、同じくFirestoreの「comments」に保存します
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .add({
              'user': aiName, // 動作：AIのキャラクター名
              'content': aiReply,
              'createdAt': FieldValue.serverTimestamp(),
              'isAi': true, // 動作：AIなのでtrue
            });
      }
    } catch (e) {
      print('コメント送信、またはAI自動返信エラー: $e');
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? postId = widget.post['id'];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('コメント', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // 💡 動作：元の親投稿を表示するエリア（タイムラインと同じ内容を上に置くことで分かりやすくしています）
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white.withOpacity(0.05),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post['user'] ?? '不明なユーザー',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.post['content'] ?? '',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),

          // 💡 動作：リアルタイムでコメント一覧を監視・表示する StreamBuilder エリア
          Expanded(
            child: postId == null
                ? const Center(
                    child: Text(
                      '読み込みエラー',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .doc(postId)
                        .collection('comments')
                        .orderBy(
                          'createdAt',
                          descending: false,
                        ) // 動作：古いコメントが上、新しいコメントが下
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.blueAccent,
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            '最初のコメントを書いてみよう！',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      final commentDocs = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: commentDocs.length,
                        itemBuilder: (context, index) {
                          final commentData =
                              commentDocs[index].data() as Map<String, dynamic>;
                          final String user = commentData['user'] ?? '不明なユーザー';
                          final String content = commentData['content'] ?? '';
                          final bool isAi = commentData['isAi'] ?? false;

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 動作：ユーザーとAIでアバターの色を変えて見やすくします
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: isAi
                                      ? Colors.pinkAccent
                                      : Colors.blueAccent,
                                  child: Icon(
                                    isAi ? Icons.auto_awesome : Icons.person,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user,
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        content,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),

          // 💡 動作：ボトムのコメント入力欄
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'コメントを入力...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                  _isSending
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.blueAccent,
                          ),
                        )
                      : IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: Colors.blueAccent,
                          ),
                          onPressed: _sendComment,
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 💡 もし未実装なら、gemini_service.dartの中にこれを追加してくださいね
Future<String?> askGemini(String prompt) async {
  try {
    // 💡 gemini-2.5-flashなどのAPIリクエストをここで実行し、返ってきたテキストを返します
    // すでに構築済みのAPIコールロジック（http.postなど）を使ってpromptを送信する処理を書いてみてくださいね
  } catch (e) {
    print("Gemini APIエラー: $e");
    return null;
  }
}
