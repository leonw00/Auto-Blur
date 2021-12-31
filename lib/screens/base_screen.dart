import 'dart:io';
import 'dart:ui' as ui;
import 'package:auto_blur/objects/media_container.dart';
import 'package:auto_blur/objects/painter.dart';
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


  final ImagePicker _picker = ImagePicker();
  final faceDetector = GoogleMlKit.vision.faceDetector();

  List<Rect> rectArr = [];

  var imagePainted;
  var imgTile;

  Future pickImage() async {
    // Pick an image
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    return image;
  }

  Future processImage() async {
    rectArr = [];

    // Pick an image
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    final inputImage = InputImage.fromFilePath(image!.path);


    // detect the faces
    final List<Face> faces = await faceDetector.processImage(inputImage);
    print('Found ${faces.length} faces');

    for (Face face in faces) {
      final Rect boundingBox = face.boundingBox;

      final double? rotY = face.headEulerAngleY; // Head is rotated to the right rotY degrees
      final double? rotZ = face.headEulerAngleZ; // Head is tilted sideways rotZ degrees

      rectArr.add(boundingBox);
    }

    var bytesFromImageFile = await File(image.path).readAsBytes();


    // create folder
    final dir = Directory((await getExternalStorageDirectory())!.path + "/autoblurtemp");
    dir.create();

    // path directory for saving
    final imageFile = (await getExternalStorageDirectory())!.path + "/autoblurtemp";


    decodeImageFromList(bytesFromImageFile).then((img) async {
      // Convert Canvas to Image
      var pImage = await Painter(rectArr, img, 640, 360).getImage();
      var pngBytes = await pImage.toByteData(format: ui.ImageByteFormat.png);
      var uintBytes = pngBytes!.buffer.asUint8List();

      // Save the image to desired location
      var saveNewFrames = new File("$imageFile/image_hehe").writeAsBytes(uintBytes);


      setState(() {
        imgTile = CustomPaint(
          painter: Painter(rectArr, img, 640, 360),
        );
      });

    });
  }

  Widget defaultWidget = Center(
    child: Text(
      "Select a picture or video ...",
      style: TextStyle(fontSize: 18),
    ),
  );

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
                    defaultWidget = MediaContainer(link: image!.path,);
                  });
                });
              },
              padding: EdgeInsets.zero,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: Icon(Icons.image, size: 50, color: Colors.grey,)),
          SizedBox(width: 15,),
          Icon(Icons.video_collection, size: 50, color: Colors.grey,),
          SizedBox(width: 15,),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: defaultWidget,
      ),
    );
  }
}
