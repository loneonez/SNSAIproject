import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:practice/service/follow_service.dart'; // 動作：相互フォローロジックが書かれたサービスをインポート

// 動作：フォローボタンのWidget
class FollowButton extends StatefulWidget {
  final Map<String, dynamic> userData; // 動作：相手のユーザー情報（名前やID、アイコンなど）を受け取る

  const FollowButton({super.key, required this.userData});

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  // 動作：現在フォローしているかどうかの状態を管理するフラグ
  bool _isFollowing = false;

  // 動作：最初はFirestoreのチェック中なので「true」からスタートさせます
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // 動作：画面が立ち上がった瞬間に、すでにフォローしているかFirestoreを調べにいきます
    _checkFollowStatus();
  }

  // 💡 動作：相手の本当のIDを、データのズレ（uid, name, user）に依存せず確実に引っこ抜く共通関数
  String _getTargetId() {
    // 🔥 動作変更：最優先で「uid（部屋の本当のID）」を見にいき、無ければnameやuserをフォールバックにします
    return widget.userData['uid'] ??
        widget.userData['name'] ??
        widget.userData['user'] ??
        'unknown_user';
  }

  // 動作：すでにフォロー中か過去の履歴をチェックする関数
  Future<void> _checkFollowStatus() async {
    final String targetId = _getTargetId(); // 動作：確実なターゲットIDを取得

    try {
      // 動作：自分のfollowingコレクションの中に、相手のIDのドキュメントがあるか直接取得しにいきます
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc('my_profile')
          .collection('following')
          .doc(targetId)
          .get();

      if (mounted) {
        setState(() {
          _isFollowing =
              doc.exists; // 動作：ドキュメントがFirestoreに本当に存在していれば「true（フォロー中）」になる
          _isLoading = false; // 動作：チェック完了。ここで初めてボタンを表示可能にする
        });
      }
    } catch (e) {
      print('フォロー状況確認エラー: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // 動作：ボタンが押された時に実行する関数
  Future<void> _handleFollowTap() async {
    setState(() {
      _isLoading = true; // 動作：通信中状態にして連打を防止する
    });

    final String targetId = _getTargetId(); // 動作：確実なターゲットIDを取得

    try {
      final followService = FollowService();

      // 動作：作ったFollowServiceを呼び出して、自分と相手を相互フォロー状態（または解除）にする
      await followService.handleFollow(
        myUid: 'my_profile', // 自分のID
        targetUserId: targetId, // 相手のAIのID
        isAiUser: true, // 動作：今回はAI相手なので常にtrueにして自動フォローバックを走らせます
        isCurrentlyFollowing: _isFollowing, // 動作：現在の状態を渡して、追加か削除かを内部で分岐させる
      );

      if (mounted) {
        setState(() {
          _isFollowing = !_isFollowing; // 動作：通信が成功したらフォロー状態を反転（true ⇄ false）させる
        });
      }

      // 動作：画面下に通知をふわっと出す
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isFollowing ? 'フォローしました！' : 'フォローを解除しました')),
      );
    } catch (e) {
      print('フォローボタンタップエラー: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // 動作：すべての通信処理が終了したのでローディングを解除
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 動作：Firestoreに確認している間（読み込み中）は、小さな青いぐるぐるを出して誤動作を防ぐ
    if (_isLoading) {
      return const SizedBox(
        width: 32,
        height: 32,
        child: Padding(
          padding: EdgeInsets.all(6.0),
          // 2.5 flash互換用の安全なローディングWidget
          child: CircularProgressIndicator(
            color: Colors.blueAccent,
            strokeWidth: 2,
          ),
        ),
      );
    }

    return SizedBox(
      height: 36,
      child: ElevatedButton(
        onPressed: _handleFollowTap, // 動作：タップされたらフォロー処理を実行
        style: ElevatedButton.styleFrom(
          backgroundColor: _isFollowing ? Colors.white12 : Colors.blueAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18), // 動作：カプセル型のボタンにする
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          elevation: 0,
        ),
        child: Text(
          _isFollowing ? 'フォロー中' : 'フォローする', // 動作：状態に合わせて文字を変える
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }
}
