
import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../services/image_pipeline.dart';
import '../../services/compliance_service.dart';
import '../../services/face_service.dart';
import 'overlay_guides.dart';

class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  Timer? _probeTimer;
  bool _busy = false;
  String _hint = 'Align your face within the guides, neutral expression, no glasses.';
  Uint8List? _lastGood;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    final front = _cameras!.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras!.first,
    );
    _controller = CameraController(front, ResolutionPreset.medium, enableAudio: false);
    await _controller!.initialize();
    if (!mounted) return;
    setState(() {});
    _startProbing();
  }

  void _startProbing() {
    _probeTimer?.cancel();
    _probeTimer = Timer.periodic(const Duration(seconds: 2), (_) => _tryAutoCapture());
  }

  Future<void> _tryAutoCapture() async {
    if (!mounted || _busy || _controller == null || !_controller!.value.isInitialized) return;
    setState(() => _busy = true);
    try {
      final file = await _controller!.takePicture();
      final bytes = await file.readAsBytes();
      // Process and check
      final pipeline = ImagePipeline();
      final result = await pipeline.processForDV(bytes);
      final report = ComplianceService.check(result.processed, result.metrics);
      if (report.overallPass) {
        _lastGood = result.processed;
        setState(() {
          _hint = 'Looks good! You can save/export from Checker.';
        });
        if (mounted) {
          // Show a small toast-like bar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Auto-captured a DV-ready photo! Open Checker to export.')),
          );
        }
      } else {
        setState(() {
          _hint = 'Adjust: ${_firstFail(report)}';
        });
      }
    } catch (e) {
      setState(() {
        _hint = 'Could not capture: $e';
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _firstFail(ComplianceReport r) {
    if (!r.faceDetected) return 'Face not detected';
    if (!r.headPercentOk) return r.headPercentDetail;
    if (!r.eyeBandOk) return r.eyeBandDetail;
    if (!r.dimensionsOk) return r.dimensionsDetail;
    if (!r.sizeOk) return r.sizeDetail;
    if (!r.colorOk) return r.colorDetail;
    return 'Adjust framing/lighting';
    }

  @override
  void dispose() {
    _probeTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Live Capture',
      body: _controller == null || !_controller!.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                CameraPreview(_controller!),
                const OverlayGuides(),
                Positioned(
                  left: 0, right: 0, bottom: 16,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _hint,
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FilledButton(
                            onPressed: _busy ? null : _tryAutoCapture,
                            child: const Text('Try Auto-Capture Now'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
