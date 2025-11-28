import 'package:flutter/material.dart';
import '../models/asmr_category.dart';

class AsmrCategoriesViewModel extends ChangeNotifier {
  final List<AsmrCategory> categories = [
    // Голос
    AsmrCategory(
      id: 'whispering',
      name: 'Шепот',
      icon: Icons.record_voice_over,
      searchTags: ['asmr whisper', 'asmr whispering', 'asmr whisper sleep'],
      searchTagsRu: ['асмр шепот', 'шепот асмр', 'шепот для сна'],
    ),
    AsmrCategory(
      id: 'personal_care',
      name: 'Забота',
      icon: Icons.self_improvement,
      searchTags: ['asmr personal attention', 'asmr care', 'asmr roleplay', 'asmr pampering'],
      searchTagsRu: ['асмр личное внимание', 'асмр забота', 'ролевые игры асмр'],
    ),
    AsmrCategory(
      id: 'storytelling',
      name: 'Истории',
      icon: Icons.auto_stories,
      searchTags: ['asmr storytelling', 'asmr fairy tales', 'asmr myths', 'asmr reading stories'],
      searchTagsRu: ['асмр истории', 'асмр сказки', 'асмр мифы', 'чтение асмр'],
    ),
    AsmrCategory(
      id: 'facts',
      name: 'Факты',
      icon: Icons.lightbulb_outline,
      searchTags: ['asmr facts', 'asmr fun facts', 'asmr educational', 'asmr interesting facts'],
      searchTagsRu: ['асмр факты', 'интересные факты асмр', 'познавательное асмр'],
    ),
    // Касания
    AsmrCategory(
      id: 'tapping',
      name: 'Таппинг',
      icon: Icons.touch_app,
      searchTags: ['asmr tapping', 'asmr nail tapping', 'asmr tap sounds', 'asmr keyboard', 'asmr typing'],
      searchTagsRu: ['асмр таппинг', 'постукивание асмр', 'таппинг ногтями', 'асмр клавиатура', 'печать асмр'],
    ),
    AsmrCategory(
      id: 'scratching',
      name: 'Скрэтчинг',
      icon: Icons.gesture,
      searchTags: ['asmr scratching', 'asmr scratch sounds', 'asmr nails'],
      searchTagsRu: ['асмр царапание', 'скрэтчинг асмр', 'ногти асмр'],
    ),
    AsmrCategory(
      id: 'brushing',
      name: 'Кисти',
      icon: Icons.brush,
      searchTags: ['asmr brushing', 'asmr brush sounds', 'asmr hairbrush'],
      searchTagsRu: ['асмр кисти', 'звуки кисти асмр', 'расческа асмр'],
    ),
    // Материалы
    AsmrCategory(
      id: 'crinkling',
      name: 'Шуршание',
      icon: Icons.air,
      searchTags: ['asmr crinkling', 'asmr crinkle sounds', 'asmr paper sounds'],
      searchTagsRu: ['асмр шуршание', 'шуршание бумаги асмр', 'хруст асмр'],
    ),
    AsmrCategory(
      id: 'destruction',
      name: 'Разрушение',
      icon: Icons.auto_awesome,
      searchTags: ['asmr cutting soap', 'asmr slime sounds', 'asmr clay crushing'],
      searchTagsRu: ['асмр нарезка мыла', 'слайм асмр', 'разрушение асмр'],
    ),
    AsmrCategory(
      id: 'crafting',
      name: 'Ремесло',
      icon: Icons.handyman,
      searchTags: ['asmr woodworking', 'asmr crafting sounds', 'asmr tool sounds'],
      searchTagsRu: ['асмр дерево', 'ремесло асмр', 'инструменты асмр'],
    ),
    AsmrCategory(
      id: 'unboxing',
      name: 'Распаковка',
      icon: Icons.inbox,
      searchTags: ['asmr unboxing', 'asmr unpacking', 'asmr package opening'],
      searchTagsRu: ['асмр распаковка', 'анбоксинг асмр', 'открытие посылок'],
    ),
    // Релакс
    AsmrCategory(
      id: 'massage',
      name: 'Массаж',
      icon: Icons.spa,
      searchTags: ['asmr massage', 'asmr spa'],
      searchTagsRu: ['асмр массаж', 'спа асмр'],
    ),
    AsmrCategory(
      id: 'ambient',
      name: 'Атмосфера',
      icon: Icons.nights_stay,
      searchTags: ['asmr ambient', 'asmr rain sounds', 'asmr nature'],
      searchTagsRu: ['асмр атмосфера', 'звуки дождя асмр', 'природа асмр'],
    ),
    AsmrCategory(
      id: 'binaural',
      name: 'Бинауральные',
      icon: Icons.headphones,
      searchTags: ['asmr binaural', 'asmr 3d sound', 'asmr spatial audio'],
      searchTagsRu: ['асмр бинауральные', '3д звук асмр', 'объемный звук'],
    ),
    AsmrCategory(
      id: 'animals',
      name: 'Питомцы',
      icon: Icons.pets,
      searchTags: ['asmr cat purring', 'asmr cat sounds', 'asmr kitten', 'asmr pet sounds'],
      searchTagsRu: ['асмр мурлыканье', 'звуки кошки асмр', 'котенок асмр', 'питомцы асмр'],
    ),
    // Прочее
    AsmrCategory(
      id: 'eating',
      name: 'Звуки еды',
      icon: Icons.restaurant,
      searchTags: ['asmr eating', 'asmr mukbang', 'asmr food sounds'],
      searchTagsRu: ['асмр еда', 'мукбанг асмр', 'звуки еды асмр'],
    ),
    AsmrCategory(
      id: 'writing',
      name: 'Письмо',
      icon: Icons.edit,
      searchTags: ['asmr writing', 'asmr pen sounds', 'asmr pencil'],
      searchTagsRu: ['асмр письмо', 'звуки ручки асмр', 'карандаш асмр'],
    ),
    // Универсал
    AsmrCategory(
      id: 'triggers',
      name: 'Триггеры',
      icon: Icons.stars,
      searchTags: ['asmr triggers', 'asmr trigger assortment', 'asmr fast triggers'],
      searchTagsRu: ['асмр триггеры', 'ассорти триггеров', 'быстрые триггеры'],
    ),
  ];
}
