import 'package:cloud_firestore/cloud_firestore.dart';

// 動作：フォロー・フォロワーに関するFirestoreの処理を専門に行うクラス
class FollowService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 💡 動作：相手をフォロー、またはフォロー解除する関数（isFollowingRefを追加して分岐させます）
  Future<void> handleFollow({
    required String myUid, // 動作：自分のユーザーID（'my_profile'）
    required String targetUserId, // 動作：フォローしたい相手のID
    required bool isAiUser, // 動作：相手がAIアカウントかどうかの判定フラグ
    required bool isCurrentlyFollowing, // ✨ 動作追加：現在フォロー中かどうかのフラグを受け取る
  }) async {
    try {
      final WriteBatch batch = _firestore.batch();

      // 動作：自分の「フォロー中（following）」の参照パス
      final myFollowingRef = _firestore
          .collection('users')
          .doc(myUid)
          .collection('following')
          .doc(targetUserId);

      // 動作：相手の「フォロワー（followers）」の参照パス
      final targetFollowerRef = _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('followers')
          .doc(myUid);

      // 動作：相手（AI）の「フォロー中（following）」の参照パス
      final aiFollowingRef = _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('following')
          .doc(myUid);

      // 動作：自分側の「フォロワー（followers）」の参照パス
      final myFollowerRef = _firestore
          .collection('users')
          .doc(myUid)
          .collection('followers')
          .doc(targetUserId);

      if (isCurrentlyFollowing) {
        // -------------------------------------------------------
        // ❌ 【フォロー解除（削除）の処理】
        // -------------------------------------------------------
        print('フォロー解除を検知しました。データを削除します。');
        batch.delete(myFollowingRef);
        batch.delete(targetFollowerRef);

        if (isAiUser) {
          batch.delete(aiFollowingRef);
          batch.delete(myFollowerRef);
        }
      } else {
        // -------------------------------------------------------
        // ⭕️ 【新規フォロー（追加）の処理】
        // -------------------------------------------------------
        print('新規フォローを検知しました。データを追加します。');

        // 動作：相手の詳細部屋（users/相手ID）がなかった場合のための自動生成
        final targetUserDocRef = _firestore
            .collection('users')
            .doc(targetUserId);
        batch.set(targetUserDocRef, {
          'user_name': targetUserId,
          'user_icon_url': 'https://robohash.org/$targetUserId',
          'role': 'AIパートナー',
          'introduce': 'よろしくお願いします！',
        }, SetOptions(merge: true));

        batch.set(myFollowingRef, {'createdAt': FieldValue.serverTimestamp()});
        batch.set(targetFollowerRef, {
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (isAiUser) {
          batch.set(aiFollowingRef, {
            'createdAt': FieldValue.serverTimestamp(),
          });
          batch.set(myFollowerRef, {'createdAt': FieldValue.serverTimestamp()});
        }
      }

      // 動作：バッチに溜めたすべての処理（追加または削除）を一発で実行！
      await batch.commit();
      print('✨ フォロー/解除処理が正常に終了しました！');
    } catch (e) {
      print('FollowServiceエラー: $e');
      rethrow;
    }
  }
}
