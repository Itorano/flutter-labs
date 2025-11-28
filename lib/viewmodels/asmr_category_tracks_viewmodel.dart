import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import '../models/asmr_track.dart';
import '../models/saved_audio.dart';
import '../services/audio_library_service.dart';

class CategoryTracksViewModel extends ChangeNotifier {
  final String categoryName;
  final List<String> searchTags;
  final List<String> searchTagsRu;
  final AudioLibraryService _libraryService = AudioLibraryService();
  final String _youtubeApiKey = 'AIzaSyBSt8MLXiUnsy5JL9tluc_sqcZGU5KSfJg';

  List<AsmrTrack> _tracks = [];
  bool _isLoading = true;
  String? _errorMessage;
  Set<String> _downloadedTrackIds = {};

  List<AsmrTrack> get tracks => _tracks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Set<String> get downloadedTrackIds => _downloadedTrackIds;

  CategoryTracksViewModel({
    required this.categoryName,
    required this.searchTags,
    required this.searchTagsRu,
  }) {
    loadCategoryTracks();
    loadDownloadedTracks();
  }

  Future<void> loadDownloadedTracks() async {
    final downloaded = await _libraryService.getAllAudio();
    _downloadedTrackIds = downloaded
        .where((a) => a.type == AudioType.asmr)
        .map((a) => a.id)
        .toSet();
    notifyListeners();
  }

  Future<void> loadCategoryTracks() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final random = Random();
      final minDurationMinutes = 20;
      print('=' * 60);
      print('CATEGORY: $categoryName');
      print('EN Tags: $searchTags');
      print('RU Tags: $searchTagsRu');
      print('=' * 60);

      final List<AsmrTrack> allTracks = [];
      final Map<String, AsmrTrack> uniqueTracks = {};

      // Поиск по русским тегам (10 треков)
      final ruTag = searchTagsRu[random.nextInt(searchTagsRu.length)];
      print('RU Search: $ruTag');
      final ruTracks = await _searchTracks(ruTag, 'ru', minDurationMinutes, 10);
      print('Found ${ruTracks.length} RU tracks');
      for (var track in ruTracks) {
        uniqueTracks[track.id] = track;
      }

      // Поиск по английским тегам (10 треков)
      final enTag = searchTags[random.nextInt(searchTags.length)];
      print('EN Search: $enTag');
      final enTracks = await _searchTracks(enTag, 'en', minDurationMinutes, 10);
      print('Found ${enTracks.length} EN tracks');
      for (var track in enTracks) {
        uniqueTracks[track.id] = track;
      }

      allTracks.addAll(uniqueTracks.values);

      // Проверка минимум 15 треков
      if (allTracks.length < 15) {
        print('WARNING: Only ${allTracks.length} tracks, loading more...');
        final additionalTag = searchTags[random.nextInt(searchTags.length)];
        final additionalTracks = await _searchTracks(additionalTag, 'en', minDurationMinutes, 15);
        for (var track in additionalTracks) {
          if (!uniqueTracks.containsKey(track.id) && allTracks.length < 15) {
            uniqueTracks[track.id] = track;
            allTracks.add(track);
          }
        }
      }

      if (allTracks.isEmpty) {
        _errorMessage = 'Не удалось загрузить треки';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Перемешиваем
      allTracks.shuffle(random);
      print('Total tracks: ${allTracks.length}');
      print('=' * 60);

      _tracks = allTracks;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Ошибка загрузки: $e';
      _isLoading = false;
      notifyListeners();
      print('ERROR: $e');
    }
  }

  Future<List<AsmrTrack>> _searchTracks(
      String searchQuery,
      String languageCode,
      int minDurationMinutes,
      int maxResults,
      ) async {
    try {
      final queryParams = {
        'part': 'snippet',
        'q': searchQuery,
        'type': 'video',
        'videoDuration': 'long',
        'maxResults': maxResults.toString(),
        'order': 'relevance',
        'key': _youtubeApiKey,
      };

      if (languageCode == 'ru') {
        queryParams['relevanceLanguage'] = 'ru';
        queryParams['regionCode'] = 'RU';
      } else if (languageCode == 'en') {
        queryParams['relevanceLanguage'] = 'en';
      }

      final searchUrl = Uri.parse('https://www.googleapis.com/youtube/v3/search')
          .replace(queryParameters: queryParams);
      final searchResponse = await http.get(searchUrl);
      if (searchResponse.statusCode != 200) {
        return [];
      }

      final searchData = json.decode(searchResponse.body);
      final List items = searchData['items'] ?? [];
      if (items.isEmpty) return [];

      final videoIds = items
          .map((item) => item['id']['videoId'] as String?)
          .whereType<String>()
          .toList();
      if (videoIds.isEmpty) return [];

      final videosUrl = Uri.parse('https://www.googleapis.com/youtube/v3/videos')
          .replace(queryParameters: {
        'part': 'contentDetails,snippet',
        'id': videoIds.join(','),
        'key': _youtubeApiKey,
      });

      final videosResponse = await http.get(videosUrl);
      if (videosResponse.statusCode != 200) {
        return [];
      }

      final videosData = json.decode(videosResponse.body);
      final List videoItems = videosData['items'] ?? [];
      final tracks = <AsmrTrack>[];

      for (var video in videoItems) {
        try {
          final durationISO = video['contentDetails']?['duration'] as String?;
          if (durationISO == null) continue;

          final duration = _parseDuration(durationISO);
          if (duration.inMinutes >= minDurationMinutes) {
            final thumbnailUrl = video['snippet']?['thumbnails']?['default']?['url'] as String? ??
                'https://via.placeholder.com/120';

            tracks.add(AsmrTrack(
              id: video['id'] as String,
              name: video['snippet']?['title'] as String? ?? 'Unknown',
              duration: duration,
              thumbnailUrl: thumbnailUrl,
              isFavorite: false,
            ));
          }
        } catch (e) {
          continue;
        }
      }

      return tracks;
    } catch (e) {
      return [];
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

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
}
