import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImagePostProcess extends StatefulWidget {
  @override
  _ImagePostProcessState createState() => _ImagePostProcessState();
}

class _ImagePostProcessState extends State<ImagePostProcess> {

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
                  File(""),
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
                        // go to a new screen to process the image

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
