import 'dart:io';
import 'dart:ui' as ui;
import 'package:auto_blur/objects/image_container.dart';
import '../objects/painters/blur_painter.dart';
import 'package:auto_blur/objects/video_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class BaseWrapper extends StatefulWidget {

  final body;

  BaseWrapper({this.body});

  @override
  _BaseWrapperState createState() => _BaseWrapperState();
}

class _BaseWrapperState extends State<BaseWrapper> {

  late Widget defaultWidget;

  @override
  void initState() {
    super.initState();
    defaultWidget = widget.body;
  }

  Future pickImage() async {
    final ImagePicker _picker = ImagePicker();
    // Pick an image
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    return image;
  }

  Future pickVideo() async {
    final ImagePicker _picker = ImagePicker();
    // Pick a video
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    return video;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
          child: Text("AutoBlur", style: TextStyle(fontSize: 27, color: Colors.orange),),
        ),
        actions: [
          IconButton(
              onPressed: (){
                pickImage().then((image) async {
                  setState(() {
                    defaultWidget = ImageContainer(link: image!.path,);
                  });
                });
              },
              padding: EdgeInsets.zero,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: Icon(Icons.image, size: 50, color: Colors.grey,)),
          SizedBox(width: 15,),
          IconButton(
              onPressed: (){
                pickVideo().then((video) async {
                  setState(() {
                    defaultWidget = VideoContainer(link: video!.path,);
                  });
                });
              },
              padding: EdgeInsets.zero,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: Icon(Icons.video_collection, size: 50, color: Colors.grey,)),
          SizedBox(width: 15,),
        ],
      ),
      body: Center(child: defaultWidget),
    );
  }
}
