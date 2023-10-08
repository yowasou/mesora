import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'coordinates_translator.dart';

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(
    this.faces,
    this.imageSize,
    this.rotation,
    this.cameraLensDirection,
  );

  final List<Face> faces;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint1 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.red;
    final Paint paint2 = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.0
      ..color = Colors.green;

    final Paint paint3 = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.0
      ..color = Colors.blue;

    final Paint paint4 = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.0
      ..color = Colors.purple;

    for (final Face face in faces) {
      final left = translateX(
        face.boundingBox.left,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final top = translateY(
        face.boundingBox.top,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final right = translateX(
        face.boundingBox.right,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final bottom = translateY(
        face.boundingBox.bottom,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );

      canvas.drawRect(
        Rect.fromLTRB(left, top, right, bottom),
        paint1,
      );

      void paintContour(FaceContourType type) {
        final contour = face.contours[type];
        if (contour?.points != null) {
          for (final Point point in contour!.points) {
            canvas.drawCircle(
                Offset(
                  translateX(
                    point.x.toDouble(),
                    size,
                    imageSize,
                    rotation,
                    cameraLensDirection,
                  ),
                  translateY(
                    point.y.toDouble(),
                    size,
                    imageSize,
                    rotation,
                    cameraLensDirection,
                  ),
                ),
                1,
                paint1);
          }
        }
      }

      void paintLandmark(FaceLandmarkType type) {
        final landmark = face.landmarks[type];
        if (landmark?.position != null) {
          canvas.drawCircle(
              Offset(
                translateX(
                  landmark!.position.x.toDouble(),
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                ),
                translateY(
                  landmark.position.y.toDouble(),
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                ),
              ),
              2,
              paint2);
        }
      }

      void paintLeftEye() {
        for (final Face face in faces) {
          final contour = face.contours[FaceContourType.leftEye];
          if (contour != null) {
            List<int> x = [];
            List<int> y = [];
            for (var element in contour.points) {
              x.add(element.x);
            }
            for (var element in contour.points) {
              y.add(element.y);
            }
            final maxX = x.reduce(max);
            final maxY = y.reduce(max);
            final minX = x.reduce(min);
            final minY = y.reduce(min);
            print('$maxX, $maxY, $minX, $minY');
            canvas.drawRect(
              translateRect(size, maxX, maxY, minX, minY),
              paint3,
            );
            break;
          }
        }
      }

      void paintRightEye() {
        for (final Face face in faces) {
          final contour = face.contours[FaceContourType.rightEye];
          if (contour != null) {
            List<int> x = [];
            List<int> y = [];
            for (var element in contour.points) {
              x.add(element.x);
            }
            for (var element in contour.points) {
              y.add(element.y);
            }
            final maxX = x.reduce(max);
            final maxY = y.reduce(max);
            final minX = x.reduce(min);
            final minY = y.reduce(min);
            print('$maxX, $maxY, $minX, $minY');
            canvas.drawRect(
              translateRect(size, maxX, maxY, minX, minY),
              paint4,
            );
            break;
          }
        }
      }

      for (final type in FaceContourType.values) {
        paintContour(type);
      }

      for (final type in FaceLandmarkType.values) {
        paintLandmark(type);
      }

      paintLeftEye();
      paintRightEye();
    }
  }

  Rect translateRect(Size size, int l, int t, int r, int b) {
    final left = translateX(
      l.toDouble(),
      size,
      imageSize,
      rotation,
      cameraLensDirection,
    );
    final top = translateY(
      t.toDouble(),
      size,
      imageSize,
      rotation,
      cameraLensDirection,
    );
    final right = translateX(
      r.toDouble(),
      size,
      imageSize,
      rotation,
      cameraLensDirection,
    );
    final bottom = translateY(
      b.toDouble(),
      size,
      imageSize,
      rotation,
      cameraLensDirection,
    );
    return Rect.fromLTRB(left, top, right, bottom);
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.faces != faces;
  }
}
