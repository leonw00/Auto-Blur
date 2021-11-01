import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:auto_blur/objects/painter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/services.dart' show rootBundle;


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final ImagePicker _picker = ImagePicker();
  final faceDetector = GoogleMlKit.vision.faceDetector();

  late ui.Image uiImage;
  List<Rect> rectArr = [];

  var imgTile;

  Future pickImage() async {
    rectArr = [];

    // Pick an image
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    final inputImage = InputImage.fromFilePath(image!.path);

    final List<Face> faces = await faceDetector.processImage(inputImage);
    print('Found ${faces.length} faces');


    for (Face face in faces) {
      final Rect boundingBox = face.boundingBox;

      final double? rotY = face.headEulerAngleY; // Head is rotated to the right rotY degrees
      final double? rotZ = face.headEulerAngleZ; // Head is tilted sideways rotZ degrees

      rectArr.add(boundingBox);
    }

    var bytesFromImageFile = await File(image.path).readAsBytes();


    decodeImageFromList(bytesFromImageFile).then((img) {
      setState(() {
        uiImage = img;
        imgTile = CustomPaint(
          painter: Painter(rectArr, uiImage),
        );
      });
    });

  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: CupertinoColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        child: Column(
          children: [
            Center(
              child: TextButton(
                onPressed: () { pickImage(); },
                child: Text("TEST"),
              ),
            ),

            Container(
              child: FittedBox(
                child: SizedBox(
                  height: 550,
                  width: 550,
                  child: imgTile,
                ),
              ),
            ),


            Center(
              child: TextButton(
                onPressed: () { pickImage(); },
                child: Text("CLEAR"),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
