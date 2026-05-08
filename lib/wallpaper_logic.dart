import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class WallpaperManager extends StatefulWidget {
  const WallpaperManager({super.key});

  @override
  State<WallpaperManager> createState() => _WallpaperManagerState();
}

class _WallpaperManagerState extends State<WallpaperManager> {
  final List<String> _layers = ['lock', 'home', 'tray', 'drawer'];
  final Map<String, String?> _paths = {};

  @override
  void initState() {
    super.initState();
    _loadPaths();
  }

  Future<void> _loadPaths() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var layer in _layers) {
        _paths['${layer}_land'] = prefs.getString('${layer}_land');
        _paths['${layer}_port'] = prefs.getString('${layer}_port');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _layers.length,
      itemBuilder: (context, index) {
        final layer = _layers[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: Column(
            children: [
              ListTile(title: Text('${layer.toUpperCase()} Wallpaper')),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPicker(layer, 'land'),
                  _buildPicker(layer, 'port'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPicker(String layer, String orientation) {
    final path = _paths['${layer}_$orientation'];
    return Column(
      children: [
        Text(orientation == 'land' ? 'Landscape' : 'Portrait'),
        GestureDetector(
          onTap: () {
            // In a real app, use image_picker. For this demo, we assume paths are set manually or via placeholder.
            _mockPickImage(layer, orientation);
          },
          child: Container(
            width: 100,
            height: 100,
            color: Colors.white10,
            child: path != null
                ? Image.file(File(path), fit: BoxFit.cover)
                : const Icon(Icons.add_a_photo),
          ),
        ),
      ],
    );
  }

  Future<void> _mockPickImage(String layer, String orientation) async {
    // Mocking image selection
    final prefs = await SharedPreferences.getInstance();
    final path = '/sdcard/Download/mock_${layer}_$orientation.jpg';
    await prefs.setString('${layer}_$orientation', path);
    _loadPaths();
  }
}

class WallpaperBackground extends StatelessWidget {
  final String layer;
  final double blur;

  const WallpaperBackground({super.key, required this.layer, this.blur = 0});

  @override
  Widget build(BuildContext context) {
    return NativeDeviceOrientationReader(
      builder: (context) {
        final orientation = NativeDeviceOrientationReader.orientation(context);
        final isLandscape = orientation == NativeDeviceOrientation.landscapeLeft ||
            orientation == NativeDeviceOrientation.landscapeRight;
        final key = '${layer}_${isLandscape ? 'land' : 'port'}';

        return FutureBuilder<String?>(
          future: SharedPreferences.getInstance().then((p) => p.getString(key)),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return Container(color: Colors.black);
            }
            return ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: Image.file(
                File(snapshot.data!),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            );
          },
        );
      },
    );
  }
}

Future<String> processAndCacheBlur(String inputPath, double blurSigma) async {
  return compute(_blurTask, {'path': inputPath, 'sigma': blurSigma});
}

Future<String> _blurTask(Map<String, dynamic> params) async {
  final String path = params['path'];
  final double sigma = params['sigma'];
  
  final bytes = await File(path).readAsBytes();
  final image = img.decodeImage(bytes);
  if (image == null) return path;

  final blurred = img.gaussianBlur(image, radius: sigma.toInt());
  
  final tempDir = await getTemporaryDirectory();
  final outPath = '${tempDir.path}/blurred_${DateTime.now().millisecondsSinceEpoch}.jpg';
  await File(outPath).writeAsBytes(img.encodeJpg(blurred));
  
  return outPath;
}
