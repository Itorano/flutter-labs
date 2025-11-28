import 'dart:async';
import 'dart:ui';
import 'package:just_audio/just_audio.dart';

class SleepTimerService {
  Timer? _timer;
  bool _isActive = false;
  Duration? _remainingTime;
  Duration? _totalDuration;
  bool _endOfTrackMode = false;
  StreamSubscription? _positionSubscription;

  bool get isActive => _isActive;
  Duration? get remainingTime => _remainingTime;
  Duration? get totalDuration => _totalDuration;

  void startTimer({
    required Duration duration,
    required AudioPlayer player,
    required bool endOfTrackMode,
    required VoidCallback onComplete,
  }) {
    cancelTimer();

    _isActive = true;
    _endOfTrackMode = endOfTrackMode;
    _totalDuration = duration;
    _remainingTime = duration;

    if (endOfTrackMode) {
      // Режим "конец трека" - слушаем позицию трека
      _positionSubscription = player.positionStream.listen((position) {
        final trackDuration = player.duration ?? Duration.zero;
        final trackRemaining = trackDuration - position;

        // Если трек заканчивается раньше таймера
        if (trackRemaining.inSeconds <= 1) {
          _completeTimer(player, onComplete: onComplete);
        }
      });

      // Также запускаем обычный таймер как максимальное время
      _startCountdown(player, duration, onComplete);
    } else {
      // Обычный режим таймера
      _startCountdown(player, duration, onComplete);
    }
  }

  void _startCountdown(
      AudioPlayer player,
      Duration duration,
      VoidCallback onComplete,
      ) {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime != null && _remainingTime!.inSeconds > 0) {
        _remainingTime = Duration(seconds: _remainingTime!.inSeconds - 1);
      } else {
        _completeTimer(player, onComplete: onComplete);
      }
    });
  }

  Future<void> _completeTimer(
      AudioPlayer player, {
        required VoidCallback onComplete,
      }) async {
    if (!_isActive) return; // Предотвращаем двойное срабатывание

    _timer?.cancel();
    _positionSubscription?.cancel();

    // Плавное затухание звука (2 секунды)
    final currentVolume = player.volume;
    const fadeSteps = 20;
    const fadeDuration = Duration(milliseconds: 100);

    for (int i = fadeSteps; i >= 0; i--) {
      if (!_isActive) break; // Если таймер был отменён во время затухания
      await player.setVolume(currentVolume * (i / fadeSteps));
      await Future.delayed(fadeDuration);
    }

    // Пауза
    await player.pause();
    await player.setVolume(currentVolume);

    _isActive = false;
    _remainingTime = null;
    _totalDuration = null;
    _endOfTrackMode = false;

    onComplete();
  }

  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _isActive = false;
    _remainingTime = null;
    _totalDuration = null;
    _endOfTrackMode = false;
  }

  void dispose() {
    cancelTimer();
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
}
