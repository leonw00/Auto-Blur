import 'package:auto_blur/objects/postprocess_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PostProcessRow extends StatelessWidget {

  final Function save;
  final Function share;

  PostProcessRow({required this.share, required this.save});

  @override
  Widget build(BuildContext context) {
    double iconSize = MediaQuery.of(context).size.height / 14;

  return Container(
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
              this.save();
            },
          ),

          // share Button
          PostProcessButton(
            size: iconSize,
            icon: Icons.share,
            function: (){
              this.share();
            },
          ),

        ],
      ),
  );
  }
}
