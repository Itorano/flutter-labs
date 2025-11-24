import 'package:flutter/material.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFD8DFE8),
        appBar: AppBar(
          backgroundColor: const Color(0xFFD8DFE8),
          title: const Text('БИБЛИОТЕКА'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'АСМР'),
              Tab(text: 'Избранное'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTrackList(),
            _buildTrackList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackList() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildTrackCard('Трек 1', '01:23:45'),
        const SizedBox(height: 12),
        _buildTrackCard('Трек 2', '00:45:30'),
        const SizedBox(height: 12),
        _buildTrackCard('Трек 3', '02:10:15'),
      ],
    );
  }

  Widget _buildTrackCard(String title, String duration) {
    return Card(
      color: const Color(0xFFADBCD3),
      child: ListTile(
        leading: const Icon(Icons.music_note, color: Color(0xFF7C9FB0)),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          duration,
          style: const TextStyle(color: Color(0xFF7C9FB0)),
        ),
        trailing: const Icon(Icons.play_arrow, color: Color(0xFF7C9FB0)),
        onTap: null,
      ),
    );
  }
}
