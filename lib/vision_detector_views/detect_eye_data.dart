import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

enum DetectMode {
  None,
  Calib,
  Detect
}

class DetectEyeData {
  DetectEyeData._internal();
  static final DetectEyeData instance = DetectEyeData._internal();
  factory DetectEyeData() => instance;

  img.Image? leftEyeImage;
  img.Image? rightEyeImage;
  DetectMode mode = DetectMode.None;
}