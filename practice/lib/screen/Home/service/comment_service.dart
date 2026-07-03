import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:practice/screen/Home/service/gemini_service.dart';

// 動作：コメント画面に関するFirestore通信やAI自動返信の裏方処理を専門に行うクラス
class CommentService {
  // 動作：Firestoreを操作するためのインスタンス（窓口）
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 動作：Geminiサービスを呼び出すための実体
  final GeminiService _geminiService = GeminiService();

  // 動作：特定の投稿に対するコメント一覧のリアルタイム更新を監視するストリームを返す関数
  Stream<QuerySnapshot> getCommentsStream(String postId) {
    // 動作：特定の投稿(postId)の中にある「comments」サブコレクションを古い順（createdAt）で流す川を戻します
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  // 動作：ユーザーのコメントを保存し、それに対するAIキャラクターからの自動返信を生成・保存する一連の関数
  Future<void> postCommentAndAiReply({
    required String postId,
    required String commentText,
    required String aiName,
    required String aiRole,
    required String aiIconUrl,
  }) async {
    try {
      // 💡 動作：1. ユーザー自身のコメントをFirestoreのサブコレクション「comments」に保存します
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .add({
            'user': 'name', // 動作：ログイン中のユーザー名（仮で固定）
            'content': commentText,
            'createdAt': FieldValue.serverTimestamp(),
            'isAi': false, // 動作：ユーザー自身なのでAIフラグはfalse
          });

      // 💡 動作：2. キャラクター設定（role）をGeminiに流し込むための指示メッセージ（プロンプト）を作ります
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

      // 💡 動作：3. GeminiServiceを使って、設定に沿った返信テキストを作ってもらいます
      final String? aiReply = await _geminiService.askGemini(aiPrompt);

      if (aiReply != null) {
        // 💡 動作：4. 生成されたAIの返信を、同じくFirestoreの「comments」に保存します
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .add({
              'user': aiName, // 動作：AIのキャラクター名
              'content': aiReply,
              'createdAt': FieldValue.serverTimestamp(),
              'isAi': true, // 動作：AIなのでtrue
              'icon?url': aiIconUrl,
            });
      }
    } catch (e) {
      print('【CommentService】コメント送信、またはAI自動返信エラー: $e');
      rethrow; // 動作：エラーが発生した場合は画面側にも伝える
    }
  }
}
