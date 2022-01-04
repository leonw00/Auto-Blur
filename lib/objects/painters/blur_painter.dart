import 'dart:ui' as ui;
import 'package:auto_blur/logic/size_to_rect.dart';
import 'package:flutter/material.dart';

class BlurPainter extends CustomPainter {

  BlurPainter(this.rect, this.image, this.width, this.height);

  final List<Rect> rect;
  ui.Image image;
  var picture;
  var finalImage;
  double width;
  double height;

  @override
  void paint(Canvas canvas, Size size) {

    Size imageSize = new Size(width, height);

    Paint shaderPaint = Paint();

    Paint framePaint = Paint()
      ..color = Color(0xffaa0000)
      ..style = PaintingStyle.stroke
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4)
      ..strokeWidth = 6;


    Matrix4 matrix = sizeToRect(imageSize, Offset.zero & size);
    // inverseMatrix = Matrix4.copy(matrix)..invert();
    shaderPaint.shader = ImageShader(image, TileMode.clamp, TileMode.clamp, matrix.storage);
    Rect clip = MatrixUtils.transformRect(matrix, Offset.zero & imageSize);


    // draw the base image
    canvas.drawImage(image, Offset.zero, Paint()..style = PaintingStyle.fill);

    // cover the selected regions
    for (var i = 0; i <= rect.length - 1; i++) {
      canvas.clipRect(rect[i]);
    }

    // set the selected regions to be blurred
    canvas.drawRect(clip, shaderPaint..imageFilter = ui.ImageFilter.blur(sigmaX: 50, sigmaY: 50));
  }

  @override
  bool shouldRepaint(oldDelegate) {
    return true;
  }

  Future<ui.Image> getImage() async {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(recorder);
    BlurPainter painter = BlurPainter(rect, image, width, height);
    var size = Size(width, height);
    painter.paint(canvas, size);
    final ui.Picture picture = recorder.endRecording();
    return await picture.toImage(width.toInt(), height.toInt());
  }
}