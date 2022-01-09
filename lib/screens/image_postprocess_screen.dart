import 'package:auto_blur/logic/process_media.dart';
import 'package:auto_blur/objects/others/postprocess_row.dart';
import 'package:auto_blur/objects/postprocess_button.dart';
import 'package:auto_blur/wrapper/base_image_wrapper.dart';
import 'package:auto_blur/wrapper/base_template.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImagePostProcessScreen extends StatefulWidget {

  final imagePainter;
  final imageBytes;
  final imageWidth;
  final imageHeight;

  ImagePostProcessScreen({this.imageBytes, this.imagePainter, this.imageWidth, this.imageHeight});

  @override
  _ImagePostProcessScreenState createState() => _ImagePostProcessScreenState();
}

class _ImagePostProcessScreenState extends State<ImagePostProcessScreen> {

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
              child: BaseImageWrapper(
                child: FittedBox(
                  child: Container(
                    width: widget.imageWidth,
                    height: widget.imageHeight,
                    child: widget.imagePainter,
                  ),
                ),
                hasContinue: false,
              ),
            ),

            Positioned(
              bottom: 0,
              width: screenWidth,
              height: screenHeight / 9,
              child: PostProcessRow(
                save: (){
                  saveImage(widget.imageBytes);
                },
                share: (){
                  shareImage(widget.imageBytes);
                },
              ),
            ),
          ],
        ),
      )
    );
  }
}
