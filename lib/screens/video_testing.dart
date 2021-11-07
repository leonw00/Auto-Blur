import 'dart:io';
import 'dart:ui' as ui;
import 'package:auto_blur/objects/painter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_ffmpeg/media_information.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';



class TestVideo extends StatefulWidget {
  @override
  _TestVideoState createState() => _TestVideoState();
}

class _TestVideoState extends State<TestVideo> {

  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  final ImagePicker _picker = ImagePicker();
  final faceDetector = GoogleMlKit.vision.faceDetector();
  final FlutterFFprobe flutterFFprobe = FlutterFFprobe();
  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();

  late ui.Image uiImage;

  var imgTile;


  Future<void> deleteFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Error in getting access to the file.
    }
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

  Future pickImage() async {

    List<List<Rect>> facesArr = [];   // rect positions
    var frames = [];                  // list of frames
    var finalFrames = [];             // list of the final frames

    // Pick a video
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);


    // get the video details
    var videoPath = video!.path;
    MediaInformation mediaInformation = await flutterFFprobe.getMediaInformation(videoPath);
    Map<dynamic, dynamic> mp = mediaInformation.getMediaProperties()!;
    var videoDuration = (double.parse(mp["duration"]) * 1000).toInt();
    var timePerFrame = 1000 ~/ 24;


    // the path for the new image file
    final fileImg = (await getExternalStorageDirectory())!.path + "/autoblurtemp";

    // get the frames of the video
    for(int i = 0; i < videoDuration; i+=timePerFrame) {

      var videoFrameBytes = await VideoThumbnail.thumbnailData(
        video: videoPath,
        imageFormat: ImageFormat.PNG,
        maxWidth: 640, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
        maxHeight: 360,
        quality: 25,
        timeMs: i,
      );

      // we will get the path to store it into
      var newPath = "$fileImg/image_$i.png";

      // save the image to the path
      var saveNewFrames = await File(newPath).writeAsBytes(videoFrameBytes!);

      frames.add(saveNewFrames);
    }



    for(var frame in frames){
      // getting the image from file path
      final inputImage = InputImage.fromFilePath(frame.path);

      List<Rect> boxes = [];    // initialize the list of boxes

      final List<Face> faces = await faceDetector.processImage(inputImage);

      for (Face face in faces) {
        final Rect boundingBox = face.boundingBox;

        boxes.add(boundingBox);
      }

      facesArr.add(boxes);
    }

    // create the folder
    await createFolder();


    int frameCount = 0;
    // apply the effect into the video frames
    for(var frame in frames){
      // decode the image to bytes
      var bytesFromImageFile = await frame.readAsBytes();


      // converting from the bytes to the image
      decodeImageFromList(bytesFromImageFile).then((img) async {

        // Convert Canvas with applied effect to Image
        var pImage = await Painter(facesArr[frameCount], img).getImage();
        var pngBytes = await pImage.toByteData(format: ui.ImageByteFormat.png);
        var uintBytes = pngBytes!.buffer.asUint8List();

        // the path for the new image file
        final imageFile = (await getExternalStorageDirectory())!.path + "/autoblurtemp";


        // save the new video frames into an external file
        var pathNum = (frameCount / 1000000).toString().substring(2);
        // append the path with 0 if it's not of a certain length
        while(pathNum.length < 6){
          pathNum += "0";
        }

        // we will get the new path
        var newPath = "$imageFile/image_$pathNum.png";

        // save the image to the path
        var saveNewFrames = await File(newPath).writeAsBytes(uintBytes);

        print(saveNewFrames.path);

        // add the files to the list of final frames
        finalFrames.add(saveNewFrames);

        print("************   NEXT *****************");
      });

      frameCount++;
    }


    print("********** OUT OF THE LOOP ****************");


    await mergeToVideo();



    // remove all the files
    for(int i = 0; i < frames.length; i++){
      // remove the original video frames
      deleteFile(frames[i]);
      // // remove the new video frames
      deleteFile(finalFrames[i]);
    }
  }


  Future<void> mergeToVideo() async {
    deleteFile(new File("/storage/emulated/0/Android/data/hoxy.auto_blur/files/autoblurtemp/out.mp4"));

    // the path for the stored image file
    final imageFile = (await getExternalStorageDirectory())!.path + "/autoblurtemp";


    // convert from the images to video using ffmpeg
    await _flutterFFmpeg.execute(
      '-framerate 24 -i $imageFile/image_%6d.png $imageFile/out.mp4',
    ).then((rc)=>print("FFmpeg process exited with rc $rc"));


    // show the video on the screen
    var newVideo = File("$imageFile/out.mp4");


    print(newVideo.path);
    print(newVideo);


    _controller = VideoPlayerController.file(newVideo);

    _initializeVideoPlayerFuture = _controller.initialize();
  }


  @override
  void initState() {
    // Create and store the VideoPlayerController. The VideoPlayerController
    // offers several different constructors to play videos from assets, files,
    // or the internet.
    _controller = VideoPlayerController.network(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    );

    _initializeVideoPlayerFuture = _controller.initialize();

    super.initState();
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller.dispose();

    super.dispose();
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
              child: FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    // If the VideoPlayerController has finished initialization, use
                    // the data it provides to limit the aspect ratio of the video.
                    return AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      // Use the VideoPlayer widget to display the video.
                      child: VideoPlayer(_controller),
                    );
                  } else {
                    // If the VideoPlayerController is still initializing, show a
                    // loading spinner.
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),


            FloatingActionButton(
              onPressed: () {
                // Wrap the play or pause in a call to `setState`. This ensures the
                // correct icon is shown.
                setState(() {
                  // If the video is playing, pause it.
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                  } else {
                    // If the video is paused, play it.
                    _controller.play();
                  }
                });
              },
              // Display the correct icon depending on the state of the player.
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            ),


          ],
        ),
      ),
    );
  }

}
