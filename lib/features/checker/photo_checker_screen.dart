
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../services/image_pipeline.dart';
import '../../services/compliance_service.dart';
import '../../shared/widgets/result_row.dart';

class PhotoCheckerScreen extends ConsumerStatefulWidget {
  const PhotoCheckerScreen({super.key});

  @override
  ConsumerState<PhotoCheckerScreen> createState() => _PhotoCheckerScreenState();
}

class _PhotoCheckerScreenState extends ConsumerState<PhotoCheckerScreen> {
  Uint8List? _originalBytes;
  Uint8List? _processedBytes;
  ComplianceReport? _report;
  bool _busy = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Pick from Gallery'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('Use Camera'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
        ]),
      ),
    );
    if (source == null) return;

    final XFile? file = await picker.pickImage(source: source, imageQuality: 100);
    if (file == null) return;

    final bytes = await file.readAsBytes();
    setState(() {
      _originalBytes = bytes;
      _processedBytes = null;
      _report = null;
    });

    await _process(bytes);
  }

  Future<void> _process(Uint8List input) async {
    setState(() => _busy = true);
    try {
      final pipeline = ImagePipeline();
      final result = await pipeline.processForDV(input);
      final report = ComplianceService.check(result.processed, result.metrics);

      setState(() {
        _processedBytes = result.processed;
        _report = report;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Processing failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _exportDV() async {
    if (_processedBytes == null) return;
    final path = await ImagePipeline.saveToDownloads(_processedBytes!, suggestName: 'dv_photo.jpg');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved to: $path')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Photo Checker',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _busy ? null : _pickImage,
                icon: const Icon(Icons.add_a_photo),
                label: const Text('Pick or Capture'),
              ),
              const SizedBox(width: 12),
              if (_processedBytes != null && _report?.overallPass == true)
                FilledButton.icon(
                  onPressed: _exportDV,
                  icon: const Icon(Icons.download),
                  label: const Text('Export DV-Ready'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_busy) const LinearProgressIndicator(),
          if (_originalBytes != null || _processedBytes != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text('Original'),
                      const SizedBox(height: 8),
                      if (_originalBytes != null)
                        Image.memory(_originalBytes!, height: 240, fit: BoxFit.contain),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      const Text('DV-Ready (600×600)'),
                      const SizedBox(height: 8),
                      if (_processedBytes != null)
                        Image.memory(_processedBytes!, height: 240, fit: BoxFit.contain),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          if (_report != null) _ReportCard(report: _report!),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final ComplianceReport report;
  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Compliance Results', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ResultRow('Dimensions 600×600', report.dimensionsOk, details: report.dimensionsDetail),
            ResultRow('File size ≤ 240 KB', report.sizeOk, details: report.sizeDetail),
            ResultRow('Color space sRGB (24-bit)', report.colorOk, details: report.colorDetail),
            ResultRow('Head size 50–69%', report.headPercentOk, details: report.headPercentDetail),
            ResultRow('Eye height within band', report.eyeBandOk, details: report.eyeBandDetail),
            ResultRow('Face detected', report.faceDetected, details: report.faceDetail),
            const Divider(),
            Row(
              children: [
                Icon(
                  report.overallPass ? Icons.verified : Icons.error_outline,
                  color: report.overallPass ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  report.overallPass ? 'PASS — DV-ready' : 'FAIL — see above',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
