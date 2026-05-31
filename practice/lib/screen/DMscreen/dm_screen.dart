import 'package:flutter/material.dart';

class DmScreen extends StatefulWidget {
  // 誰とDMしているか識別するために、相手のユーザーデータを受け取る
  final Map<String, dynamic> userData;

  const DmScreen({super.key, required this.userData});

  @override
  State<DmScreen> createState() => _DmScreenState();
}

class _DmScreenState extends State<DmScreen> {
  // チャットに入力された文字を管理するコントローラー
  final TextEditingController _messageController = TextEditingController();

  // 動作確認用のチャット履歴データ（ダミー）
  // isMe が true なら自分（右側・青）、false なら相手（左側・グレー）
  final List<Map<String, dynamic>> _messages = [
    {"text": "こんにちは！Flutterの勉強は順調ですか？にゃん", "isMe": false},
    {"text": "いま画面遷移のところを作ってます！", "isMe": true},
    {"text": "すごい！画面がつながると一気にSNSらしくなってワクワクするにゃんね！応援してるにゃ！", "isMe": false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 背景はダークモード仕様の黒
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
        // AppBar のタイトルに相手の名前とアイコンを動的に表示するよ
        title: Row(
          children: [
            Text(
              widget.userData['icon'] ?? '👤',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 10),
            Text(
              widget.userData['user'] ?? 'AIユーザー',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // --- 1. チャット履歴の表示エリア ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              // 新しいメッセージが下に追加されたら、自動で下にスクロールする設定
              reverse: false,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final bool isMe = message['isMe'] ?? false;

                return Align(
                  // 自分が送信したなら右寄せ、相手なら左寄せ
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    constraints: BoxConstraints(
                      // 画面の横幅いっぱいに吹き出しが広がらないように制限（最大7割）
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    decoration: BoxDecoration(
                      // 自分の吹き出しは青、相手の吹き出しは濃いグレー
                      color: isMe ? Colors.blueAccent : Colors.grey[800],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(
                          isMe ? 16 : 0,
                        ), // 相手の吹き出しの左下を角丸にしない
                        bottomRight: Radius.circular(
                          isMe ? 0 : 16,
                        ), // 自分の吹き出しの右下を角丸にしない
                      ),
                    ),
                    child: Text(
                      message['text'] ?? '',
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                );
              },
            ),
          ),

          // --- 2. メッセージ入力エリア ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: Colors.grey[900],
            child: SafeArea(
              child: Row(
                children: [
                  // 入力フォーム
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'メッセージを入力...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                      ),
                    ),
                  ),
                  // 送信ボタン
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blueAccent),
                    onPressed: () {
                      if (_messageController.text.trim().isEmpty) return;

                      setState(() {
                        // 自分のメッセージをリストに追加して画面を更新する
                        _messages.add({
                          "text": _messageController.text,
                          "isMe": true,
                        });
                      });
                      // 入力欄をクリアにする
                      _messageController.clear();
                    },
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
