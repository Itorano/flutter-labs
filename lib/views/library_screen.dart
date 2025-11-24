import 'package:flutter/material.dart';
import 'package:aethel/views/asmr_offline_player_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final List<Map<String, String>> _asmrTracks = [
    {'title': 'Трек 1', 'duration': '01:23:45'},
    {'title': 'Трек 2', 'duration': '00:45:30'},
    {'title': 'Трек 3', 'duration': '02:10:15'},
  ];

  final List<Map<String, String>> _favoriteTracks = [
    {'title': 'Избранный трек 1', 'duration': '00:55:20'},
    {'title': 'Избранный трек 2', 'duration': '01:15:40'},
  ];

  void _removeTrack(int tabIndex, int trackIndex) {
    setState(() {
      if (tabIndex == 0) {
        _asmrTracks.removeAt(trackIndex);
      } else {
        _favoriteTracks.removeAt(trackIndex);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Трек удален'),
        duration: Duration(seconds: 1),
      ),
    );
  }

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
            labelColor: Color(0xFF7C9FB0),
            indicatorColor: Color(0xFF7C9FB0),
            tabs: [
              Tab(text: 'АСМР'),
              Tab(text: 'Избранное'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTrackList(0, _asmrTracks),
            _buildTrackList(1, _favoriteTracks),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackList(int tabIndex, List<Map<String, String>> tracks) {
    if (tracks.isEmpty) {
      return const Center(
        child: Text(
          'Список пуст',
          style: TextStyle(
            color: Color(0xFF7C9FB0),
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: tracks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildTrackCard(
          tracks[index]['title']!,
          tracks[index]['duration']!,
          tabIndex,
          index,
        );
      },
    );
  }

  Widget _buildTrackCard(
      String title, String duration, int tabIndex, int trackIndex) {
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.play_arrow, color: Color(0xFF7C9FB0)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AsmrOfflinePlayerScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Color(0xFF7C9FB0)),
              onPressed: () => _removeTrack(tabIndex, trackIndex),
            ),
          ],
        ),
      ),
    );
  }
}
