import 'package:flutter/material.dart';
import 'package:aethel/views/asmr_category_tracks_screen.dart';

class AsmrCategoriesScreen extends StatelessWidget {
  const AsmrCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD8DFE8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD8DFE8),
        title: const Text('КАТЕГОРИИ'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          children: [
            _buildCategoryCard(context, 'Категория 1', Icons.water_drop),
            _buildCategoryCard(context, 'Категория 2', Icons.ac_unit),
            _buildCategoryCard(context, 'Категория 3', Icons.nightlight_round),
            _buildCategoryCard(context, 'Категория 4', Icons.spa),
            _buildCategoryCard(context, 'Категория 5', Icons.self_improvement),
            _buildCategoryCard(context, 'Категория 6', Icons.music_note),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context, String name, IconData icon) {
    return Card(
      color: const Color(0xFFADBCD3),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AsmrCategoryTracksScreen(categoryName: name),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF7C9FB0), size: 28),
            const SizedBox(height: 5),
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
