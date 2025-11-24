import 'package:flutter/material.dart';

class AsmrSleepTimerScreen extends StatefulWidget {
  const AsmrSleepTimerScreen({super.key});

  @override
  State<AsmrSleepTimerScreen> createState() => _AsmrSleepTimerScreenState();
}

class _AsmrSleepTimerScreenState extends State<AsmrSleepTimerScreen> {
  bool _endOfTrackMode = false; // Переменная состояния вне build()

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD8DFE8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD8DFE8),
        title: const Text('Таймер сна'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Переключатель "Конец трека"
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFADBCD3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF7C9FB0).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Завершение при достижении конца трека',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Switch(
                    value: _endOfTrackMode,
                    onChanged: (value) {
                      setState(() {
                        _endOfTrackMode = value;
                      });
                    },
                    activeColor: const Color(0xFF7C9FB0),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Круглый таймер
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFADBCD3),
                border: Border.all(
                  color: const Color(0xFF7C9FB0),
                  width: 4,
                ),
              ),
              child: const Center(
                child: Text(
                  '00:30:00',
                  style: TextStyle(
                    color: Color(0xFF7C9FB0),
                    fontSize: 40,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Кнопка запуска
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                backgroundColor: const Color(0xFFADBCD3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(
                    color: Color(0xFF7C9FB0),
                    width: 1.5,
                  ),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_arrow_rounded,
                    color: Color(0xFF7C9FB0),
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Запустить',
                    style: TextStyle(
                      color: Color(0xFF7C9FB0),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
