enum AudioType {
  asmr,
  mix,
  generated,
}

class SavedAudio {
  final String id;
  final String name;
  final Duration duration;
  final String localPath;
  final DateTime savedAt;
  final AudioType type;
  final int fileSize;
  bool isFavorite;

  SavedAudio({
    required this.id,
    required this.name,
    required this.duration,
    required this.localPath,
    required this.savedAt,
    required this.type,
    required this.fileSize,
    required this.isFavorite,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'durationSeconds': duration.inSeconds,
      'localPath': localPath,
      'savedAt': savedAt.toIso8601String(),
      'type': _typeToString(type),
      'fileSize': fileSize,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  factory SavedAudio.fromMap(Map<String, dynamic> map) {
    return SavedAudio(
      id: map['id'],
      name: map['name'],
      duration: Duration(seconds: map['durationSeconds']),
      localPath: map['localPath'],
      savedAt: DateTime.parse(map['savedAt']),
      type: _stringToType(map['type']),
      fileSize: map['fileSize'],
      isFavorite: map['isFavorite'] == 1,
    );
  }

  static String _typeToString(AudioType type) {
    switch (type) {
      case AudioType.asmr:
        return 'asmr';
      case AudioType.mix:
        return 'mix';
      case AudioType.generated:
        return 'generated';
    }
  }

  static AudioType _stringToType(String typeString) {
    if (typeString.contains('generated')) {
      return AudioType.generated;
    } else if (typeString.contains('mix')) {
      return AudioType.mix;
    } else {
      return AudioType.asmr;
    }
  }

  SavedAudio copyWith({
    String? id,
    String? name,
    Duration? duration,
    String? localPath,
    DateTime? savedAt,
    AudioType? type,
    int? fileSize,
    bool? isFavorite,
  }) {
    return SavedAudio(
      id: id ?? this.id,
      name: name ?? this.name,
      duration: duration ?? this.duration,
      localPath: localPath ?? this.localPath,
      savedAt: savedAt ?? this.savedAt,
      type: type ?? this.type,
      fileSize: fileSize ?? this.fileSize,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
