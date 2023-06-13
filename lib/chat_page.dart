import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<String> praiseReplies = [
    '素晴らしい！',
    'よくできました！',
    'すごい！',
    'おめでとう！',
  ];

  void sendReply(String reply) {
    // リプライをサーバーに送信する処理を実装する
    print('リプライ: $reply');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('completedTask')
            .orderBy('completedDate', descending: true)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
          }

          final completedTasks = snapshot.data!.docs;

          return ListView.builder(
            itemCount: completedTasks.length,
            itemBuilder: (context, index) {
              final completedTask = completedTasks[index].data() as Map<String, dynamic>;
              final completedDate = completedTask['completedDate'];
              final author = completedTask['author'];
              final taskList = List<String>.from(completedTask['completedTask']);

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$completedDate - $author',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(height: 8),
                      ...taskList.map((task) => Padding(
                            padding: EdgeInsets.only(bottom: 4),
                            child: Text(task),
                          )),
                      SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        children: praiseReplies
                          .map(
                            (reply) => OutlinedButton(
                              onPressed: () {
                                // 褒める言葉を選択してリプライを返す処理をここに追加します。
                              },
                              child: Text(reply),
                            ),
                          )
                          .toList(),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
