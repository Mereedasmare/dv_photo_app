
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../services/print_sheet_service.dart';
import '../../services/image_pipeline.dart';
import 'package:printing/printing.dart';

class PrintSheetScreen extends ConsumerStatefulWidget {
  const PrintSheetScreen({super.key});

  @override
  ConsumerState<PrintSheetScreen> createState() => _PrintSheetScreenState();
}

class _PrintSheetScreenState extends ConsumerState<PrintSheetScreen> {
  Uint8List? _lastDV;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Print Sheet',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Generate a PDF with multiple 2×2" tiles per page.'),
          const SizedBox(height: 12),
          Row(
            children: [
              FilledButton(
                onPressed: () async {
                  final bytes = await Printing.pickImage();
                  if (bytes == null) return;
                  // Ensure it's DV 600×600; if not, process
                  final pipeline = ImagePipeline();
                  final processed = await pipeline.processForDV(bytes);
                  setState(() => _lastDV = processed.processed);
                },
                child: const Text('Pick an Image'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_lastDV != null)
            Wrap(
              spacing: 12,
              children: [
                FilledButton.tonal(
                  onPressed: () async {
                    final pdf = await PrintSheetService.generate(_lastDV!, paper: PaperSize.letter);
                    await Printing.layoutPdf(onLayout: (_) async => pdf);
                  },
                  child: const Text('Print on Letter'),
                ),
                FilledButton.tonal(
                  onPressed: () async {
                    final pdf = await PrintSheetService.generate(_lastDV!, paper: PaperSize.a4);
                    await Printing.layoutPdf(onLayout: (_) async => pdf);
                  },
                  child: const Text('Print on A4'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
