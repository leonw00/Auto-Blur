import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class NormalPainter extends CustomPainter {

  NormalPainter(this.image, this.width, this.height);

  ui.Image image;
  var picture;
  var finalImage;
  double width;
  double height;

  @override
  void paint(Canvas canvas, Size size) {
    // draw the base image
    canvas.drawImage(image, Offset.zero, Paint()..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(oldDelegate) {
    return true;
  }

  Future<ui.Image> getImage() async {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(recorder);
    NormalPainter painter = NormalPainter(image, width, height);
    var size = Size(width, height);
    painter.paint(canvas, size);
    final ui.Picture picture = recorder.endRecording();
    return await picture.toImage(width.toInt(), height.toInt());
  }
}