import 'package:flutter/material.dart';
import 'package:nanzo_theme/wallpaper_logic.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _blurAnimation;
  double _maxBlur = 20.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _blurAnimation = Tween<double>(begin: 0, end: _maxBlur).animate(_controller);
    _controller.forward();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _maxBlur = prefs.getDouble('drawer_max_blur') ?? 20.0;
      _blurAnimation = Tween<double>(begin: 0, end: _maxBlur).animate(_controller);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _blurAnimation,
      builder: (context, child) {
        return Scaffold(
          body: Stack(
            children: [
              WallpaperBackground(layer: 'drawer', blur: _blurAnimation.value),
              child!,
            ],
          ),
        );
      },
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search Apps...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                  filled: true,
                  fillColor: Colors.black54,
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                ),
                itemCount: 20,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: const Color(0xFF00E5FF)),
                        ),
                        child: const Icon(Icons.android, size: 40, color: Color(0xFF00E5FF)),
                      ),
                      const SizedBox(height: 8),
                      Text('App $index', overflow: TextOverflow.ellipsis),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
