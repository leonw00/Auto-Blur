import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Painter extends CustomPainter {

  Painter(this.rect, this.image);

  final List<Rect> rect;
  ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..style = PaintingStyle.fill;

    var bluer = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7;


    canvas.drawImage(image, Offset.zero, paint);
    for (var i = 0; i <= rect.length - 1; i++) {
      canvas.drawRect(rect[i], bluer);
    }
  }

  @override
  bool shouldRepaint(oldDelegate) {
    return true;
  }
}