import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/saved_audio.dart';
import '../services/audio_library_service.dart';
import '../services/sleep_timer_service.dart';

class OfflineAsmrPlayerViewModel extends ChangeNotifier {
  final SavedAudio audio;
  final List<SavedAudio> playlist;
  final AudioLibraryService _service = AudioLibraryService();
  final SleepTimerService _sleepTimerService = SleepTimerService();

  late AudioPlayer audioPlayer;
  late ConcatenatingAudioSource playlistSource;

  bool isSleepTimerActive = false;
  Duration? sleepTimerDuration;
  bool sleepTimerEndOfTrack = false;
  bool isPlaying = false;
  bool isLoading = true;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  double volume = 0.70;
  LoopMode loopMode = LoopMode.off;
  bool isShuffle = false;
  bool isFavorite = false;
  String? errorMessage;
  int currentIndex = 0;

  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _currentIndexSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;

  SavedAudio get currentAudio => playlist[currentIndex];
  Duration? get sleepTimerRemaining => _sleepTimerService.remainingTime;

  OfflineAsmrPlayerViewModel(this.audio, this.playlist) {
    audioPlayer = AudioPlayer();
    currentIndex = playlist.indexWhere((a) => a.id == audio.id);
    if (currentIndex == -1) currentIndex = 0;
    isFavorite = audio.isFavorite;
    initializePlaylist();
  }

  Future<void> initializePlaylist() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      playlistSource = ConcatenatingAudioSource(
        children: playlist.map((audio) {
          return AudioSource.uri(
            Uri.file(audio.localPath),
            tag: audio,
          );
        }).toList(),
      );

      await audioPlayer.setAudioSource(
        playlistSource,
        initialIndex: currentIndex,
        initialPosition: Duration.zero,
      );

      await audioPlayer.setVolume(volume);
      await audioPlayer.setLoopMode(loopMode);
      await audioPlayer.setShuffleModeEnabled(isShuffle);

      _setupListeners();

      isLoading = false;
      notifyListeners();

      await audioPlayer.play();
      print('✅ Playlist loaded with ${playlist.length} tracks');
    } catch (e) {
      print('❌ Error loading playlist: $e');
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  void _setupListeners() {
    _playerStateSubscription = audioPlayer.playerStateStream.listen((state) {
      isPlaying = state.playing;
      notifyListeners();
    });

    _currentIndexSubscription = audioPlayer.currentIndexStream.listen((index) {
      if (index != null && currentIndex != index) {
        currentIndex = index;
        final newAudio = playlist[index];
        isFavorite = newAudio.isFavorite;
        notifyListeners();
        print('🎵 Current track: ${newAudio.name}');
      }
    });

    _durationSubscription = audioPlayer.durationStream.listen((dur) {
      if (dur != null) {
        duration = dur;
        notifyListeners();
      }
    });

    _positionSubscription = audioPlayer.positionStream.listen((pos) {
      position = pos;
      notifyListeners();
    });
  }

  Future<void> togglePlayPause() async {
    try {
      if (isPlaying) {
        await audioPlayer.pause();
      } else {
        await audioPlayer.play();
      }
    } catch (e) {
      print('Error toggle play/pause: $e');
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await audioPlayer.seek(position);
    } catch (e) {
      print('Error seeking: $e');
    }
  }

  Future<void> skipForward() async {
    final newPosition = position + const Duration(seconds: 15);
    if (newPosition < duration) {
      await seek(newPosition);
    } else {
      await seek(duration);
    }
  }

  Future<void> skipBackward() async {
    final newPosition = position - const Duration(seconds: 15);
    if (newPosition > Duration.zero) {
      await seek(newPosition);
    } else {
      await seek(Duration.zero);
    }
  }

  Future<void> previousTrack() async {
    try {
      await audioPlayer.seekToPrevious();
    } catch (e) {
      print('❌ Error seeking to previous: $e');
    }
  }

  Future<void> nextTrack() async {
    try {
      await audioPlayer.seekToNext();
    } catch (e) {
      print('❌ Error seeking to next: $e');
    }
  }

  Future<void> toggleLoop() async {
    if (loopMode == LoopMode.off) {
      loopMode = LoopMode.all;
    } else if (loopMode == LoopMode.all) {
      loopMode = LoopMode.one;
    } else {
      loopMode = LoopMode.off;
    }
    notifyListeners();
    await audioPlayer.setLoopMode(loopMode);
    print('🔁 Loop mode: $loopMode');
  }

  Future<void> toggleShuffle() async {
    isShuffle = !isShuffle;
    notifyListeners();
    await audioPlayer.setShuffleModeEnabled(isShuffle);
    print('🔀 Shuffle: $isShuffle');
  }

  Future<bool> toggleFavorite() async {
    final success = await _service.toggleFavorite(currentAudio.id);
    if (success) {
      isFavorite = !isFavorite;
      currentAudio.isFavorite = isFavorite;
      notifyListeners();
    }
    return success;
  }

  void setVolume(double newVolume) {
    volume = newVolume;
    audioPlayer.setVolume(newVolume);
    notifyListeners();
  }

  void startSleepTimer({
    required Duration duration,
    required bool endOfTrack,
    required VoidCallback onComplete,
  }) {
    isSleepTimerActive = true;
    sleepTimerDuration = duration;
    sleepTimerEndOfTrack = endOfTrack;
    notifyListeners();

    _sleepTimerService.startTimer(
      duration: duration,
      player: audioPlayer,
      endOfTrackMode: endOfTrack,
      onComplete: () {
        isSleepTimerActive = false;
        sleepTimerDuration = null;
        sleepTimerEndOfTrack = false;
        notifyListeners();
        onComplete();
      },
    );
  }

  void stopSleepTimer() {
    _sleepTimerService.cancelTimer();
    isSleepTimerActive = false;
    sleepTimerDuration = null;
    sleepTimerEndOfTrack = false;
    notifyListeners();
  }

  void stopPlayer() {
    audioPlayer.stop();
  }

  String formatDuration(Duration dur) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = dur.inHours;
    final minutes = dur.inMinutes.remainder(60);
    final seconds = dur.inSeconds.remainder(60);
    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  void dispose() {
    _sleepTimerService.dispose();
    _playerStateSubscription?.cancel();
    _currentIndexSubscription?.cancel();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    audioPlayer.dispose();
    super.dispose();
  }
}
