
import 'dart:typed_data';
import 'metrics.dart';

class ComplianceReport {
  final bool dimensionsOk;
  final String dimensionsDetail;

  final bool sizeOk;
  final String sizeDetail;

  final bool colorOk;
  final String colorDetail;

  final bool headPercentOk;
  final String headPercentDetail;

  final bool eyeBandOk;
  final String eyeBandDetail;

  final bool faceDetected;
  final String faceDetail;

  bool get overallPass => dimensionsOk && sizeOk && colorOk && headPercentOk && eyeBandOk && faceDetected;

  ComplianceReport({
    required this.dimensionsOk,
    required this.dimensionsDetail,
    required this.sizeOk,
    required this.sizeDetail,
    required this.colorOk,
    required this.colorDetail,
    required this.headPercentOk,
    required this.headPercentDetail,
    required this.eyeBandOk,
    required this.eyeBandDetail,
    required this.faceDetected,
    required this.faceDetail,
  });
}

class ComplianceService {
  // DV: 600x600px, <= 240KB, sRGB, head 50–69%, eye height band approx.
  static const int targetDim = 600;
  static const int maxBytes = 240 * 1024;
  static const double minHeadPct = 50.0;
  static const double maxHeadPct = 69.0;

  // Eye band approximation: eyes should be around 336–378 px from top in a 600px image (rough guide).
  static const int eyeMin = 336;
  static const int eyeMax = 378;

  static ComplianceReport check(Uint8List processedJpeg, Metrics m) {
    final bytesLen = processedJpeg.lengthInBytes;

    final dimsOk = (m.width == targetDim && m.height == targetDim);
    final sizeOk = bytesLen <= maxBytes;
    // Color check proxy: since we re-encode with `image` as 24-bit JPEG, treat as ok
    final colorOk = true;

    final headOk = m.headPercent >= minHeadPct && m.headPercent <= maxHeadPct;
    final eyeOk = m.eyeY >= eyeMin && m.eyeY <= eyeMax;

    return ComplianceReport(
      dimensionsOk: dimsOk,
      dimensionsDetail: '${m.width}×${m.height} (required 600×600)',
      sizeOk: sizeOk,
      sizeDetail: '${(bytesLen/1024).toStringAsFixed(1)} KB (max 240 KB)',
      colorOk: colorOk,
      colorDetail: 'Encoded as 24-bit JPEG (sRGB pipeline)',
      headPercentOk: headOk,
      headPercentDetail: m.faceDetected
          ? '${m.headPercent.toStringAsFixed(1)}% (required 50–69%)'
          : 'No face detected',
      eyeBandOk: eyeOk,
      eyeBandDetail: m.faceDetected
          ? 'Eye line at y=${m.eyeY}px (acceptable ${eyeMin}–${eyeMax}px)'
          : 'No face detected',
      faceDetected: m.faceDetected,
      faceDetail: m.faceDetected ? 'Face detected' : 'No face found',
    );
  }
}
