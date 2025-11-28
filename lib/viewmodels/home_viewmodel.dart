import 'package:flutter/material.dart';
import 'package:aethel/theme/app_theme.dart';

class HomeViewModel extends ChangeNotifier {
  bool _isNavigating = false;
  bool get isNavigating => _isNavigating;

  bool _isReady = false;
  bool get isReady => _isReady;

  void setReady() {
    _isReady = true;
    notifyListeners();
  }

  void startNavigation() {
    _isNavigating = true;
    notifyListeners();
  }

  void completeNavigation() {
    _isNavigating = false;
    notifyListeners();
  }

  // Логика для навигации к экрану АСМР
  Future<void> navigateToAsmr(BuildContext context, Widget destination) async {
    if (_isNavigating) return;

    startNavigation();

    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
            ),
          );
          return Stack(
            children: [
              Container(color: theme.primaryDark),
              FadeTransition(opacity: fadeIn, child: child),
            ],
          );
        },
        transitionDuration: const Duration(milliseconds: 1000),
      ),
    );

    completeNavigation();
  }

  // Логика для навигации к библиотеке
  Future<void> navigateToLibrary(BuildContext context, Widget destination) async {
    if (_isNavigating) return;

    startNavigation();

    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
            ),
          );
          return Stack(
            children: [
              Container(color: theme.primaryDark),
              FadeTransition(opacity: fadeIn, child: child),
            ],
          );
        },
        transitionDuration: const Duration(milliseconds: 1000),
      ),
    );

    completeNavigation();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
