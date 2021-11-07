import 'package:auto_blur/screens/home_screen.dart';
import 'package:auto_blur/screens/video_testing.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Auto Blur',
      initialRoute: '/',
      routes: {
        '/': (context) => TestVideo(),
      },
    );
  }
}
