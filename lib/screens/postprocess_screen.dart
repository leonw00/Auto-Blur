import 'package:auto_blur/objects/postprocess_button.dart';
import 'package:auto_blur/wrapper/base_template.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PostProcessScreen extends StatefulWidget {

  final imagePainter;
  final imageBytes;
  final imageWidth;
  final imageHeight;

  PostProcessScreen({this.imageBytes, this.imagePainter, this.imageWidth, this.imageHeight});

  @override
  _PostProcessScreenState createState() => _PostProcessScreenState();
}

class _PostProcessScreenState extends State<PostProcessScreen> {

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
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.all(Radius.circular(20))
                  ),
                  child: FittedBox(
                    child: Container(
                      width: widget.imageWidth,
                      height: widget.imageHeight,
                      child: widget.imagePainter,
                    ),
                  ),
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
                      function: (){},
                    ),

                    // share Button
                    PostProcessButton(
                      size: iconSize,
                      icon: Icons.share,
                      function: (){},
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
