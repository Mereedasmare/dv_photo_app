
import 'dart:typed_data';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class DetectedLandmarks {
  final RectLike boundingBox;
  final PointLike? leftEye;
  final PointLike? rightEye;
  final PointLike? noseBase;
  final PointLike? mouthCenter;

  DetectedLandmarks({
    required this.boundingBox,
    this.leftEye,
    this.rightEye,
    this.noseBase,
    this.mouthCenter,
  });
}

class RectLike {
  final double left, top, right, bottom;
  RectLike(this.left, this.top, this.right, this.bottom);

  double get width => right - left;
  double get height => bottom - top;
  double get centerDx => left + width / 2;
  double get centerDy => top + height / 2;
}

class PointLike {
  final double x, y;
  PointLike(this.x, this.y);
}

class FaceService {
  final FaceDetector _detector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: false,
      enableLandmarks: true,
      enableContours: false,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  Future<DetectedLandmarks?> detect(Uint8List bytes) async {
    final input = InputImage.fromFilePath(await _bytesToTempFile(bytes));
    final faces = await _detector.processImage(input);
    if (faces.isEmpty) return null;
    // Take the largest face
    faces.sort((a, b) => (b.boundingBox.width * b.boundingBox.height)
        .compareTo(a.boundingBox.width * a.boundingBox.height));
    final f = faces.first;

    PointLike? safeLandmark(FaceLandmarkType t) {
      final lm = f.landmarks[t];
      if (lm == null) return null;
      return PointLike(lm.position.x.toDouble(), lm.position.y.toDouble());
    }

    return DetectedLandmarks(
      boundingBox: RectLike(
        f.boundingBox.left.toDouble(),
        f.boundingBox.top.toDouble(),
        f.boundingBox.right.toDouble(),
        f.boundingBox.bottom.toDouble(),
      ),
      leftEye: safeLandmark(FaceLandmarkType.leftEye),
      rightEye: safeLandmark(FaceLandmarkType.rightEye),
      noseBase: safeLandmark(FaceLandmarkType.noseBase),
      mouthCenter: safeLandmark(FaceLandmarkType.bottomMouth),
    );
  }

  Future<String> _bytesToTempFile(Uint8List bytes) async {
    // Write to a temp file because MLKit prefers file paths
    // Use dart:io with system temp
    final dir = await getSystemTempDirectory();
    final file = await File('${dir.path}/mlkit_in.jpg').create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
}

// Minimal polyfills (since we can't import path_provider here)
import 'dart:io';
Future<Directory> getSystemTempDirectory() async {
  return Directory.systemTemp.createTemp('dv_tmp_');
}
