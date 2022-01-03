import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:auto_blur/objects/painter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';


Future processImage(String link, int width, int height) async {
  final faceDetector = GoogleMlKit.vision.faceDetector();
  List<Rect> rectArr = [];

  // convert the ints into doubles
  double imageWidth = width.toDouble();
  double imageHeight = height.toDouble();

  // get the image
  final inputImage = InputImage.fromFilePath(link);

  // detect the faces
  final List<Face> faces = await faceDetector.processImage(inputImage);
  print('Found ${faces.length} faces');

  for (Face face in faces) {
    final Rect boundingBox = face.boundingBox;

    final double? rotY = face.headEulerAngleY; // Head is rotated to the right rotY degrees
    final double? rotZ = face.headEulerAngleZ; // Head is tilted sideways rotZ degrees

    rectArr.add(boundingBox);
  }

  var bytesFromImageFile = await File(link).readAsBytes();

  var finalImagePainter;
  var finalImageBytes;

  await decodeImageFromList(bytesFromImageFile).then((img) async {
    // Convert Canvas to Image
    var pImage = await Painter(rectArr, img, imageWidth, imageHeight).getImage();
    var pngBytes = await pImage.toByteData(format: ui.ImageByteFormat.png);
    var uintBytes = pngBytes!.buffer.asUint8List();

    finalImagePainter = CustomPaint(
      painter: Painter(rectArr, img, imageWidth, imageHeight),
    );

    finalImageBytes = uintBytes;

  });

  return {"image" : finalImagePainter, "bytes" : finalImageBytes, "width" : imageWidth, "height" : imageHeight};

}

Future saveImage(var bytes) async {

  // path directory for saving
  final imageFile = (await getExternalStorageDirectory())!.path + "/autoblurtemp";

  // check if folder exists
  final dir = Directory(imageFile);

  await dir.exists().then((exist){
    // create folder
    if(!exist){dir.create();}
  }) ;

  // create random file name
  var randomString = generateRandomString(10);

  // Save the image to desired location
  var savedImage = new File("$imageFile/{$randomString}").writeAsBytes(bytes);
}

String generateRandomString(int len) {
  var r = Random();
  return String.fromCharCodes(List.generate(len, (index) => r.nextInt(33) + 89));
}