import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class Painter extends CustomPainter {

  Painter(this.rect, this.image);

  final List<Rect> rect;
  ui.Image image;
  var picture;
  var finalImage;

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

  Future<ui.Image> getImage() async {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(recorder);
    Painter painter = Painter(rect, image);
    var size = Size(640, 360);
    painter.paint(canvas, size);
    final ui.Picture picture = recorder.endRecording();
    return await picture.toImage(size.width.toInt(), size.height.toInt());
  }
}