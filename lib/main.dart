import 'package:aethel/views/asmr_categories_screen.dart';
import 'package:aethel/views/asmr_category_tracks_screen.dart';
import 'package:aethel/views/asmr_screen.dart';
import 'package:aethel/views/asmr_sleep_timer_screen.dart';
import 'package:aethel/views/library_screen.dart';
import 'package:aethel/views/asmr_offline_player_screen.dart';
import 'package:aethel/views/asmr_player_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD8DFE8),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.spa,
                size: 80,
                color: Color(0xFF7C9FB0),
              ),
              const SizedBox(height: 24),
              const Text(
                'AETHEL',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFF7C9FB0),
                  letterSpacing: 8,
                ),
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AsmrScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 70),
                  backgroundColor: const Color(0xFFADBCD3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.headphones, size: 28, color: Color(0xFF7C9FB0)),
                    SizedBox(width: 16),
                    Text(
                      'АСМР',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF7C9FB0),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LibraryScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 70),
                  backgroundColor: const Color(0xFFADBCD3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.library_music_rounded,
                        size: 28, color: Color(0xFF7C9FB0)),
                    SizedBox(width: 16),
                    Text(
                      'Библиотека',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF7C9FB0),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
