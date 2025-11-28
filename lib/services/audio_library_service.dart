import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/saved_audio.dart';
import '../models/asmr_track.dart';

class AudioLibraryService {
  static final AudioLibraryService _instance = AudioLibraryService._internal();

  factory AudioLibraryService() => _instance;

  AudioLibraryService._internal();

  Database? _database;
  DateTime? _lastRequestTime;
  Map<String, CancelToken> _downloads = {};

  String get _serverUrl {
    return 'https://aethel-backend.onrender.com';
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'audio_library.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE saved_audio(
            id TEXT PRIMARY KEY,
            name TEXT,
            durationSeconds INTEGER,
            localPath TEXT,
            savedAt TEXT,
            type TEXT,
            fileSize INTEGER,
            isFavorite INTEGER
          )
        ''');
      },
    );
  }

  Future<Directory> _getAudioDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${appDir.path}/audio_library');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    return audioDir;
  }

  Future<Map<String, dynamic>?> getAudioInfo(String videoId) async {
    try {
      if (_lastRequestTime != null) {
        final elapsed = DateTime.now().difference(_lastRequestTime!);
        if (elapsed.inMilliseconds < 1000) {
          await Future.delayed(Duration(milliseconds: 1000 - elapsed.inMilliseconds));
        }
      }

      _lastRequestTime = DateTime.now();
      final response = await http.get(
        Uri.parse('$_serverUrl/api/audio-info/$videoId'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 120));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        int videoSize = data['videoSize'] ?? 0;
        int audioSize = data['audioSize'] ?? 0;
        final duration = data['duration'] ?? 0;

        if (videoSize == 0 && duration > 0) {
          videoSize = (duration * 500000).toInt();
        }

        if (audioSize == 0 && duration > 0) {
          audioSize = (duration * 30000).toInt();
        }

        return {
          'videoSize': videoSize,
          'audioSize': audioSize,
          'duration': duration,
          'title': data['title'],
          'bitrate': data['bitrate'] ?? 128,
          'format': data['format'] ?? 'm4a',
          'size': audioSize,
        };
      } else if (response.statusCode == 429) {
        throw Exception('Слишком много запросов. Подождите немного.');
      } else {
        throw Exception('Ошибка сервера: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка получения информации об аудио: $e');
      return null;
    }
  }

  Future<SavedAudio?> downloadAsmrTrack(
      AsmrTrack track,
      Function(double progress, int received, int total) onProgress,
      ) async {
    try {
      final existing = await getAudioById(track.id);
      if (existing != null) {
        return existing;
      }

      final audioDir = await _getAudioDirectory();
      final fileName = '${track.id}.m4a';
      final filePath = '${audioDir.path}/$fileName';

      final cancelToken = CancelToken();
      _downloads[track.id] = cancelToken;

      final dio = Dio();
      dio.options.headers = {
        'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Accept': '*/*',
      };
      dio.options.connectTimeout = const Duration(minutes: 2);
      dio.options.receiveTimeout = const Duration(minutes: 30);
      dio.options.sendTimeout = const Duration(minutes: 30);
      dio.options.followRedirects = true;

      await dio.download(
        '$_serverUrl/api/download-audio/${track.id}',
        filePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            onProgress(progress, received, total);
          } else {
            onProgress(0.5, received, received * 2);
          }
        },
      );

      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Файл не был создан');
      }

      final actualSize = await file.length();
      if (actualSize == 0) {
        await file.delete();
        throw Exception('Загруженный файл пуст');
      }

      final savedAudio = SavedAudio(
        id: track.id,
        name: track.name,
        duration: track.duration,
        localPath: filePath,
        savedAt: DateTime.now(),
        type: AudioType.asmr,
        fileSize: actualSize,
        isFavorite: track.isFavorite,
      );

      final db = await database;
      await db.insert(
        'saved_audio',
        savedAudio.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      _downloads.remove(track.id);
      return savedAudio;
    } catch (e) {
      print('Ошибка загрузки: $e');
      _downloads.remove(track.id);
      return null;
    } finally {
      _downloads.remove(track.id);
    }
  }

  void cancelDownload([String? trackId]) {
    if (trackId != null) {
      final token = _downloads[trackId];
      if (token != null && !token.isCancelled) {
        token.cancel('Загрузка отменена пользователем');
      }
      _downloads.remove(trackId);
    } else {
      for (var token in _downloads.values) {
        if (!token.isCancelled) {
          token.cancel('Все загрузки отменены пользователем');
        }
      }
      _downloads.clear();
    }
  }

  Future<void> cancelDownloadOnServer(String videoId) async {
    try {
      await http.post(
        Uri.parse('$_serverUrl/api/cancel-download/$videoId'),
      );
    } catch (e) {
      print('Не удалось отменить загрузку на сервере: $e');
    }
  }

  Future<List<SavedAudio>> getAllAudio() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'saved_audio',
      orderBy: 'savedAt DESC',
    );

    return List.generate(maps.length, (i) => SavedAudio.fromMap(maps[i]));
  }

  Future<SavedAudio?> getAudioById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'saved_audio',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return SavedAudio.fromMap(maps.first);
  }

  Future<bool> deleteAudio(String id) async {
    try {
      final audio = await getAudioById(id);
      if (audio == null) return false;

      final file = File(audio.localPath);
      if (await file.exists()) {
        await file.delete();
      }

      final db = await database;
      await db.delete(
        'saved_audio',
        where: 'id = ?',
        whereArgs: [id],
      );

      return true;
    } catch (e) {
      print('Ошибка удаления аудио: $e');
      return false;
    }
  }

  Future<bool> isAudioDownloaded(String id) async {
    final audio = await getAudioById(id);
    return audio != null;
  }

  Future<bool> toggleFavorite(String id) async {
    try {
      final db = await database;
      final audio = await getAudioById(id);
      if (audio == null) return false;

      final newFavoriteStatus = audio.isFavorite ? 0 : 1;

      await db.update(
        'saved_audio',
        {'isFavorite': newFavoriteStatus},
        where: 'id = ?',
        whereArgs: [id],
      );

      return true;
    } catch (e) {
      print('Ошибка изменения статуса избранного: $e');
      return false;
    }
  }

  Future<List<SavedAudio>> getFavoriteAudio() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'saved_audio',
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'savedAt DESC',
    );

    return List.generate(maps.length, (i) => SavedAudio.fromMap(maps[i]));
  }

  Future<int> getTotalSize() async {
    final audios = await getAllAudio();
    return audios.fold<int>(0, (sum, audio) => sum + audio.fileSize);
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes Б';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} КБ';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} МБ';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} ГБ';
  }

  Future<List<SavedAudio>> getASMRAudio() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'saved_audio',
      where: 'type = ?',
      whereArgs: ['asmr'],
      orderBy: 'savedAt DESC',
    );
    return List.generate(maps.length, (i) => SavedAudio.fromMap(maps[i]));
  }
}
