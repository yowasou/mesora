import 'dart:math';
import 'package:camera/camera.dart';
import 'package:convert_native_img_stream/convert_native_img_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

import 'detect_eye_data.dart';
import 'detector_view.dart';
import 'painters/face_detector_painter.dart';

class FaceDetectorView extends StatefulWidget {
  @override
  State<FaceDetectorView> createState() => _FaceDetectorViewState();
}

class _FaceDetectorViewState extends State<FaceDetectorView> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
    ),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.front;

  final convertNative = ConvertNativeImgStream();

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DetectorView(
      title: 'Face Detector',
      customPaint: _customPaint,
      text: _text,
      onImage: _processImage,
      initialCameraLensDirection: _cameraLensDirection,
      onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
    );
  }

  Future<void> _processImage(InputImage inputImage, CameraImage image) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    // setState(() {
    //   _text = '';
    // });
    final faces = await _faceDetector.processImage(inputImage);
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      // final painter = FaceDetectorPainter(
      //   faces,
      //   inputImage.metadata!.size,
      //   inputImage.metadata!.rotation,
      //   _cameraLensDirection,
      // );
      // _customPaint = CustomPaint(painter: painter);

      if (faces.isNotEmpty) {
        if (DetectEyeData().mode == DetectMode.Calib) {
          _isBusy = false;
          // キャリブレーションチェック
          if (faces.first.boundingBox.height > 700) {
            // キャリブレーション完了
            DetectEyeData().mode = DetectMode.Detect;
          }
          return;
        }
      }

      // CameraImage->Jpeg変換
      final bytes = await convertNative.convertImgToBytes(image.planes.first.bytes, image.width, image.height, rotationFix: 270, quality: 20);
      final imageJpeg = img.decodeJpg(bytes!);
      for (final Face face in faces) {
        // 左目検出
        final contourLeft = face.contours[FaceContourType.leftEye];
        if (contourLeft != null) {
          List<int> x = [];
          List<int> y = [];
          for (var element in contourLeft.points) {
            x.add(element.x);
          }
          for (var element in contourLeft.points) {
            y.add(element.y);
          }
          final maxX = x.reduce(max);
          final maxY = y.reduce(max);
          final minX = x.reduce(min);
          final minY = y.reduce(min);
          img.Image crop = img.copyCrop(imageJpeg!, x: minX, y: minY, width: (maxX - minX), height: (maxY - minY));
          // DetectEyeData().leftEyeJpeg = imglib.encodeJpg(crop).buffer.asUint8List();
          DetectEyeData().leftEyeImage = crop;
        }

        // 右目検出
        final contourRight = face.contours[FaceContourType.rightEye];
        if (contourRight != null) {
          List<int> x = [];
          List<int> y = [];
          for (var element in contourRight.points) {
            x.add(element.x);
          }
          for (var element in contourRight.points) {
            y.add(element.y);
          }
          final maxX = x.reduce(max);
          final maxY = y.reduce(max);
          final minX = x.reduce(min);
          final minY = y.reduce(min);
          img.Image crop = img.copyCrop(imageJpeg!, x: minX, y: minY, width: (maxX - minX), height: (maxY - minY));
          // DetectEyeData().rightEyeJpeg = imglib.encodeJpg(crop).buffer.asUint8List();
          DetectEyeData().rightEyeImage = crop;
        }
      }
    } else {
      String text = 'Faces found: ${faces.length}\n\n';
      for (final face in faces) {
        text += 'face: ${face.boundingBox}\n\n';
      }
      _text = text;
      // TODO: set _customPaint to draw boundingRect on top of image
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      // setState(() {});
    }
  }
}
