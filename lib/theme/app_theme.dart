import 'package:animated_background/particles.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Сервис управления темой приложения (темная тема)
class AppTheme {
  static final AppTheme _instance = AppTheme._internal();
  factory AppTheme() => _instance;
  AppTheme._internal();

  // Основные цвета темы
  final Color _primaryDark = const Color(0xFF0E0E10);
  final Color _secondaryDark = const Color(0xFF1A1A1C);
  final Color _accentColor = const Color(0xFFBFA87C);

  // Текстовые цвета
  final Color _textPrimary = Colors.white;
  final Color _textSecondary = Colors.white70;
  final Color _textTertiary = Colors.white54;

  // Системные цвета
  static const Color errorColor = Color(0xFF8B3333);
  static const Color successColor = Colors.green;
  static const Color whiteColor = Colors.white;
  static const Color blackColor = Colors.black;
  static const Color transparentColor = Colors.transparent;

  // Геттеры для основных цветов
  Color get primaryDark => _primaryDark;
  Color get secondaryDark => _secondaryDark;
  Color get accentColor => _accentColor;
  bool get isDarkMode => true;

  // Оттенки
  Color get accentLight => _accentColor.withOpacity(0.7);
  Color get accentMedium => _accentColor.withOpacity(0.5);
  Color get accentSubtle => _accentColor.withOpacity(0.3);
  Color get accentVerySubtle => _accentColor.withOpacity(0.2);
  Color get accentMinimal => _accentColor.withOpacity(0.1);

  // Дополнительные оттенкии
  Color get secondaryDarkLight => _secondaryDark.withOpacity(0.6);
  Color get secondaryDarkMedium => _secondaryDark.withOpacity(0.4);
  Color get secondaryDarkSubtle => _secondaryDark.withOpacity(0.25);
  Color get secondaryDarkVerySubtle => _secondaryDark.withOpacity(0.15);

  // Цвета для карточек
  Color get controlCardBackground => _secondaryDark.withOpacity(0.4);
  Color get controlCardGradientEnd => _secondaryDark.withOpacity(0.25);
  Color get controlCardBorder => whiteColor.withOpacity(0.1);
  Color get controlButtonIcon => accentColor;
  Color get playButtonBackground => accentColor;
  Color get playButtonGradientEnd => const Color(0xFFA08860);
  Color get playButtonShadow => accentMedium;

  // Цвет текста
  Color get whiteLight => _textPrimary;
  Color get whiteMedium => _textSecondary;
  Color get whiteSubtle => _textTertiary;
  Color get whiteVerySubtle => Colors.white.withOpacity(0.4);
  Color get whiteMinimal => Colors.white.withOpacity(0.3);

  // Текст для треков
  Color get trackTitle => Colors.white;
  Color get trackDuration => _accentColor.withOpacity(0.3);

  // Состояние отключенных кнопок
  Color get disabledButtonLight => _secondaryDark.withOpacity(0.25);
  Color get disabledButtonDark => _secondaryDark.withOpacity(0.15);
  Color get disabledButtonBorder => _accentColor.withOpacity(0.3);
  Color get disabledButtonIcon => _accentColor;
  Color get disabledButtonText => _accentColor.withOpacity(0.5);

  // Поиск и категории
  Color get searchHint => _accentColor.withOpacity(0.5);
  Color get searchText => Colors.white;
  Color get inactiveCategoryText => _accentColor.withOpacity(0.3);
  Color get addSoundText => _accentColor;
  Color get inactiveTabIcon => _accentColor.withOpacity(0.3);
  Color get selectedTrackText => Colors.white;

  // Цвета системные
  Color get errorLight => errorColor.withOpacity(0.5);
  Color get errorMedium => errorColor.withOpacity(0.3);
  Color get errorSubtle => errorColor.withOpacity(0.2);

  Color get successLight => successColor.withOpacity(0.8);
  Color get successMedium => successColor.withOpacity(0.5);
  Color get successSubtle => successColor.withOpacity(0.2);

  // Градиенты
  LinearGradient get accentGradient => LinearGradient(
    colors: [
      accentVerySubtle,
      accentMinimal,
    ],
  );

  LinearGradient get accentGradientStrong => LinearGradient(
    colors: [
      accentSubtle,
      accentVerySubtle,
    ],
  );

  LinearGradient get secondaryGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      secondaryDarkSubtle,
      secondaryDarkVerySubtle,
    ],
  );

  LinearGradient get controlCardGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      controlCardBackground,
      controlCardGradientEnd,
    ],
  );

  LinearGradient get playButtonGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      playButtonBackground,
      playButtonGradientEnd,
    ],
  );

  LinearGradient get disabledButtonGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      disabledButtonDark,
      disabledButtonLight,
    ],
  );

  LinearGradient get errorGradient => LinearGradient(
    colors: [
      errorMedium,
      errorSubtle,
    ],
  );

  LinearGradient get successGradient => LinearGradient(
    colors: [
      successMedium,
      successSubtle,
    ],
  );

  LinearGradient get sideButtonGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      sideButtonBackground,
      sideButtonBackground.withOpacity(0.7),
    ],
  );

  // Для свича (переключатель)
  Color get switchActiveThumb => accentColor;
  Color get switchActiveTrack => accentMedium;
  Color get switchInactiveThumb => Colors.white38;
  Color get switchInactiveTrack => secondaryDark;

  // Для боковых кнопок
  Color get sideButtonBackground => secondaryDark.withOpacity(0.4);
  Color get sideButtonBorder => accentColor.withOpacity(0.3);

  // Границы
  Border get accentBorderLight => Border.all(
    color: accentSubtle,
    width: 1.5,
  );

  Border get accentBorderMedium => Border.all(
    color: accentMedium,
    width: 1.5,
  );

  Border get accentBorderStrong => Border.all(
    color: accentLight,
    width: 2,
  );

  Border get errorBorder => Border.all(
    color: errorLight,
    width: 1.5,
  );

  Border get successBorder => Border.all(
    color: successColor,
    width: 1.5,
  );

  // Тени
  List<BoxShadow> get accentShadow => [
    BoxShadow(
      color: accentSubtle,
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];

  List<BoxShadow> get accentShadowStrong => [
    BoxShadow(
      color: accentMedium,
      blurRadius: 12,
      spreadRadius: 1,
    ),
  ];

  List<BoxShadow> get playButtonShadowEffect => [
    BoxShadow(
      color: playButtonShadow,
      blurRadius: 18,
      spreadRadius: 1,
      offset: const Offset(0, 3),
    ),
  ];

  // Стиль текста
  TextStyle get headerStyle => TextStyle(
    color: accentColor,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  TextStyle get titleStyle => TextStyle(
    color: _textPrimary,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
  );

  TextStyle get subtitleStyle => TextStyle(
    color: accentLight,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
  );

  TextStyle get bodyStyle => TextStyle(
    color: _textPrimary,
    fontSize: 14,
    letterSpacing: 0.3,
  );

  TextStyle get captionStyle => TextStyle(
    color: whiteSubtle,
    fontSize: 12,
  );

  TextStyle get buttonStyle => TextStyle(
    color: accentColor,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  TextStyle get errorTextStyle => const TextStyle(
    color: errorColor,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  TextStyle get successTextStyle => const TextStyle(
    color: successColor,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  // Параметры виджетов
  ParticleOptions get particleOptions => ParticleOptions(
    baseColor: accentColor,
    spawnMinSpeed: 10,
    spawnMaxSpeed: 30,
    spawnMinRadius: 2,
    spawnMaxRadius: 4,
    particleCount: 25,
  );

  SliderThemeData get sliderTheme => SliderThemeData(
    activeTrackColor: accentColor,
    inactiveTrackColor: primaryDark,
    thumbColor: accentColor,
    overlayColor: accentVerySubtle,
    trackHeight: 3,
    thumbShape: const RoundSliderThumbShape(
      enabledThumbRadius: 5,
    ),
    overlayShape: const RoundSliderOverlayShape(
      overlayRadius: 12,
    ),
  );

  // Загрузка темы
  Future<void> loadSavedTheme() async {
    // Тема всегда темная
    return;
  }
}

// Глобальный экземпляр для удобного доступа
final theme = AppTheme();
