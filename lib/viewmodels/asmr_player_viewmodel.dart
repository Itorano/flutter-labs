import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/asmr_track.dart';
import '../services/audio_library_service.dart';
import '../services/download_queue_service.dart';

class AsmrPlayerViewModel extends ChangeNotifier {
  final AsmrTrack track;
  final AudioLibraryService _service = AudioLibraryService();
  final DownloadQueueManager _queueManager;

  late YoutubePlayerController controller;
  bool isPlayerReady = false;
  bool isDownloaded = false;
  bool isPreparingToAdd = false;

  AsmrPlayerViewModel(this.track, this._queueManager) {
    _initPlayer();
    _checkIfDownloaded();
    _queueManager.addListener(_onQueueUpdate);
    _setupQueueListener();
  }

  void _initPlayer() {
    controller = YoutubePlayerController(
      initialVideoId: track.id,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
        hideControls: false,
        loop: false,
      ),
    )..addListener(_playerListener);
  }

  void _playerListener() {
    if (isPlayerReady && !controller.value.isFullScreen) {
      notifyListeners();
    }
  }

  void _setupQueueListener() {
    _queueManager.progressStream.listen((task) {
      if (task.id == track.id) {
        if (task.status == DownloadStatus.completed) {
          _checkIfDownloaded();
        }
        notifyListeners();
      }
    });
  }

  Future<void> _checkIfDownloaded() async {
    final downloaded = await _service.isAudioDownloaded(track.id);
    isDownloaded = downloaded;
    notifyListeners();
  }

  void _onQueueUpdate() {
    notifyListeners();
  }

  void setPlayerReady() {
    isPlayerReady = true;
    notifyListeners();
  }

  Future<bool> startDownload() async {
    if (isPreparingToAdd) return false;

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }

    isPreparingToAdd = true;
    notifyListeners();

    final info = await _service.getAudioInfo(track.id);
    isPreparingToAdd = false;
    notifyListeners();

    return info != null;
  }

  Future<Map<String, dynamic>?> getAudioInfo() async {
    return await _service.getAudioInfo(track.id);
  }

  Future<bool> addToQueue() async {
    final added = await _queueManager.addToQueue(track);
    notifyListeners();
    return added;
  }

  void cancelDownload() {
    _queueManager.removeFromQueue(track.id);
    notifyListeners();
  }

  DownloadTask? getTaskStatus() {
    return _queueManager.getTaskStatus(track.id);
  }

  bool isCurrentlyDownloading() {
    return _queueManager.currentTask?.id == track.id;
  }

  List<DownloadTask> getQueue() {
    return _queueManager.queue;
  }

  void pausePlayer() {
    controller.pause();
  }

  String formatFileSize(int bytes) {
    return _service.formatFileSize(bytes);
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  void dispose() {
    _queueManager.removeListener(_onQueueUpdate);
    controller.dispose();
    super.dispose();
  }
}
