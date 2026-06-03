import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:practice/screen/startScreen/start_screen.dart';
import 'firebase_options.dart';

void main() async {
  //flutterの初期化処理が完全に終わるのを待つ
  WidgetsFlutterBinding.ensureInitialized();

  //firebaseをアプリ起動時に初期化する
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const StartScreen());
  }
}
