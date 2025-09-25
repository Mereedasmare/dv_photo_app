
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'face_service.dart';
import 'metrics.dart';

class ProcessResult {
  final Uint8List processed;
  final Metrics metrics;
  ProcessResult(this.processed, this.metrics);
}

class ImagePipeline {
  /// Main entry: returns DV-ready JPEG (600x600, <=240KB, sRGB)
  Future<ProcessResult> processForDV(Uint8List bytes) async {
    // Decode original
    img.Image? original = img.decodeImage(bytes);
    if (original == null) {
      throw 'Unsupported or corrupted image';
    }

    // Ensure sRGB by re-encoding via image package anyway
    // Detect face + landmarks
    final detector = FaceService();
    final landmarks = await detector.detect(bytes);

    // Compute crop square around face with head % target ~60%
    final cropped = _cropToDV(original, landmarks);

    // Resize to 600x600
    final resized = img.copyResize(cropped, width: 600, height: 600, interpolation: img.Interpolation.cubic);

    // Encode adaptive JPEG to <=240KB
    final jpeg = await _encodeAdaptiveJpeg(resized, maxBytes: 240 * 1024);

    // Compute metrics for compliance
    final metrics = Metrics.fromImageAndLandmarks(resized, landmarks);

    return ProcessResult(Uint8List.fromList(jpeg), metrics);
  }

  img.Image _cropToDV(img.Image original, DetectedLandmarks? lm) {
    // If no face, center-crop square
    if (lm == null) {
      final size = min(original.width, original.height);
      final x = (original.width - size) ~/ 2;
      final y = (original.height - size) ~/ 2;
      return img.copyCrop(original, x: x, y: y, width: size, height: size);
    }

    // Use face bounding box as base
    final rect = lm.boundingBox;
    // Estimate head height as bbox height; target head% ~ 60% of final
    // We'll expand to a square that keeps the face centered with some headroom.
    final faceCenterX = rect.centerDx;
    final faceCenterY = rect.centerDy;

    // Desired square size: make face height ~60% of final crop.
    // We don't know final yet, so we choose square side such that bbox height is ~60% of side.
    final desiredSide = (rect.height / 0.60).clamp(100.0, max(original.width, original.height).toDouble());
    final side = min(desiredSide, min(original.width, original.height).toDouble());

    double x = faceCenterX - side / 2;
    double y = faceCenterY - side / 2;

    // Clamp to image bounds
    x = x.clamp(0, (original.width - side).toDouble());
    y = y.clamp(0, (original.height - side).toDouble());

    return img.copyCrop(original, x: x.round(), y: y.round(), width: side.round(), height: side.round());
  }

  Future<List<int>> _encodeAdaptiveJpeg(img.Image image, {required int maxBytes}) async {
    int quality = 95;
    List<int> out = img.encodeJpg(image, quality: quality);
    while (out.length > maxBytes && quality > 40) {
      quality -= 5;
      out = img.encodeJpg(image, quality: quality);
    }
    return out;
  }

  static Future<String> saveToDownloads(Uint8List bytes, {String suggestName = 'dv_photo.jpg'}) async {
    final dir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
    final path = '${dir.path}/$suggestName';
    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);
    return path;
  }
}
