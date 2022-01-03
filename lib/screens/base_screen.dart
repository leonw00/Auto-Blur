import 'dart:io';
import 'dart:ui' as ui;
import 'package:auto_blur/objects/image_container.dart';
import 'package:auto_blur/objects/painter.dart';
import 'package:auto_blur/objects/video_container.dart';
import 'package:auto_blur/wrapper/base_template.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class BaseScreen extends StatefulWidget {
  @override
  _BaseScreenState createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
  }


  Widget defaultWidget = Center(
    child: Text(
      "Select a picture or video ...",
      style: TextStyle(fontSize: 18),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return BaseWrapper(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: defaultWidget,
      ),
    );
  }
}
