import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:auto_blur/objects/painters/normal_painter.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_ffmpeg/media_information.dart';

import '../objects/painters/blur_painter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:path_provider/path_provider.dart';


String generateRandomString(int len) {
  var r = Random();
  const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  return List.generate(len, (index) => _chars[r.nextInt(_chars.length)]).join();
}


Future<String> createFolder() async {
  final dir = Directory((await getExternalStorageDirectory())!.path + "/autoblurtemp");
  // var status = await Permission.storage.status;
  // if (!status.isGranted) {
  //   await Permission.storage.request();
  // }
  if ((await dir.exists())) {
    return dir.path;
  } else {
    dir.create();
    return dir.path;
  }
}

Future<void> deleteFile(File file) async {
  try {
    if (await file.exists()) {
      await file.delete();
    }
  } catch (e) {}
}

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

    var painter;

    // if there exists a face
    if(rectArr.isNotEmpty) {
      painter = BlurPainter(rectArr, img, imageWidth, imageHeight);
    }
    else{
      painter = NormalPainter(img, imageWidth, imageHeight);
    }

    // Convert Canvas to Image
    var pImage = await painter.getImage();
    var pngBytes = await pImage.toByteData(format: ui.ImageByteFormat.png);
    var uintBytes = pngBytes!.buffer.asUint8List();

    // show progress toast
    EasyLoading.showProgress(1, status: "Finalizing Image...");

    // assign the returned variables
    finalImagePainter = CustomPaint(
      painter: painter,
    );
    finalImageBytes = uintBytes;

  });

  // dismiss the loading toast
  EasyLoading.dismiss();

  return {"image" : finalImagePainter, "bytes" : finalImageBytes, "width" : imageWidth, "height" : imageHeight};

}

Future saveImage(var bytes) async {

  // path directory for saving
  final imageDir = createFolder();

  // create random file name
  var randomString = generateRandomString(10);

  // create the saved file location
  String saveLocation = "$imageDir/$randomString.png";

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

Future processVideo(String videoPath, int width, int height) async {

  List<List<Rect>> facesArr = [];   // rect positions
  var frames = [];                  // list of frames
  var finalFrames = [];             // list of the final frames

  final faceDetector = GoogleMlKit.vision.faceDetector();
  final FlutterFFprobe flutterFFprobe = FlutterFFprobe();
  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();

  // create the folder
  await createFolder();

  // get the video details
  MediaInformation mediaInformation = await flutterFFprobe.getMediaInformation(videoPath);
  Map<dynamic, dynamic> mp = mediaInformation.getMediaProperties()!;
  var videoDuration = (double.parse(mp["duration"])).toInt();
  var videoWidth = double.parse(width.toString());
  var videoHeight = double.parse(height.toString());
  var frameRate = 12;
  var saveDigits = 6;


  // the path for the new image file
  final fileImg = (await getExternalStorageDirectory())!.path + "/autoblurtemp";


  // convert from the images to video using ffmpeg
  await _flutterFFmpeg.execute(
    '-i $videoPath -vf fps=$frameRate $fileImg/thumb_%${saveDigits}d.png',
  ).then((rc)=>print("FFmpeg process exited with rc $rc"));


  // get the frames for the video
  for(int i = 1; i < (frameRate * videoDuration).round(); i++){

    // save the new video frames into an external file
    var pathNum = (i / 1000000).toString().substring(2);
    // append the path with 0 if it's not of a certain length
    while(pathNum.length < saveDigits){
      pathNum += "0";
    }

    // we will get the path of the images
    var imagePath = "$fileImg/thumb_$pathNum.png";

    // save the image to the path
    var initialFrames = new File(imagePath);

    // add the files to the list of final frames
    frames.add(initialFrames);
  }

  for(var frame in frames){
    // getting the image from file path
    final inputImage = InputImage.fromFile(frame);

    List<Rect> boxes = [];    // initialize the list of boxes

    final List<Face> faces = await faceDetector.processImage(inputImage);

    for (Face face in faces) {
      final Rect boundingBox = face.boundingBox;

      boxes.add(boundingBox);
    }

    facesArr.add(boxes);
  }



  int frameCount = 0;
  // apply the effect into the video frames
  for(var frame in frames){
    // decode the image to bytes
    await frame.readAsBytes().then((bytesFromImageFile) async {

      // converting from the bytes to the image
      await decodeImageFromList(bytesFromImageFile).then((img) async {

        // Convert Canvas with applied effect to Image
        var pImage = await BlurPainter(facesArr[frameCount], img, videoWidth, videoHeight).getImage();
        var pngBytes = await pImage.toByteData(format: ui.ImageByteFormat.png);
        var uintBytes = pngBytes!.buffer.asUint8List();

        // the path for the new image file
        final imageFile = (await getExternalStorageDirectory())!.path + "/autoblurtemp";

        // save the new video frames into an external file
        var pathNum = (frameCount / 1000000).toString().substring(2);
        // append the path with 0 if it's not of a certain length
        while(pathNum.length < saveDigits){
          pathNum += "0";
        }

        // we will get the new path
        var newPath = "$imageFile/image_$pathNum.png";

        // save the image to the path
        var saveNewFrames = await File(newPath).writeAsBytes(uintBytes);

        decodeImageFromList(saveNewFrames.readAsBytesSync()).then((img){

        });


        // add the files to the list of final frames
        finalFrames.add(saveNewFrames);

        frameCount++;
      });
    });
  }


  // remove all the files
  for(int i = 0; i < frames.length; i++){
    // remove the original video frames
    deleteFile(frames[i]);
    // remove the new video frames
    deleteFile(finalFrames[i]);
  }
}
