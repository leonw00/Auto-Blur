import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import '../objects/painters/blur_painter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:path_provider/path_provider.dart';


Future processImage(String link, int width, int height) async {

  // show progress toast
  EasyLoading.showProgress(0.2, status: "Processing Image...");

  final faceDetector = GoogleMlKit.vision.faceDetector();
  List<Rect> rectArr = [];

  // convert the ints into doubles
  double imageWidth = width.toDouble();
  double imageHeight = height.toDouble();

  // show progress toast
  EasyLoading.showProgress(0.5, status: "Detecting Faces...");

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

  // show progress toast
  EasyLoading.showProgress(0.7, status: "Blurring Faces...");

  var bytesFromImageFile = await File(link).readAsBytes();

  var finalImagePainter;
  var finalImageBytes;

  await decodeImageFromList(bytesFromImageFile).then((img) async {
    // Convert Canvas to Image
    var pImage = await BlurPainter(rectArr, img, imageWidth, imageHeight).getImage();
    var pngBytes = await pImage.toByteData(format: ui.ImageByteFormat.png);
    var uintBytes = pngBytes!.buffer.asUint8List();

    // show progress toast
    EasyLoading.showProgress(1, status: "Finalizing Image...");

    // if there exists a face
    if(rectArr.isNotEmpty) {
      finalImagePainter = CustomPaint(
        painter: BlurPainter(rectArr, img, imageWidth, imageHeight),
      );
      finalImageBytes = uintBytes;
    }
    else{
      finalImagePainter = CustomPaint(
        painter: BlurPainter(rectArr, img, imageWidth, imageHeight),
      );
      finalImageBytes = uintBytes;
    }

  });

  // dismiss the loading toast
  EasyLoading.dismiss();

  return {"image" : finalImagePainter, "bytes" : finalImageBytes, "width" : imageWidth, "height" : imageHeight};

}

Future saveImage(var bytes) async {

  // path directory for saving
  final imageFile = (await getExternalStorageDirectory())!.path + "/autoblurtemp";

  // check if folder exists
  final dir = Directory(imageFile);

  await dir.exists().then((exist) async {
    // create folder
    if(!exist){await dir.create();}
  }) ;

  // create random file name
  var randomString = generateRandomString(10);

  // create the saved file location
  String saveLocation = "$imageFile/$randomString.png";

  print(saveLocation);

  // Save the image to desired location
  var savedImage = await new File(saveLocation).writeAsBytes(bytes);

  // save image to gallery
  GallerySaver.saveImage(saveLocation).then((status){
    if(status!){
      EasyLoading.showSuccess("Image saved!");
      Future.delayed(const Duration(milliseconds: 500), (){
        EasyLoading.dismiss();
      });
    }
  });

}

String generateRandomString(int len) {
  var r = Random();
  const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  return List.generate(len, (index) => _chars[r.nextInt(_chars.length)]).join();
}