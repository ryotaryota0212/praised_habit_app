import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';

Future<Map<String, dynamic>> getTask() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  return await FirebaseFirestore.instance.doc('tasks/$uid').get().then(
    (DocumentSnapshot doc) {
      if (doc.exists) {
        return (doc.data() as Map<String, dynamic>);
      } else {
        return {};
      }
    }
  );
}
Future<List<Map<String, dynamic>>> getTaskList() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  // ここからタスク続き
  final result =  await FirebaseFirestore.instance.collection('tasks/$uid/task_detail').get();
  List<Map<String, dynamic>> data = result.docs.map((doc) => doc.data()).toList();
  print(data);
  return data;
}



// 特定の日付のタスクをフィルタリングする関数
List<MapEntry<String, dynamic>> getTasksForDate(Map<String, dynamic> tasks, DateTime date) {
  return tasks.entries.where((entry) {
    DateTime taskDate = DateTime.parse(entry.value['date']);
    return isSameDay(taskDate, date);
  }).toList();
}

List<String> convertTasksToStringList(List<dynamic> tasks) {
  List<String> result = [];

  tasks.forEach((task) {
    result.add('${task['title']}(${task['duration']}分)');
  });

  return result;
}