import 'package:flutter/material.dart';
import '../models/saved_audio.dart';
import '../services/audio_library_service.dart';

class LibraryViewModel extends ChangeNotifier {
  final AudioLibraryService _service = AudioLibraryService();

  List<SavedAudio> _asmrAudios = [];
  List<SavedAudio> _favoriteAudios = [];
  bool _isLoading = true;
  int _totalSize = 0;
  int _currentTab = 0;

  List<SavedAudio> get asmrAudios => _asmrAudios;
  List<SavedAudio> get favoriteAudios => _favoriteAudios;
  bool get isLoading => _isLoading;
  int get totalSize => _totalSize;
  int get currentTab => _currentTab;

  List<SavedAudio> get currentAudios =>
      _currentTab == 0 ? _asmrAudios : _favoriteAudios;

  int get currentCount => currentAudios.length;

  int get currentSize =>
      currentAudios.fold(0, (sum, audio) => sum + audio.fileSize);

  String get currentLabel => _currentTab == 0 ? 'АСМР' : 'Избранных';

  LibraryViewModel() {
    loadLibrary();
  }

  Future<void> loadLibrary() async {
    _isLoading = true;
    notifyListeners();

    final asmrAudios = await _service.getASMRAudio();
    final favoriteAudios = await _service.getFavoriteAudio();
    final totalSize = await _service.getTotalSize();

    _asmrAudios = asmrAudios;
    _favoriteAudios = favoriteAudios;
    _totalSize = totalSize;
    _isLoading = false;

    notifyListeners();
  }

  void setCurrentTab(int index) {
    _currentTab = index;
    notifyListeners();
  }

  Future<bool> deleteAudio(SavedAudio audio) async {
    final success = await _service.deleteAudio(audio.id);
    if (success) {
      await loadLibrary();
    }
    return success;
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
}
