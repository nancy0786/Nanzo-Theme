import 'package:flutter/material.dart';
import 'package:nanzo_theme/wallpaper_logic.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecuritySettings extends StatefulWidget {
  const SecuritySettings({super.key});

  @override
  State<SecuritySettings> createState() => _SecuritySettingsState();
}

class _SecuritySettingsState extends State<SecuritySettings> {
  bool _lockEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lockEnabled = prefs.getBool('lock_enabled') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Enable Picture Password'),
          value: _lockEnabled,
          onChanged: (val) async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('lock_enabled', val);
            setState(() => _lockEnabled = val);
          },
        ),
        if (_lockEnabled)
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SetupLockScreen()),
              );
            },
            child: const Text('Setup Coordinates'),
          ),
      ],
    );
  }
}

class SetupLockScreen extends StatefulWidget {
  const SetupLockScreen({super.key});

  @override
  State<SetupLockScreen> createState() => _SetupLockScreenState();
}

class _SetupLockScreenState extends State<SetupLockScreen> {
  final List<Offset> _points = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTapDown: (details) {
          setState(() {
            if (_points.length < 5) {
              _points.add(details.localPosition);
            }
          });
        },
        child: Stack(
          children: [
            const WallpaperBackground(layer: 'lock'),
            for (var point in _points)
              Positioned(
                left: point.dx - 25,
                top: point.dy - 25,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.cyan, width: 2),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Tap 5 spots: ${_points.length}/5',
                  style: const TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _points.length == 5
          ? FloatingActionButton(
              onPressed: _savePoints,
              child: const Icon(Icons.check),
            )
          : null,
    );
  }

  Future<void> _savePoints() async {
    final prefs = await SharedPreferences.getInstance();
    final pointStrings = _points.map((p) => '${p.dx},${p.dy}').toList();
    await prefs.setStringList('lock_points', pointStrings);
    if (mounted) Navigator.pop(context);
  }
}

class LockScreenOverlay extends StatefulWidget {
  const LockScreenOverlay({super.key});

  @override
  State<LockScreenOverlay> createState() => _LockScreenOverlayState();
}

class _LockScreenOverlayState extends State<LockScreenOverlay> {
  List<Offset> _targets = [];
  final List<Offset> _attempts = [];
  DateTime? _longPressStart;

  @override
  void initState() {
    super.initState();
    _loadTargets();
  }

  Future<void> _loadTargets() async {
    final prefs = await SharedPreferences.getInstance();
    final pointStrings = prefs.getStringList('lock_points') ?? [];
    setState(() {
      _targets = pointStrings.map((s) {
        final parts = s.split(',');
        return Offset(double.parse(parts[0]), double.parse(parts[1]));
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTapDown: (details) {
          _checkTap(details.localPosition);
        },
        onLongPressStart: (details) {
          _longPressStart = DateTime.now();
        },
        onLongPressEnd: (details) {
          if (_longPressStart != null) {
            final duration = DateTime.now().difference(_longPressStart!);
            // Check if long press in bottom right (approx)
            final size = MediaQuery.of(context).size;
            if (duration.inSeconds >= 5 &&
                details.localPosition.dx > size.width - 100 &&
                details.localPosition.dy > size.height - 100) {
              _unlock();
            }
          }
        },
        child: Stack(
          children: [
            const WallpaperBackground(layer: 'lock'),
            // Lock UI elements
          ],
        ),
      ),
    );
  }

  void _checkTap(Offset tap) {
    if (_attempts.length >= _targets.length) return;
    
    final target = _targets[_attempts.length];
    final distance = (tap - target).distance;
    
    if (distance <= 50) {
      _attempts.add(tap);
      if (_attempts.length == _targets.length) {
        _unlock();
      }
    } else {
      setState(() => _attempts.clear());
    }
  }

  void _unlock() {
    // Navigate away or close overlay
    Navigator.of(context).pop();
  }
}
