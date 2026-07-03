import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:practice/screen/localUserProfile/local_user.dart';

class MyFollowUser extends StatelessWidget {
  const MyFollowUser({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 動作：「フォロー中」「フォロワー」の2つのタブ
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          title: const Text(
            'つながり',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          // 上部のタブバー
          bottom: const TabBar(
            indicatorColor: Colors.blueAccent,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'フォロー中'),
              Tab(text: 'フォロワー'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // --- 1. 動作：フォロー中のリストをFirestoreからリアルタイム取得 ---
            _buildFollowStream('following', 'まだ誰もフォローしていません'),

            // --- 2. 動作：フォロワーのリストをFirestoreからリアルタイム取得 ---
            _buildFollowStream('followers', 'フォロワーはいません'),
          ],
        ),
      ),
    );
  }

  // 💡 動作：指定されたコレクション（following または followers）の電波を監視する関数
  Widget _buildFollowStream(String collectionName, String emptyMessage) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc('my_profile')
          .collection(collectionName) // 動作：followingかfollowersを切り替える
          .snapshots(),
      builder: (context, snapshot) {
        // 動作：読み込み中のぐるぐる表示
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blueAccent),
          );
        }

        // 動作：データが空っぽ、またはドキュメントが存在しない場合
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              emptyMessage,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        // 💡 動作：繋がっているユーザーのID（ドキュメントID）のリストを作成します
        final List<String> userIds = snapshot.data!.docs
            .map((doc) => doc.id)
            .toList();

        // 💡 動作変更：裏側で持っている「本当の部屋の名前（ドキュメントID）」を使って、
        // usersコレクションから確実に1ミリのズレもなくデータをヒットさせます！
        return FutureBuilder<QuerySnapshot>(
          // 動作：usersコレクションの中から、IDがuserIdsリスト（ドキュメントID）に含まれる部屋をまとめて取得
          future: FirebaseFirestore.instance
              .collection('users')
              .where(
                FieldPath.documentId,
                whereIn: userIds,
              ) // 🔥 フィールド名ではなく documentId に修正！
              .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.blueAccent),
              );
            }

            // 動作：データが取得できなかった場合のセーフティ（デバッグログ付き）
            if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
              print('firebaseからデータを取得できませんでした。探したIDリスト : $userIds');
              return Center(
                child: Text(
                  emptyMessage,
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              );
            }

            // 動作：取得できたドキュメントデータのリスト
            final userDocs = userSnapshot.data!.docs;

            return ListView.builder(
              itemCount: userDocs.length,
              itemBuilder: (context, index) {
                // 動作：Firestoreから届いた1人分の生データ
                final docData = userDocs[index].data() as Map<String, dynamic>;

                // 💡 動作変更：次の画面（LocalUser）に渡すとき、ズレを防ぐための「uid」をバトンとして新しく追加します！
                final Map<String, dynamic> userData = {
                  "uid": userDocs[index]
                      .id, // 🔥 動作追加：Firestore上の本当の部屋のID（例: unknown_user）を保持
                  "name": docData['user_name'] ?? '名前未設定',
                  "user":
                      docData['user_name'] ??
                      '名前未設定', // 動作：ListTileのタイトル表示の互換性用
                  "icon":
                      docData['user_icon_url'] ??
                      'https://robohash.org/my_user', // 動作：選んだアバターURL
                  "role": docData['role'] ?? '性格や背景設定（短く）',
                  "content":
                      docData['introduce'] ?? '過去の投稿はありません', // 動作：プロフ画面の投稿欄に表示
                };

                return ListTile(
                  // 動作：ユーザーのアイコン表示（丸い写真）
                  leading: CircleAvatar(
                    backgroundColor: Colors.white12,
                    backgroundImage: NetworkImage(
                      userData['icon'],
                    ), // 動作：URL写真を反映！
                  ),
                  title: Text(
                    userData['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    userData['role'],
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                  // 動作：行全体をタップしたら、そのAIユーザーの本物のプロフ画面（LocalUser）に飛ぶ
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LocalUser(userData: userData),
                      ),
                    );
                    print(
                      '${userData['name']} のプロフへ移動（ID: ${userData['uid']}）',
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
