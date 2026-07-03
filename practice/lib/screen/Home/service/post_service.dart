import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'dart:async';
import 'package:practice/screen/Home/service/gemini_service.dart';

// 動作：タイムラインの投稿（Firebase・Gemini通信）に関する裏方処理を専門に行うクラス
class PostService {
  // 動作：Firestoreを操作するためのインスタンス（窓口）
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GeminiService _geminiService = GeminiService();

  // 動作：Firebaseの「posts」コレクションのリアルタイム更新を監視するストリームを返す関数
  Stream<QuerySnapshot> getPostsStream() {
    // 動作：postsコレクション全体の生データをリアルタイムに流す川を戻します
    return _firestore.collection('posts').snapshots();
  }

  // 動作：特定の投稿の「いいね」状態をFirebase上で反転させて更新する関数
  Future<void> toggleFavorite(
    Map<String, dynamic> post,
    bool currentStatus,
  ) async {
    final String? postId = post['id'];
    try {
      // 動作：現在のいいね状態を反転（true ⇄ false）させます
      final bool newFavoriteStatus = !currentStatus;

      // 動作：指定されたドキュメントIDの「isFavorite」フィールドを直接更新します
      await _firestore.collection('posts').doc(postId).update({
        'isFavorite': newFavoriteStatus,
      });
      print("【PostService】Firebaseのいいね状態を更新しました！");

      // 💡 ここからが新しく追加した【目標②】の確率・時間差ロジック！
      // 動作：ユーザーが「いいねを付けた（falseからtrueになった）」瞬間だけを狙い撃ちして判定します
      if (currentStatus == false) {
        // 動作：1〜100までのランダムな数字（サイコロの目）を引きます
        final int lottery = Random().nextInt(100) + 1;
        print("【確率ガチャ】サイコロの目は… [$lottery] でした！（1〜30なら30%の確率で当選です）");

        // 動作：30%の確率（サイコロの目が30以下）を引き当てた場合の処理
        if (lottery <= 30) {
          print("🎉【当選！】30%の確率を引きました！3分後にフォローイベントを裏で実行します。");

          // 動作：3分間（180秒）待ってから内部の処理を自動実行するタイマーを仕込みます
          // 🚨 注意：裏で待っている間にアプリを完全にシャットダウンすると消えちゃうけど、
          // 起動したまま別の画面を見たり操作していれば、3分後に確実に発動するよ！
          Future.delayed(const Duration(seconds: 180), () async {
            print("⏰【タイマー発動】いいねを押してから3分が経過しました！AIのフォローバック処理を開始します。");

            // 💡 動作：ここに将来、通知コレクション（notifications）に「フォローされました」と追加するコードを書きます
            // await _firestore.collection('notifications').add({ ... });
            print("👤【AIアクション】AIキャラクターがあなたをフォローしました！");
          });
        } else {
          // 動作：31以上の数字を引いてしまった、残り70%のハズレ枠だった場合の処理
          print("❌【ハズレ】今回はAIからフォローが来ない70%の枠でした。");
        }
      }
    } catch (e) {
      print("【PostService】いいね更新または確率ロジックでのエラー: $e");
    }
  }

  // 動作：新しくAIの投稿を生成して、Firebase（Firestore）に新規保存する関数
  Future<void> fetchAndSaveNewAiPost() async {
    // 動作：GeminiServiceを使って、AIの投稿データを生成してもらいます
    final data = await _geminiService.generateAiPost();

    if (data != null) {
      try {
        // 動作：Firestoreの「posts」コレクションに新しいドキュメントを追加（保存）します
        await _firestore.collection('posts').add({
          "user": data['name'],
          "icon": data['icon_url'],
          "content": data['post'],
          "role": data['role'],
          "isFavorite": false, // 動作：初期状態は未いいね
          "isShared": false,
          "shareCount": 0,
          "createdAt": FieldValue.serverTimestamp(), // 動作：サーバー側の現在時刻を刻印
        });
        print("【PostService】FirebaseへのAI投稿の新規保存に成功しました！");
      } catch (e) {
        print("【PostService】Firebase保存エラー: $e");
      }
    }
  }
}
