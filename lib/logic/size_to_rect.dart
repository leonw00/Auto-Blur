import 'package:flutter/material.dart';

/// Return a scaled and translated [Matrix4] that maps [src] to [dst] for given [fit]
/// aligned by [alignment] within [dst]
///
/// For example, if you have a [CustomPainter] with size 300 x 200 logical pixels and
/// you want to draw an expanded, centered image with size 80 x 100 you can do the following:
///
/// ```dart
///  canvas.save();
///  var matrix = sizeToRect(imageSize, Offset.zero & customPainterSize);
///  canvas.transform(matrix.storage);
///  canvas.drawImage(image, Offset.zero, Paint());
///  canvas.restore();
/// ```
///
///  and your image will be drawn inside a rect Rect.fromLTRB(70, 0, 230, 200)
Matrix4 sizeToRect(Size src, Rect dst, {BoxFit fit = BoxFit.contain, Alignment alignment = Alignment.center}) {
  FittedSizes fs = applyBoxFit(fit, src, dst.size);
  double scaleX = fs.destination.width / fs.source.width;
  double scaleY = fs.destination.height / fs.source.height;
  Size fittedSrc = Size(src.width * scaleX, src.height * scaleY);
  Rect out = alignment.inscribe(fittedSrc, dst);

  return Matrix4.identity()
    ..translate(out.left, out.top)
    ..scale(scaleX, scaleY);
}

/// Like [sizeToRect] but accepting a [Rect] as [src]
Matrix4 rectToRect(Rect src, Rect dst, {BoxFit fit = BoxFit.contain, Alignment alignment = Alignment.center}) {
  return sizeToRect(src.size, dst, fit: fit, alignment: alignment)
    ..translate(-src.left, -src.top);
}