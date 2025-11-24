import 'package:flutter/material.dart';
import 'package:aethel/views/asmr_sleep_timer_screen.dart';

class AsmrPlayerScreen extends StatefulWidget {
  final String trackTitle;

  const AsmrPlayerScreen({
    super.key,
    required this.trackTitle,
  });

  @override
  State<AsmrPlayerScreen> createState() => _AsmrPlayerScreenState();
}

class _AsmrPlayerScreenState extends State<AsmrPlayerScreen> {
  bool _isPlaying = false;
  bool _isFavorite = false;
  double _currentPosition = 0.0;
  final double _maxDuration = 100.0;

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite
            ? 'Добавлено в избранное'
            : 'Удалено из избранного'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD8DFE8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD8DFE8),
        title: const Text('Воспроизведение'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            // Видео плеер (заглушка)
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xFFADBCD3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _isPlaying
                    ? Icons.pause_circle_outline_rounded
                    : Icons.play_circle_outline_rounded,
                size: 80,
                color: const Color(0xFF7C9FB0),
              ),
            ),
            const SizedBox(height: 30),
            // Название трека
            Text(
              widget.trackTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            const Text(
              'Автор трека',
              style: TextStyle(
                color: Color(0xFF7C9FB0),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 30),
            // Прогресс бар
            Slider(
              value: _currentPosition,
              max: _maxDuration,
              activeColor: const Color(0xFF7C9FB0),
              inactiveColor: const Color(0xFFADBCD3),
              onChanged: (value) {
                setState(() {
                  _currentPosition = value;
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(_currentPosition),
                    style: const TextStyle(color: Color(0xFF7C9FB0)),
                  ),
                  Text(
                    _formatDuration(_maxDuration),
                    style: const TextStyle(color: Color(0xFF7C9FB0)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Кнопки управления
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: _toggleFavorite,
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: const Color(0xFF7C9FB0),
                    size: 32,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.skip_previous_rounded,
                    color: Color(0xFF7C9FB0),
                    size: 40,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFADBCD3),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: IconButton(
                    onPressed: _togglePlayPause,
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: const Color(0xFF7C9FB0),
                      size: 40,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.skip_next_rounded,
                    color: Color(0xFF7C9FB0),
                    size: 40,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AsmrSleepTimerScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.timer_outlined,
                    color: Color(0xFF7C9FB0),
                    size: 32,
                  ),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  String _formatDuration(double seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = (seconds % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
