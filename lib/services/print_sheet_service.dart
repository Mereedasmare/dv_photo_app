
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

enum PaperSize { letter, a4 }

class PrintSheetService {
  // 2x2 inch tiles at 300 DPI -> 600x600 px; PDFs use points (1/72 inch)
  // We'll place images sized to 2x2 inches, with small margins and grid.
  static Future<Uint8List> generate(Uint8List dvJpeg, {PaperSize paper = PaperSize.letter}) async {
    final doc = pw.Document();

    final pageFormat = paper == PaperSize.letter ? PdfPageFormat.letter : PdfPageFormat.a4;

    final image = pw.MemoryImage(dvJpeg);

    // 2x2 inches in PDF points:
    final tileSize = 2 * PdfPageFormat.inch;

    // Compute grid: try to fit as many as possible with 0.25" gaps
    final gap = 0.25 * PdfPageFormat.inch;

    doc.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (context) {
          final cols = ((pageFormat.width - gap) / (tileSize + gap)).floor();
          final rows = ((pageFormat.height - gap) / (tileSize + gap)).floor();

          return pw.Column(
            children: List.generate(rows, (r) {
              return pw.Padding(
                padding: pw.EdgeInsets.only(bottom: r == rows - 1 ? 0 : gap),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: List.generate(cols, (c) {
                    return pw.Padding(
                      padding: pw.EdgeInsets.only(right: c == cols - 1 ? 0 : gap),
                      child: pw.Container(
                        width: tileSize,
                        height: tileSize,
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                        ),
                        child: pw.Center(child: pw.Image(image, width: tileSize, height: tileSize, fit: pw.BoxFit.cover)),
                      ),
                    );
                  }),
                ),
              );
            }),
          );
        },
      ),
    );

    return Uint8List.fromList(await doc.save());
  }
}
