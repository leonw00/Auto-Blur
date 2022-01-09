import 'dart:io';
import 'package:auto_blur/logic/process_media.dart';
import '../wrapper/base_image_wrapper.dart';
import 'package:auto_blur/screens/image_postprocess_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImageContainer extends StatelessWidget {

  final link;

  ImageContainer({this.link});


  @override
  Widget build(BuildContext context) {

    var imageFile = File(this.link);

    return BaseImageWrapper(

      child: Image.file(
        imageFile,
        fit: BoxFit.contain,
      ),

      function: () async {
        // decode image to get size
        var decodedImage = await decodeImageFromList(imageFile.readAsBytesSync());

        // process the image
        await processImage(this.link, decodedImage.width, decodedImage.height).then((processed){

          // go to a new screen to show the processed the image
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ImagePostProcessScreen(
              imagePainter: processed["image"],
              imageBytes: processed["bytes"],
              imageWidth: processed["width"],
              imageHeight: processed["height"],
            )),
          );
        });

        // show ad

      },

    );
  }
}
