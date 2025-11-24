import 'package:flutter/material.dart';
import 'package:aethel/views/asmr_player_screen.dart';

class AsmrCategoryTracksScreen extends StatelessWidget {
  final String categoryName;

  const AsmrCategoryTracksScreen({
    super.key,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD8DFE8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD8DFE8),
        title: Text(categoryName.toUpperCase()),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildTrackCard(context, 'Трек $categoryName 1'),
          const SizedBox(height: 12),
          _buildTrackCard(context, 'Трек $categoryName 2'),
          const SizedBox(height: 12),
          _buildTrackCard(context, 'Трек $categoryName 3'),
        ],
      ),
    );
  }

  Widget _buildTrackCard(BuildContext context, String title) {
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
        trailing:
        const Icon(Icons.play_arrow_rounded, color: Color(0xFF7C9FB0)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AsmrPlayerScreen(trackTitle: title),
            ),
          );
        },
      ),
    );
  }
}
