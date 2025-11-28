import 'dart:async';
import 'package:flutter/material.dart';

class SleepTimerViewModel extends ChangeNotifier {
  int selectedHours;
  int selectedMinutes;
  int selectedSeconds;
  bool endOfTrackMode;
  bool isRunning;
  Duration? remainingDuration;
  Duration? totalDuration;

  Timer? _countdownTimer;

  SleepTimerViewModel({
    required bool isTimerActive,
    Duration? currentDuration,
    Duration? remainingTime,
    required bool currentEndOfTrack,
  })  : isRunning = isTimerActive,
        endOfTrackMode = currentEndOfTrack,
        selectedHours = 0,
        selectedMinutes = 30,
        selectedSeconds = 0 {
    if (isRunning && remainingTime != null) {
      remainingDuration = remainingTime;
      totalDuration = currentDuration ?? remainingTime;
      selectedHours = remainingTime.inHours;
      selectedMinutes = remainingTime.inMinutes.remainder(60);
      selectedSeconds = remainingTime.inSeconds.remainder(60);
      _startLocalCountdown();
    } else {
      final duration = currentDuration ?? const Duration(minutes: 30);
      selectedHours = duration.inHours;
      selectedMinutes = duration.inMinutes.remainder(60);
      selectedSeconds = duration.inSeconds.remainder(60);
      totalDuration = duration;
    }
  }

  double get progress {
    if (isRunning && totalDuration != null && remainingDuration != null) {
      return 1.0 - (remainingDuration!.inSeconds / totalDuration!.inSeconds);
    }
    return 0.0;
  }

  void _startLocalCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingDuration != null && remainingDuration!.inSeconds > 0) {
        remainingDuration = Duration(seconds: remainingDuration!.inSeconds - 1);
        selectedHours = remainingDuration!.inHours;
        selectedMinutes = remainingDuration!.inMinutes.remainder(60);
        selectedSeconds = remainingDuration!.inSeconds.remainder(60);
        notifyListeners();
      } else {
        _countdownTimer?.cancel();
      }
    });
  }

  void onHourSelected(int index) {
    if (isRunning) return;
    selectedHours = index % 24;
    notifyListeners();
  }

  void onMinuteSelected(int index) {
    if (isRunning) return;
    selectedMinutes = index % 60;
    notifyListeners();
  }

  void onSecondSelected(int index) {
    if (isRunning) return;
    selectedSeconds = index % 60;
    notifyListeners();
  }

  void toggleEndOfTrackMode() {
    if (isRunning) return;
    endOfTrackMode = !endOfTrackMode;
    notifyListeners();
  }

  Duration get selectedDuration => Duration(
    hours: selectedHours,
    minutes: selectedMinutes,
    seconds: selectedSeconds,
  );

  bool validateDuration() {
    return selectedDuration.inSeconds > 0;
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
