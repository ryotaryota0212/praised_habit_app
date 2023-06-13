import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'main.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('新規登録')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'メールアドレス'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'メールアドレスを入力してください';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'パスワード'),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'パスワードを入力してください';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _displayNameController,
              decoration: InputDecoration(labelText: '表示名'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '表示名を入力してください';
                }
                return null;
              },
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await _signUp(
                    _emailController.text,
                    _passwordController.text,
                    _displayNameController.text,
                  );
                }
              },
              child: Text('新規登録'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signUp(String email, String password, String displayName) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 名前を設定
      await userCredential.user!.updateDisplayName(displayName);
      // await userCredential.user!.reload();
      // User? updatedUser = FirebaseAuth.instance.currentUser;

      print('ユーザー名: ${userCredential.user!.displayName}');

      // 新規登録が成功したら、一覧ページに遷移
      Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage(pageIndex:0)),
      (route) => false,
    );
    } on FirebaseAuthException catch (e) {
      // エラー処理
      print(e);
    }
  }
}
