import 'dart:async';
import 'package:flutter/material.dart';
import '../models/asmr_track.dart';
import '../models/saved_audio.dart';
import 'audio_library_service.dart';

enum DownloadStatus {
  queued,
  preparing,
  downloading,
  completed,
  failed,
  cancelled
}

class DownloadTask {
  final String id;
  final AsmrTrack track;
  DownloadStatus status;
  double progress;
  int receivedBytes;
  int totalBytes;
  String? errorMessage;
  DateTime addedAt;
  Map<String, dynamic>? audioInfo;

  DownloadTask({
    required this.id,
    required this.track,
    this.status = DownloadStatus.queued,
    this.progress = 0.0,
    this.receivedBytes = 0,
    this.totalBytes = 0,
    this.errorMessage,
    this.audioInfo,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();
}

class DownloadQueueManager extends ChangeNotifier {
  static final DownloadQueueManager _instance = DownloadQueueManager._internal();
  factory DownloadQueueManager() => _instance;
  DownloadQueueManager._internal();

  final AudioLibraryService _audioService = AudioLibraryService();
  final List<DownloadTask> _queue = [];
  DownloadTask? _currentTask;
  Timer? _notificationTimer;
  Timer? _processingTimer;

  final StreamController<DownloadTask> _progressController =
  StreamController<DownloadTask>.broadcast();

  Stream<DownloadTask> get progressStream => _progressController.stream;

  Function(String message)? onShowNotification;
  Function(String trackName)? onDownloadCompleted;

  List<DownloadTask> get queue => List.unmodifiable(_queue);
  DownloadTask? get currentTask => _currentTask;
  int get queueLength => _queue.length;
  bool get isProcessing => _currentTask != null;

  void initialize() {
    _startNotificationTimer();
    _startProcessingLoop();
  }

  Future<bool> addToQueue(AsmrTrack track) async {
    final isDownloaded = await _audioService.isAudioDownloaded(track.id);
    if (isDownloaded) {
      return false;
    }

    if (_queue.any((task) => task.id == track.id) ||
        _currentTask?.id == track.id) {
      return false;
    }

    final task = DownloadTask(
      id: track.id,
      track: track,
      status: DownloadStatus.queued,
    );

    _queue.add(task);
    notifyListeners();

    _audioService.getAudioInfo(track.id).then((info) {
      if (info != null) {
        task.audioInfo = info;
        task.totalBytes = info['audioSize'] ?? 0;
      }
    }).catchError((e) {
      print('Не удалось получить информацию об аудио: $e');
    });

    return true;
  }

  void cancelCurrentDownload() {
    if (_currentTask == null) return;

    final trackId = _currentTask!.id;

    _audioService.cancelDownload(trackId);
    _audioService.cancelDownloadOnServer(trackId);

    _currentTask!.status = DownloadStatus.cancelled;

    final cancelledTask = _currentTask!;
    _currentTask = null;

    _progressController.add(cancelledTask);
    notifyListeners();
  }

  void removeFromQueue(String trackId) {
    if (_currentTask?.id == trackId) {
      cancelCurrentDownload();
      return;
    }

    _audioService.cancelDownloadOnServer(trackId);

    _queue.removeWhere((task) => task.id == trackId);
    notifyListeners();
  }

  DownloadTask? getTaskStatus(String trackId) {
    if (_currentTask?.id == trackId) {
      return _currentTask;
    }

    try {
      return _queue.firstWhere((task) => task.id == trackId);
    } catch (e) {
      return null;
    }
  }

  void _startProcessingLoop() {
    _processingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentTask == null && _queue.isNotEmpty) {
        _processNextInQueue();
      }
    });
  }

  Future<void> _processNextInQueue() async {
    if (_queue.isEmpty || _currentTask != null) return;

    _currentTask = _queue.removeAt(0);
    _currentTask!.status = DownloadStatus.downloading;
    _currentTask!.progress = 0.0;
    _currentTask!.receivedBytes = 0;

    _progressController.add(_currentTask!);
    notifyListeners();

    try {
      final result = await _audioService.downloadAsmrTrack(
        _currentTask!.track,
            (progress, received, total) {
          if (_currentTask == null) return;

          _currentTask!.progress = progress;
          _currentTask!.receivedBytes = received;
          _currentTask!.totalBytes = total;

          _progressController.add(_currentTask!);
        },
      );

      if (_currentTask == null) return;

      if (result != null) {
        _currentTask!.status = DownloadStatus.completed;
        _currentTask!.progress = 1.0;

        _progressController.add(_currentTask!);
        notifyListeners();

        onDownloadCompleted?.call(_currentTask!.track.name);
      } else {
        _currentTask!.status = DownloadStatus.failed;
        _currentTask!.errorMessage = 'Ошибка скачивания';
        _progressController.add(_currentTask!);
        notifyListeners();
      }
    } catch (e) {
      if (_currentTask != null) {
        _currentTask!.status = DownloadStatus.failed;
        _currentTask!.errorMessage = e.toString();
        _progressController.add(_currentTask!);
        notifyListeners();
        print('Ошибка загрузки: $e');
      }
    } finally {
      _currentTask = null;
      notifyListeners();
    }
  }

  void _startNotificationTimer() {
    _notificationTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _showPeriodicNotification();
    });
  }

  void _showPeriodicNotification() {
    if (onShowNotification == null) return;

    String message;

    if (_currentTask != null) {
      final percent = (_currentTask!.progress * 100).toInt();
      if (_currentTask!.status == DownloadStatus.downloading && percent > 0) {
        message = 'Скачивание $percent%. В очереди ${_queue.length}.';
      } else {
        message = 'Подготовка... В очереди ${_queue.length}.';
      }
    } else if (_queue.isNotEmpty) {
      message = 'В очереди ${_queue.length}.';
    } else {
      return;
    }

    onShowNotification!(message);
  }

  void clearCompleted() {
    _queue.removeWhere((task) =>
    task.status == DownloadStatus.completed ||
        task.status == DownloadStatus.failed);
    notifyListeners();
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    _processingTimer?.cancel();
    _progressController.close();
    super.dispose();
  }
}
