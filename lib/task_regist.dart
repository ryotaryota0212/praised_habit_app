import 'package:flutter/material.dart';
import 'task_list.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';

class TaskRegistPage extends StatefulWidget {
  @override
  _TaskRegistPageState createState() => _TaskRegistPageState();
}

class _TaskRegistPageState extends State<TaskRegistPage> {
  TextEditingController _taskController = TextEditingController();

  Future<dynamic> saveTask(String task) async {
    Map<String, dynamic> tasks = {};
    final auth = FirebaseAuth.instance;
    final uid = auth.currentUser?.uid.toString();
    final taskList = await FirebaseFirestore.instance.doc('tasks/$uid').get().then(
      (DocumentSnapshot doc) {
        if (doc.exists) {
          return (doc.data() as Map<String, dynamic>);
        } else {
          return {};
        }
      }
    );

    final taskCount = taskList.length;
    await FirebaseFirestore.instance.doc('tasks/$uid').set({'task${taskCount + 1}':task},SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('タスク登録')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _taskController,
              decoration: InputDecoration(
                labelText: '習慣化したいタスク',
                hintText: 'タスクを入力してください',
                fillColor: Colors.white,
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.lime, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.lime, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.lime, width: 2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.lime, width: 2),
                ),
                // prefixIcon: Icon(Icons.search, color: Colors.blue),
                labelStyle: TextStyle(color: Colors.lime),
                hintStyle: TextStyle(color: Colors.lime),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await saveTask(_taskController.text);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage(pageIndex:0)),
                );
              },
              child: Text('登録'),
            ),
          ],
        ),
      ),
    );
  }
}
