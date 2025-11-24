import 'package:flutter/material.dart';

class AsmrCategoryTracksScreen extends StatelessWidget {
  const AsmrCategoryTracksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD8DFE8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD8DFE8),
        title: const Text('КАТЕГОРИЯ 1'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildTrackCard('Трек категории 1'),
          const SizedBox(height: 12),
          _buildTrackCard('Трек категории 2'),
        ],
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
          '00:45:30',
          style: TextStyle(color: Color(0xFF7C9FB0)),
        ),
        trailing: const Icon(Icons.download_rounded, color: Color(0xFF7C9FB0)),
        onTap: null,
      ),
    );
  }
}
