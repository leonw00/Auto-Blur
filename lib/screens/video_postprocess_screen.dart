import 'dart:io';
import 'package:auto_blur/logic/process_media.dart';
import 'package:auto_blur/objects/postprocess_button.dart';
import 'package:auto_blur/wrapper/base_template.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPostProcessScreen extends StatefulWidget {

  final link;

  VideoPostProcessScreen({this.link});

  @override
  _VideoPostProcessScreenState createState() => _VideoPostProcessScreenState();
}

class _VideoPostProcessScreenState extends State<VideoPostProcessScreen> {


  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    // show the video on the screen
    var video = File(widget.link);
    _controller = VideoPlayerController.file(video);
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

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    double iconSize = screenHeight / 14;

    return BaseWrapper(
        body: Container(
          width: double.infinity,
          child: Stack(
            children: [
              Center(
                child: FractionallySizedBox(
                  widthFactor: 0.85,
                  heightFactor: 0.9,
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.all(Radius.circular(20))
                        ),
                        child: FutureBuilder(
                          future: _initializeVideoPlayerFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              // If the VideoPlayerController has finished initialization, use
                              // the data it provides to limit the aspect ratio of the video.
                              return FittedBox(
                                fit: BoxFit.contain,
                                child: SizedBox(
                                  width: _controller.value.size.width,
                                  height: _controller.value.size.height,
                                  child: VideoPlayer(_controller),
                                ),
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


                      Positioned(
                        bottom: screenHeight / 9 + 10,
                        left: 30,
                        child: Container(
                          height: 45,
                          width: 45,
                          decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.all(Radius.circular(50))
                          ),
                          child: Center(
                            child: IconButton(
                              onPressed: (){
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
                              iconSize: 30,
                              color: Colors.white,
                              icon: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow,),
                            ),
                          ),
                        ),
                      ),
                    ]
                  ),
                ),
              ),

              Positioned(
                bottom: 0,
                width: screenWidth,
                height: screenHeight / 9,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(15.0),
                      topLeft: Radius.circular(15.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      // Back Button
                      PostProcessButton(
                        size: iconSize,
                        icon: Icons.arrow_back,
                        function: (){
                          Navigator.pop(context);
                        },
                      ),

                      // Edit Button
                      PostProcessButton(
                        size: iconSize,
                        icon: Icons.edit,
                        function: (){},
                      ),

                      // Discard Button
                      PostProcessButton(
                        size: iconSize,
                        icon: Icons.close,
                        function: (){
                          Navigator.popAndPushNamed(context, "/");
                        },
                      ),

                      // Save Button
                      PostProcessButton(
                        size: iconSize,
                        icon: Icons.download,
                        function: (){
                          saveVideo(widget.link);
                        },
                      ),

                      // share Button
                      PostProcessButton(
                        size: iconSize,
                        icon: Icons.share,
                        function: (){
                          shareVideo(widget.link);
                        },
                      ),

                    ],
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }
}
