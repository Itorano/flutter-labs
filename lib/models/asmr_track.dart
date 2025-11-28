class AsmrTrack {
  final String id;
  final String name;
  final Duration duration;
  final String thumbnailUrl;
  bool isFavorite;

  AsmrTrack({
    required this.id,
    required this.name,
    required this.duration,
    required this.thumbnailUrl,
    this.isFavorite = false,
  });
}
