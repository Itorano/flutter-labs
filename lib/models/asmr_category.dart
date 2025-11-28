import 'package:flutter/material.dart';

class AsmrCategory {
  final String id;
  final String name;
  final IconData icon;
  final List<String> searchTags;
  final List<String> searchTagsRu;

  AsmrCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.searchTags,
    required this.searchTagsRu,
  });
}
