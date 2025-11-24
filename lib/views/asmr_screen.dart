import 'package:flutter/material.dart';
import 'package:aethel/views/asmr_categories_screen.dart';
import 'package:aethel/views/asmr_player_screen.dart';

class AsmrScreen extends StatefulWidget {
  const AsmrScreen({super.key});

  @override
  State<AsmrScreen> createState() => _AsmrScreenState();
}

class _AsmrScreenState extends State<AsmrScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _tracks = [
    'АСМР Трек 1',
    'АСМР Трек 2',
    'АСМР Трек 3',
  ];
  List<String> _filteredTracks = [];

  @override
  void initState() {
    super.initState();
    _filteredTracks = List.from(_tracks);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterTracks(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredTracks = List.from(_tracks);
      } else {
        _filteredTracks = _tracks
            .where((track) => track.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AsmrCategoriesScreen(),
                  ),
                );
              },
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
                  Icon(Icons.grid_view_rounded,
                      color: Color(0xFF7C9FB0), size: 25),
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
            TextField(
              controller: _searchController,
              onChanged: _filterTracks,
              decoration: InputDecoration(
                hintText: 'Поиск видео или автора...',
                prefixIcon:
                const Icon(Icons.search_rounded, color: Color(0xFF7C9FB0)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _filteredTracks.isEmpty
                  ? const Center(
                child: Text(
                  'Треки не найдены',
                  style: TextStyle(
                    color: Color(0xFF7C9FB0),
                    fontSize: 16,
                  ),
                ),
              )
                  : ListView.separated(
                itemCount: _filteredTracks.length,
                separatorBuilder: (context, index) =>
                const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildTrackCard(_filteredTracks[index]);
                },
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
