import 'package:flutter/material.dart';
import 'package:praised_habit_app/main.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'utils.dart';
import 'task_detail.dart';
import 'package:intl/intl.dart';
import 'chat_page.dart';
import 'main.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:lottie/lottie.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Future<List<Map<String, dynamic>>>? taskListFuture;

  @override
  void initState() {
    super.initState();
    taskListFuture = getTaskList();
  }

  Widget buildTaskList(DateTime selectedDay, List<dynamic> tasks, BuildContext context) {
  tasks.sort((a, b) => a['time'].compareTo(b['time']));
  bool allTasksCompleted() {
    for (var task in tasks) {
      final finishDateArray = task['finishDate'];
      bool isCompleted = finishDateArray != null && finishDateArray.contains(DateFormat('yyyy/MM/dd').format(selectedDay));
      if (!isCompleted) {
        return false;
      }
    }
    return true;
  }

  Future<void> saveCompletedTask() async {
    final auth = FirebaseAuth.instance;
    final uid = auth.currentUser?.uid;
    final user = FirebaseAuth.instance.currentUser;
    DateFormat Format = DateFormat('yyyy/MM/dd');
    final completedTaskList = convertTasksToStringList(tasks);
    final today = Format.format(DateTime.now());
    if (uid != null) {
      await FirebaseFirestore.instance
        .doc('completedTask/$uid')
        .set({
          'completedDate': today,
          'completedTask': completedTaskList,
          'author':user!.displayName,
          }
          ,SetOptions(merge: true)
        );
    }
  }

  Widget shareButton(completedTasks) {
    if (allTasksCompleted()) {
      return FloatingActionButton(
        onPressed: () async {
          final result = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                // title: Text('おめでとう！！タスク完了'),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      Lottie.asset('assets/cracker_animation.json', width: 500, height: 300),
                      Text('おめでとう！！タスク完了！\n今日の成果をみんなに見せますか？'),
                    ],
                  ),
                ),
                actions: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text('キャンセル'),
                      ),
                      SizedBox(width: 20), // スペースを追加
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text('投稿'),
                      ),
                    ],
                  ),
                ],
              );
            },
          );

          if (result == true) {
            await saveCompletedTask();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyHomePage(pageIndex: 2),
              ),
            );
          }
        },
        child: Icon(Icons.share_sharp),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  List<dynamic> completedTasks = tasks.where((task) {
    final finishDateArray = task['finishDate'];
    return finishDateArray != null && finishDateArray.contains(DateFormat('yyyy/MM/dd').format(selectedDay));
  }).toList();

  return Stack(
    children: [
      SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ...tasks.map((task) {
              final finishDateArray = task['finishDate'];
              bool isCompleted = finishDateArray != null && finishDateArray.contains(DateFormat('yyyy/MM/dd').format(selectedDay));
              // タスク詳細に遷移用のMapEntryを作成
              MapEntry<String, dynamic> transitionTask = MapEntry<String, dynamic>(task['key'], task['title']);
              return Card(
                margin: EdgeInsets.all(8),
                child: InkWell(
                  onTap: () {
                    // タスク詳細ページに遷移
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskDetailPage(task: transitionTask),
                      ),
                    );
                  },
                  child: ListTile(
                    title: Text(
                      task['title'],
                      style: TextStyle(
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: Text(task['time']),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
      if (allTasksCompleted())
        Positioned.fill(
          child: Container(
            color: Colors.grey.withOpacity(0.5),
            child: Center(
              child: shareButton(completedTasks)
            ),
          ),
        ),
    ],
  );
}



  List<dynamic> _getEventsForDay(DateTime selectedDay, List<Map<String, dynamic>> taskList) {
    List<dynamic> events = [];
    for (var task in taskList) {
      List<bool> days = List<bool>.from(task['days']);
      // taskDateの曜日を取得 (0: Monday, 1: Tuesday, ..., 6: Sunday)
      int weekday = selectedDay.weekday - 1;

      // 曜日に応じたイベントを追加
      if (days[weekday]) {
        events.add(task);
      }
    }
    return events;
  }

  List<dynamic> _getTasksForSelectedDay(DateTime selectedDay, List<Map<String, dynamic>> taskList) {
    List<Map<String, dynamic>> tasks = [];
    for (var task in taskList) {
      List<bool> days = List<bool>.from(task['days']);

      // selectedDayの曜日を取得 (0: Monday, 1: Tuesday, ..., 6: Sunday)
      int weekday = selectedDay.weekday - 1;
      if (days[weekday]) {
        tasks.add(task);
      }
    }
    return tasks;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            FutureBuilder<List<Map<String, dynamic>>>(
              future: taskListFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
                }

                final taskList = snapshot.data!;

                return 
                TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2025, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    onFormatChanged: (format) {
                      if (_calendarFormat != format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      }
                    },
                    eventLoader: (day) {
                      // ここで各曜日に対応するタスクをロードします。
                      // カレンダーに表示するイベントのリストを返します。
                      return _getEventsForDay(day, taskList);
                    },
                    startingDayOfWeek: StartingDayOfWeek.sunday,
                    
                  );
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: taskListFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
                    }

                    final taskList = snapshot.data!;

                    if (_selectedDay != null) {
                      return buildTaskList(
                          _selectedDay!,
                          _getTasksForSelectedDay(_selectedDay!, taskList),
                          context);
                    } else {
                      return Container();
                    }
                  },
                ),
              )
            ),
          ],
        ),
      ),
    );

  }
}
