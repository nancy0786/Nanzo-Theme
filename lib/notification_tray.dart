import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nanzo_theme/wallpaper_logic.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationTray extends StatefulWidget {
  const NotificationTray({super.key});

  @override
  State<NotificationTray> createState() => _NotificationTrayState();
}

class _NotificationTrayState extends State<NotificationTray> {
  double _blurValue = 10.0;

  @override
  void initState() {
    super.initState();
    _loadBlur();
  }

  Future<void> _loadBlur() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _blurValue = prefs.getDouble('tray_blur') ?? 10.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          WallpaperBackground(layer: 'tray', blur: _blurValue),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Notifications', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const CircleAvatar(backgroundColor: Color(0xFF00E5FF)),
                        title: Text('Notification $index'),
                        subtitle: const Text('This is a sample notification message.'),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('Blur Intensity'),
                      Slider(
                        value: _blurValue,
                        min: 0,
                        max: 50,
                        onChanged: (val) async {
                          setState(() => _blurValue = val);
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setDouble('tray_blur', val);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
