import 'dart:io';
import 'package:flutter/material.dart';

class WallpaperEditor extends StatefulWidget {
  final String imagePath;
  const WallpaperEditor({super.key, required this.imagePath});

  @override
  State<WallpaperEditor> createState() => _WallpaperEditorState();
}

class _WallpaperEditorState extends State<WallpaperEditor> {
  Offset _offset = Offset.zero;
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Wallpaper'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              // Save the cropped/positioned version
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: GestureDetector(
        onScaleUpdate: (details) {
          setState(() {
            _scale = details.scale;
            _offset += details.focalPointDelta;
          });
        },
        child: ClipRect(
          child: CustomPaint(
            painter: WallpaperPainter(
              imagePath: widget.imagePath,
              offset: _offset,
              scale: _scale,
            ),
            child: Container(),
          ),
        ),
      ),
    );
  }
}

class WallpaperPainter extends CustomPainter {
  final String imagePath;
  final Offset offset;
  final double scale;

  WallpaperPainter({required this.imagePath, required this.offset, required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    // In a real implementation, we would load the image and draw it with transformation.
    final paint = Paint()..color = Colors.grey;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Wallpaper Preview\nScale: ${scale.toStringAsFixed(2)}\nOffset: $offset',
        style: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(20, 20));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
