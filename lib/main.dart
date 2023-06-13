import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:lottie/lottie.dart';
import 'task_regist.dart';
import 'login_page.dart';
import 'task_list.dart';
import 'task_calender.dart';
import 'chat_page.dart';
import 'celebrate.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.lime,
      ),
      home: LandingPage()
      // const MyHomePage(title: '褒められ習慣アプリ'),
    );
  }
}

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;

    return StreamBuilder<User?>(
      stream: auth.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
        if (snapshot.hasData) {
          return MyHomePage(pageIndex:0);
        } else {
          return LoginPage();
        }
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  final int pageIndex;
  const MyHomePage({Key? key, required this.pageIndex}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentIndex = 0;

  void showCelebrateDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 200),
      pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
        return Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.4,
            margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Lottie.asset(
                    'assets/cracker_animation.json',
                    repeat: true,
                    animate: true,
                  ),
                ),
                Text('おめでとうございます！\nこれで3日続きましたね、すごいです！\n引き続き頑張りましょう！', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                SizedBox(height: 30),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('閉じる'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    currentIndex = widget.pageIndex;
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      showCelebrateDialog(context);
    });
  }

  Widget buildBody() {
  switch (currentIndex) {
    case 0:
      return Scaffold(
        appBar: AppBar(title: Text('タスク一覧')),
        body: TaskListPage(),
      );
    case 1:
      return Scaffold(
        appBar: AppBar(title: Text('カレンダー')),
        body: CalendarPage(),
      );
    case 2:
      return Scaffold(
        appBar: AppBar(title: Text('褒めチャット')),
        body: ChatPage(),
      );
    default:
      return Container();
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'タスク一覧',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'カレンダー',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: '褒めチャット',
          ),
        ],
      ),
    );
  }
}
