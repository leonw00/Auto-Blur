import 'dart:io';
import 'dart:ui' as ui;
import 'package:auto_blur/objects/painter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

final ImagePicker _picker = ImagePicker();
final faceDetector = GoogleMlKit.vision.faceDetector();

List<Rect> rectArr = [];

var imagePainted;
var imgTile;

Future pickImage() async {
  // Pick an image
  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
  final inputImage = InputImage.fromFilePath(image!.path);

  return inputImage;
}

Future processImage(InputImage inputImage) async {
  rectArr = [];

  // detect the faces
  final List<Face> faces = await faceDetector.processImage(inputImage);
  print('Found ${faces.length} faces');

  for (Face face in faces) {
    final ui.Rect boundingBox = face.boundingBox;

    final double? rotY = face
        .headEulerAngleY; // Head is rotated to the right rotY degrees
    final double? rotZ = face
        .headEulerAngleZ; // Head is tilted sideways rotZ degrees

    rectArr.add(boundingBox);
  }

  var bytesFromImageFile = await File(image.path).readAsBytes();


  // create folder
  final dir = Directory(
      (await getExternalStorageDirectory())!.path + "/autoblurtemp");
  dir.create();

  // path directory for saving
  final imageFile = (await getExternalStorageDirectory())!.path +
      "/autoblurtemp";


  decodeImageFromList(bytesFromImageFile).then((img) async {
    // Convert Canvas to Image
    var pImage = await Painter(rectArr, img, 640, 360).getImage();
    var pngBytes = await pImage.toByteData(format: ui.ImageByteFormat.png);
    var uintBytes = pngBytes!.buffer.asUint8List();

    // Save the image to desired location
    var saveNewFrames = new File("$imageFile/image_hehe").writeAsBytes(
        uintBytes);


    setState(() {
      imgTile = CustomPaint(
        painter: Painter(rectArr, img, 640, 360),
      );
    });
  });
}