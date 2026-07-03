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

  // 💡 修正ポイント：使っていない自分の userData 変数はエラーの元になるので削除するか、今後使うためにコメントアウトのままにするのが安全だよ！
  // 今は相手のデータを widget.userData から受け取れているからバッチリ！

  // 動作確認用のチャット履歴データ
  // isMe が true なら自分（右側・青）、false なら相手（左側・グレー）
  final List<Map<String, dynamic>> _messages = [
    {"text": "こんにちは！Flutterの勉強は順調ですか？にゃん", "isMe": false},
    {"text": "いま画面遷移のところを作ってます！", "isMe": true},
    {"text": "すごい！画面がつながると一気にSNSらしくなってワクワクするにゃんね！応援してるにゃ！", "isMe": false},
  ];

  // 💡 動作：ユーザーが送信した後に、AIが「にゃんモード」で自動返信してくる関数（ロジックの土台）
  void _simulateAiReply(String userText) async {
    // 動作：1.5秒待って、本当に考えて返信してきたようなリアルな「間」を作ります
    await Future.delayed(const Duration(milliseconds: 1500));

    // 💡 動作：ここに後で本物の Gemini API を接続します！今はダミーの自動応答にしておくね
    String aiResponse = "「$userText」って言ったにゃん？ゆうたくん、その調子で頑張るにゃ！応援してるにゃん！";

    // 動作：AIのメッセージをリストに追加して、画面を再描画します
    setState(() {
      _messages.add({
        "text": aiResponse,
        "isMe": false, // AIなので左側の吹き出し
      });
    });
  }

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
            // 💡 動作：もし引数のキーが 'icon' じゃなくて 'iconUrl' だった場合でも落ちないように対策
            Text(
              widget.userData['icon'] ?? widget.userData['iconUrl'] ?? '👤',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 10),
            Text(
              widget.userData['user'] ?? widget.userData['name'] ?? 'AIユーザー',
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
              reverse: false, // 動作：上から下に歴史が並ぶ通常の設定
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final bool isMe = message['isMe'] ?? false;

                return Align(
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
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blueAccent : Colors.grey[800],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMe ? 16 : 0),
                        bottomRight: Radius.circular(isMe ? 0 : 16),
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
                      decoration: const InputDecoration(
                        hintText: 'メッセージを入力...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                  // 送信ボタン
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blueAccent),
                    onPressed: () {
                      final String text = _messageController.text.trim();
                      if (text.isEmpty) return;

                      setState(() {
                        // 動作：自分のメッセージをリストに追加して画面を更新する
                        _messages.add({"text": text, "isMe": true});
                      });

                      // 入力欄をクリアにする
                      _messageController.clear();

                      // 💡 動作追加：自分が送った文字（text）をトリガーにして、AIの返信関数を動かします！
                      _simulateAiReply(text);
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
