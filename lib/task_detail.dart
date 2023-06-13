import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:intl/intl.dart';
import 'task_calender.dart';
import 'main.dart';

class TaskDetailPage extends StatefulWidget {
  final MapEntry<String ,dynamic> task;

  TaskDetailPage({required this.task});
   @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  List<bool> daysSelected = List.generate(7, (index) => true);
  TimeOfDay? selectedTime;
  int? customDurationInMinutes = 15;
  bool showCompletedButton = false;
  List<String>? finishDateArray = [];
  Timer? _timer;
  bool _timerStarted = false;
  CountDownController _timerController = CountDownController();

  void _startTimer() {
    setState(() {
      _timerStarted = true;
    });
    _timerController.start();
  }

  Future<void> saveFinishFlag() async {
    final auth = FirebaseAuth.instance;
    final uid = auth.currentUser?.uid;
    DateFormat Format = DateFormat('yyyy/MM/dd');
    final addDate = Format.format(DateTime.now());
    finishDateArray?.add(addDate);
    if (uid != null) {
      await FirebaseFirestore.instance
          .doc('tasks/$uid/task_detail/${widget.task.key}')
          .set({'finishDate': finishDateArray},SetOptions(merge: true));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('タスクが完了しました'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadTaskDetail();
  }

  Future<void> loadTaskDetail() async {
    final auth = FirebaseAuth.instance;
    final uid = auth.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance
        .doc('tasks/$uid/task_detail/${widget.task.key}')
        .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          if (data['duration'] != null) {
            customDurationInMinutes = data['duration'];
          }
          if (data['finishDate'] != null) {
            finishDateArray = data['finishDate'].cast<String>() as List<String>;
          }
          print(finishDateArray);
          daysSelected = List<bool>.from(data['days'] ?? []);
          final time = data['time'] as String?;
          if (time != null) {
            final timeParts = time.split(':');
            selectedTime = TimeOfDay(
                hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
          }
        });
      }
    }
  }

  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
    print(selectedTime);
  }

  Future<void> saveTaskDetails() async {
    final auth = FirebaseAuth.instance;
    final uid = auth.currentUser?.uid.toString();
    // print(selectedTime);
    final time = selectedTime != null
    ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}' 
    : null;
    await FirebaseFirestore.instance.doc('tasks/$uid/task_detail/${widget.task.key}').set({
      'key': widget.task.key,
      'title': widget.task.value,
      'days': daysSelected,
      'time': time,
      'duration': customDurationInMinutes,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
      content: Text('保存されました'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.task.value)),
      body: ListView(
        children: [
          for (int i = 0; i < daysSelected.length; i++)
            CheckboxListTile(
              title: Text(
                ['月曜日', '火曜日', '水曜日', '木曜日', '金曜日', '土曜日', '日曜日'][i],
              ),
              value: daysSelected[i],
              onChanged: (bool? value) {
                setState(() {
                  daysSelected[i] = value!;
                });
              },
            ),
          ListTile(
            title: Text('時間を選択: ${selectedTime?.format(context) ?? '未選択'}'),
            trailing: Icon(Icons.access_time),
            onTap: () => selectTime(context),
          ),
          ListTile(
            title: Text('タイマー設定: ${customDurationInMinutes ?? '未設定'} 分'),
            trailing: Icon(Icons.timer),
            onTap: () async {
              final int? result = await showDialog<int>(
                context: context,
                builder: (BuildContext context) {
                  return StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return AlertDialog(
                        title: Text('何分しますか？'),
                        content: DropdownButton<int>(
                        value: customDurationInMinutes,
                        onChanged: (int? newValue) {
                          setState(() {
                            customDurationInMinutes = newValue;
                          });
                        },
                        items: List<int>.generate(120, (i) => i + 1)
                            .map<DropdownMenuItem<int>>((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(value.toString()),
                            );
                          }).toList(),
                        dropdownColor: Colors.grey[200],
                        style: TextStyle(color: Colors.black, fontSize: 18),
                        icon: Icon(Icons.arrow_drop_down),
                        iconSize: 24,
                        isExpanded: true,
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(customDurationInMinutes);
                            },
                            child: const Text('設定'),
                          ),
                        ],
                      );
                    }
                  );
                },
              );
              if (result != null) {
                setState(() {
                  customDurationInMinutes = result;
                });
              }
            },
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: ElevatedButton(
              onPressed: saveTaskDetails,
              child: Text('保存'),
            ),
          ),
          if (!_timerStarted)
          Center(
            child: InkWell(
              onTap: _startTimer,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '開始',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
            ),
          ),
          if (_timerStarted && !showCompletedButton)
          CircularCountDownTimer(
            duration: customDurationInMinutes! * 60, // 期間を秒単位で設定
            width: MediaQuery.of(context).size.width / 6,
            height: MediaQuery.of(context).size.height / 6,
            fillColor: Colors.purpleAccent[100]!,
            ringColor: Colors.grey[300]!,
            // Other properties
            onStart: () {
              print('Countdown Started');
            },
            onComplete: () {
              print('Countdown Ended');
              setState(() {
                showCompletedButton = true;
              });
            },
          ),
          if (showCompletedButton)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () async {
                await saveFinishFlag();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyHomePage(pageIndex:1),
                  ),
                );
              },
              child: Text('完了'),
            ),
          ),
        ],
      ),
    );
  }
}
