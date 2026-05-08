import 'package:flutter/material.dart';
import 'package:nanzo_theme/wallpaper_logic.dart';
import 'package:nanzo_theme/security_overlay.dart';
import 'package:nanzo_theme/notification_tray.dart';
import 'package:nanzo_theme/app_drawer.dart';

void main() {
  runApp(const NanzoApp());
}

class NanzoApp extends StatelessWidget {
  const NanzoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nanzo Theme',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5FF),
          secondary: Color(0xFF00E5FF),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/notification_tray') {
          return MaterialPageRoute(builder: (_) => const NotificationTray());
        }
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const WallpaperManager(),
    const SecuritySettings(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const WallpaperBackground(layer: 'home'),
          IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.apps, size: 40, color: Color(0xFF00E5FF)),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AppDrawer()),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: Colors.black.withOpacity(0.8),
        selectedItemColor: const Color(0xFF00E5FF),
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.image), label: 'Wallpaper'),
          BottomNavigationBarItem(icon: Icon(Icons.security), label: 'Security'),
        ],
      ),
    );
  }
}
