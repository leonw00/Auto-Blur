import 'package:auto_blur/screens/base_screen.dart';
import 'package:auto_blur/screens/home_screen.dart';
import 'package:auto_blur/screens/video_testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

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
        '/': (context) => BaseScreen(),
      },
      builder: EasyLoading.init(),
    );
  }
}
