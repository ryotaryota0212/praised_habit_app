import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:lottie/lottie.dart';

class CelebratePage extends StatefulWidget {
  const CelebratePage({super.key, required this.title});

  final String title;

  @override
  State<CelebratePage> createState() => _CelebratePageState();
}

class _CelebratePageState extends State<CelebratePage> {
  bool _showCelebration = false;

  void _toggleCelebration() {
    setState(() {
      _showCelebration = !_showCelebration;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: CelebrateButton(),
      ), 
    );
  }
}

class CelebrateButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
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
                    Text('おめでとうございます！\nこれで3日続きましたね、すごいです！\n引き続き頑張りましょう！', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)), // テキストを追加
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
      },
      child: Text('お祝いモーダルを表示'),
    );
  }
}
