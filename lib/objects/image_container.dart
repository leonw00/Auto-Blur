import 'dart:io';

import 'package:auto_blur/screens/postprocess_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImageContainer extends StatelessWidget {

  final link;

  ImageContainer({this.link});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
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
                child: Image.file(
                  File(this.link),
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  height: 45,
                  width: 150,
                  decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.all(Radius.circular(50))
                  ),
                  child: Center(
                    child: TextButton(
                      onPressed: (){
                        // popup to show loading

                        // go to a new screen to show the processed the image
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PostProcessScreen()),
                        );

                        // show ad
                      },
                      child: Text(
                        "Continue",
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ]
        ));
  }
}
