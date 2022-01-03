import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PostProcessButton extends StatelessWidget {

  final icon;
  final size;
  final function;

  PostProcessButton({this.icon, this.function, this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: double.infinity,
        alignment: Alignment.center,
        child: IconButton(
          onPressed: (){this.function();},
          padding: EdgeInsets.zero,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          icon: Icon(
            this.icon,
            color: Colors.white54,
            size: this.size,
          ),
        )
    );
  }
}
