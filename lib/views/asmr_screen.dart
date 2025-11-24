import 'package:flutter/material.dart';

class AsmrScreen extends StatelessWidget {
  const AsmrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD8DFE8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD8DFE8),
        title: const Text('АСМР'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 65),
                backgroundColor: const Color(0xFFADBCD3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.grid_view_rounded, color: Color(0xFF7C9FB0), size: 25),
                  SizedBox(width: 10),
                  Text(
                    'Категории',
                    style: TextStyle(
                      color: Color(0xFF7C9FB0),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Поиск видео или автора...',
                prefixIcon: Icon(Icons.search_rounded),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildTrackCard('АСМР Трек 1'),
                  const SizedBox(height: 12),
                  _buildTrackCard('АСМР Трек 2'),
                  const SizedBox(height: 12),
                  _buildTrackCard('АСМР Трек 3'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackCard(String title) {
    return Card(
      color: const Color(0xFFADBCD3),
      child: ListTile(
        leading: const Icon(Icons.music_note_rounded, color: Color(0xFF7C9FB0)),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: const Text(
          '01:30:00',
          style: TextStyle(color: Color(0xFF7C9FB0)),
        ),
        trailing: const Icon(Icons.download_rounded, color: Color(0xFF7C9FB0)),
        onTap: null, // TODO: Навигация
      ),
    );
  }
}
