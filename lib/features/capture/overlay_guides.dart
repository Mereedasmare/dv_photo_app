
import 'package:flutter/material.dart';

class OverlayGuides extends StatelessWidget {
  const OverlayGuides({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final w = c.maxWidth;
        final h = c.maxHeight;
        final square = w < h ? w : h;
        final left = (w - square) / 2;
        final top = (h - square) / 2;

        // DV head size ~50–69% height; eye line band ~ between 336–378px on final 600px => scaled here
        final eyeMinY = top + square * (336/600);
        final eyeMaxY = top + square * (378/600);

        return Stack(
          children: [
            // Outer dim
            Container(color: Colors.black26),
            // Clear center square
            Positioned(
              left: left,
              top: top,
              width: square,
              height: square,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.white70, width: 2),
                ),
              ),
            ),
            // Eye band lines
            Positioned(
              left: left,
              top: eyeMinY,
              width: square,
              child: Container(height: 1, color: Colors.greenAccent),
            ),
            Positioned(
              left: left,
              top: eyeMaxY,
              width: square,
              child: Container(height: 1, color: Colors.greenAccent),
            ),
            // Hints
            Positioned(
              left: left,
              top: top - 28,
              child: const Text('Keep eyes between green lines', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
