import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// 💡 動作：新しく作ったCommentServiceを使えるようにインポートします
import 'package:practice/screen/Home/service/comment_service.dart';
import 'package:practice/screen/localUserProfile/widget/user_icon.dart';

// 動作：特定の投稿に対するコメント一覧の表示と、AIキャラからの返信機能を持つ画面
class CommentScreen extends StatefulWidget {
  final Map<String, dynamic> post; // 動作：タイムラインから渡された親投稿のデータ

  const CommentScreen({super.key, required this.post});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  // 動作：コメント入力欄をコントロールするためのコントローラー
  final TextEditingController _commentController = TextEditingController();

  // 💡 動作：新しく切り出したCommentServiceの実体を作成
  final CommentService _commentService = CommentService();

  // 動作：送信処理中で連打できないようにするための状態フラグ
  bool _isSending = false;

  // 💡 動作：ユーザーが入力したコメントを送信する関数（中身をService呼び出しにスッキリ変更！）
  Future<void> _sendComment() async {
    final String commentText = _commentController.text.trim();
    if (commentText.isEmpty) return; // 動作：文字が空なら何もしない

    setState(() {
      _isSending = true;
    });

    _commentController.clear(); // 動作：入力欄をクリアする

    final String? postId = widget.post['id'];
    if (postId == null) {
      setState(() {
        _isSending = false;
      });
      return;
    }

    try {
      // 💡 動作：親投稿からAIキャラクターの情報を取り出します
      final String aiRole = widget.post['role'] ?? 'フレンドリーな大学生。優しく接してね。';
      final String aiName = widget.post['user'] ?? 'AIアシスタント';
      final String aiIconUrl =
          widget.post['icon_url'] ?? 'https://robohash.org/ai_default';

      // 💡 動作：CommentServiceを呼び出して、コメントの保存からAIの自動返信までをすべて丸投げします！
      await _commentService.postCommentAndAiReply(
        postId: postId,
        commentText: commentText,
        aiName: aiName,
        aiRole: aiRole,
        aiIconUrl: aiIconUrl,
      );
    } catch (e) {
      print('コメント画面での送信エラー: $e');
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
          // 動作：元の親投稿を表示するエリア
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white.withOpacity(0.05),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserIcon(userData: widget.post),
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

          // 動作：リアルタイムでコメント一覧を監視・表示する StreamBuilder エリア
          Expanded(
            child: postId == null
                ? const Center(
                    child: Text(
                      '読み込みエラー',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : StreamBuilder<QuerySnapshot>(
                    // 💡 動作：インフラ通信は直接書かず、CommentServiceからストリームをもらいます
                    stream: _commentService.getCommentsStream(postId),
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

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  child: UserIcon(userData: commentData),
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

          // 動作：ボトムのコメント入力欄
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
                  InputTextField(controller: _commentController),
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

// 動作：TextField部分が見やすくなるように切り出したプライベートWidgetです
// 💡 動作：名前が公式のTextFieldと被らないように「Input用TextField」に変更しました！
class InputTextField extends StatelessWidget {
  final TextEditingController controller;
  const InputTextField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      // 動作：こちらはFlutter公式の本物のTextFieldです
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'コメントを入力...',
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }
}
