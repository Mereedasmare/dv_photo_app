
import 'dart:math';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'face_service.dart';

class Metrics {
  final int width;
  final int height;
  final int fileBytes;
  final double headPercent; // 0..100
  final int eyeY; // pixels from top after resize
  final bool faceDetected;

  Metrics({
    required this.width,
    required this.height,
    required this.fileBytes,
    required this.headPercent,
    required this.eyeY,
    required this.faceDetected,
  });

  static Metrics fromImageAndLandmarks(img.Image resized600, DetectedLandmarks? lm) {
    final width = resized600.width;
    final height = resized600.height;
    // File bytes unknown here; set 0 (will fill in ComplianceService with actual)
    // Compute head percent using bbox height vs image height
    double headPercent = 0;
    int eyeY = 0;
    if (lm != null) {
      headPercent = (lm.boundingBox.height / height) * 100.0;
      // Eye Y ~ average of eyes; fallback to bbox center
      double y;
      if (lm.leftEye != null && lm.rightEye != null) {
        y = (lm.leftEye!.y + lm.rightEye!.y) / 2.0;
      } else {
        y = lm.boundingBox.centerDy;
      }
      eyeY = y.round().clamp(0, height);
    }
    return Metrics(
      width: width,
      height: height,
      fileBytes: 0,
      headPercent: headPercent,
      eyeY: eyeY,
      faceDetected: lm != null,
    );
  }
}
