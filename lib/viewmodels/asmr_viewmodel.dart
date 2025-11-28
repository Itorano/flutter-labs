import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'dart:math';
import '../models/asmr_track.dart';
import '../models/saved_audio.dart';
import '../services/audio_library_service.dart';
import '../services/download_queue_service.dart';

class AsmrViewModel extends ChangeNotifier {
  final AudioLibraryService _libraryService = AudioLibraryService();
  final DownloadQueueManager _queueManager;
  final String _youtubeApiKey = dotenv.env['YOUTUBE_API_KEY'] ?? '';

  List<AsmrTrack> _tracks = [];
  bool _isLoading = true;
  String? _errorMessage;
  Set<String> _downloadedTrackIds = {};
  String _currentSearchQuery = '';
  bool _isCategoriesPressed = false;

  // Теги для случайного поиска
  final List<String> _searchTagsRu = [
    'ASMR сон',
    'ASMR релаксация',
    'ASMR медитация',
    'ASMR шепот',
    'ASMR спа',
    'ASMR успокоение',
  ];

  final List<String> _searchTagsEn = [
    'ASMR sleep',
    'ASMR relaxation',
    'ASMR meditation',
    'ASMR whisper',
    'ASMR spa',
    'ASMR calm',
  ];

  List<AsmrTrack> get tracks => _tracks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Set<String> get downloadedTrackIds => _downloadedTrackIds;
  String get currentSearchQuery => _currentSearchQuery;
  bool get isCategoriesPressed => _isCategoriesPressed;
  DownloadQueueManager get queueManager => _queueManager;

  AsmrViewModel(this._queueManager) {
    _queueManager.addListener(_onQueueChanged);
    initialize();
  }

  void initialize() {
    loadAsmrTracks();
    loadDownloadedTracks();
  }

  void _onQueueChanged() {
    notifyListeners();
  }

  Future<void> loadDownloadedTracks() async {
    final downloaded = await _libraryService.getAllAudio();
    _downloadedTrackIds = downloaded
        .where((a) => a.type == AudioType.asmr)
        .map((a) => a.id)
        .toSet();
    notifyListeners();
  }

  String _detectLanguage(String query) {
    final cyrillicRegex = RegExp(r'[а-яА-ЯёЁ]');
    return cyrillicRegex.hasMatch(query) ? 'ru' : 'en';
  }

  Future<void> loadAsmrTracks() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final random = Random();
      String searchQuery;
      String languageCode;
      int minDurationMinutes = 20;
      final trimmedQuery = _currentSearchQuery.trim();

      print('═' * 60);
      print('DEBUG: Input query = "$trimmedQuery"');
      print('═' * 60);

      if (trimmedQuery.isNotEmpty) {
        languageCode = _detectLanguage(trimmedQuery);
        searchQuery = '$trimmedQuery ASMR';
        print('USER SEARCH: "$trimmedQuery" -> "$searchQuery" (lang: $languageCode, min: >$minDurationMinutes min)');
      } else {
        final randomIndex = random.nextInt(_searchTagsRu.length);
        final ruTag = _searchTagsRu[randomIndex];
        final enTag = _searchTagsEn[randomIndex];
        searchQuery = '$ruTag $enTag';
        languageCode = 'multi';
        print('RANDOM SEARCH (BILINGUAL): "$ruTag" + "$enTag" (min: >$minDurationMinutes min)');
      }

      final queryParams = {
        'part': 'snippet',
        'q': searchQuery,
        'type': 'video',
        'maxResults': '30',
        'order': 'relevance',
        'key': _youtubeApiKey,
      };

      if (languageCode == 'ru') {
        queryParams['relevanceLanguage'] = 'ru';
        queryParams['regionCode'] = 'RU';
        print('Added: relevanceLanguage=ru, regionCode=RU');
      } else if (languageCode == 'multi') {
        print('Added: no language restriction (bilingual search)');
      } else {
        queryParams['relevanceLanguage'] = 'en';
        print('Added: relevanceLanguage=en');
      }

      final searchUrl = Uri.parse('https://www.googleapis.com/youtube/v3/search')
          .replace(queryParameters: queryParams);
      print('Final search query: "$searchQuery"');

      final searchResponse = await http.get(searchUrl);
      if (searchResponse.statusCode != 200) {
        throw Exception('Failed to load videos: ${searchResponse.statusCode}');
      }

      final searchData = json.decode(searchResponse.body);
      final List items = searchData['items'] ?? [];
      print('Found ${items.length} items from YouTube');

      if (items.isEmpty) {
        _errorMessage = 'Видео не найдены. Попробуйте другой поиск.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final videoIds = items
          .map((item) => item['id']['videoId'] as String?)
          .whereType<String>()
          .toList();

      if (videoIds.isEmpty) {
        _errorMessage = 'Видео не найдены';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final videosUrl = Uri.parse('https://www.googleapis.com/youtube/v3/videos')
          .replace(queryParameters: {
        'part': 'contentDetails,snippet',
        'id': videoIds.join(','),
        'key': _youtubeApiKey,
      });

      final videosResponse = await http.get(videosUrl);
      if (videosResponse.statusCode != 200) {
        throw Exception('Failed to load video details: ${videosResponse.statusCode}');
      }

      final videosData = json.decode(videosResponse.body);
      final List videoItems = videosData['items'] ?? [];
      print('Processing ${videoItems.length} videos');

      final tracks = <AsmrTrack>[];
      for (var video in videoItems) {
        try {
          final durationISO = video['contentDetails']?['duration'] as String?;
          if (durationISO == null) continue;

          final duration = _parseDuration(durationISO);
          if (duration.inMinutes >= minDurationMinutes) {
            final thumbnailUrl = video['snippet']?['thumbnails']?['default']?['url'] as String? ??
                video['snippet']?['thumbnails']?['medium']?['url'] as String? ??
                video['snippet']?['thumbnails']?['high']?['url'] as String? ??
                'https://via.placeholder.com/120';

            final title = video['snippet']?['title'] as String? ?? 'Unknown';

            tracks.add(AsmrTrack(
              id: video['id'] as String? ?? 'unknown_${DateTime.now().millisecondsSinceEpoch}',
              name: title,
              duration: duration,
              thumbnailUrl: thumbnailUrl,
              isFavorite: false,
            ));

            print('✓ Added: "$title" (${duration.inHours}h ${duration.inMinutes.remainder(60)}m)');

            if (tracks.length >= 15) {
              print('Reached maximum of 15 tracks');
              break;
            }
          } else {
            print('✗ Skipped (too short): "${video['snippet']?['title']}" (${duration.inMinutes} min)');
          }
        } catch (e) {
          print('✗ Error processing video: $e');
          continue;
        }
      }

      if (tracks.isEmpty) {
        _errorMessage = 'Видео более $minDurationMinutes минут не найдены. Попробуйте другой поиск.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      if (tracks.length < 10) {
        print('WARNING: Only ${tracks.length} tracks found (less than 10 minimum)');
      }

      print('Total tracks loaded: ${tracks.length}');
      tracks.shuffle(Random());

      _tracks = tracks;
      _isLoading = false;
      notifyListeners();
      print('═' * 60);
    } catch (e) {
      _errorMessage = 'Ошибка загрузки: $e';
      _isLoading = false;
      notifyListeners();
      print('ERROR: $e');
      print('═' * 60);
    }
  }

  Duration _parseDuration(String iso8601) {
    final regex = RegExp(
      r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?',
      caseSensitive: false,
    );
    final match = regex.firstMatch(iso8601);
    if (match == null) return Duration.zero;

    final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
    final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
    final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;

    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }

  void refreshDownloadStatus() {
    loadDownloadedTracks();
  }

  void onSearchChanged(String query) {
    _currentSearchQuery = query.trim();
    notifyListeners();

    if (query.trim().isEmpty) {
      loadAsmrTracks();
    }
  }

  void onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      loadAsmrTracks();
    }
  }

  void setCategoriesPressed(bool value) {
    _isCategoriesPressed = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _queueManager.removeListener(_onQueueChanged);
    super.dispose();
  }
}
