import 'package:flutter/material.dart';

class AsmrOfflinePlayerScreen extends StatelessWidget {
  const AsmrOfflinePlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD8DFE8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD8DFE8),
        title: const Text('Трек 1'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Обложка трека
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: const Color(0xFFADBCD3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.music_note_rounded,
                size: 100,
                color: Color(0xFF7C9FB0),
              ),
            ),
            const SizedBox(height: 40),

            // Название трека
            const Text(
              'Название трека',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Автор
            const Text(
              'Автор',
              style: TextStyle(
                color: Color(0xFF7C9FB0),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 40),

            // Прогресс бар (пустышка)
            Column(
              children: [
                LinearProgressIndicator(
                  value: 0.3,
                  backgroundColor: const Color(0xFFADBCD3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7C9FB0)),
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('1:23', style: TextStyle(color: Color(0xFF7C9FB0))),
                    Text('4:56', style: TextStyle(color: Color(0xFF7C9FB0))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Кнопки управления
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.skip_previous, size: 40),
                  color: const Color(0xFF7C9FB0),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.play_arrow, size: 64),
                  color: const Color(0xFF7C9FB0),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.skip_next, size: 40),
                  color: const Color(0xFF7C9FB0),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Дополнительные кнопки
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.favorite_border),
                  color: const Color(0xFF7C9FB0),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.repeat),
                  color: const Color(0xFF7C9FB0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
