import 'package:aethel/views/asmr_screen.dart';
import 'package:aethel/views/library_screen.dart';
import 'package:aethel/services/download_queue_service.dart';
import 'package:aethel/theme/app_theme.dart';
import 'package:aethel/viewmodels/app_viewmodel.dart';
import 'package:aethel/viewmodels/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:animated_background/animated_background.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Загружаем переменные окружения
  await dotenv.load(fileName: ".env");

  // Загружаем тему
  await theme.loadSavedTheme();

  final queueManager = DownloadQueueManager();
  queueManager.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider.value(value: queueManager),
      ],
      child: const AethelApp(),
    ),
  );
}

class AethelApp extends StatefulWidget {
  const AethelApp({super.key});

  @override
  State<AethelApp> createState() => _AethelAppState();
}

class _AethelAppState extends State<AethelApp> {
  bool _notificationsSetup = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppViewModel>(
      builder: (context, appViewModel, _) {
        return MaterialApp(
          title: 'Aethel',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: theme.isDarkMode ? Brightness.dark : Brightness.light,
            scaffoldBackgroundColor: theme.primaryDark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: theme.accentColor,
              brightness: theme.isDarkMode ? Brightness.dark : Brightness.light,
            ),
            fontFamily: 'Manrope',
          ),
          home: Builder(
            builder: (context) {
              if (!_notificationsSetup) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final queueManager = Provider.of<DownloadQueueManager>(
                    context,
                    listen: false,
                  );
                  appViewModel.setupNotifications(context, queueManager);
                  setState(() {
                    _notificationsSetup = true;
                  });
                });
              }
              return const SplashSequenceScreen();
            },
          ),
        );
      },
    );
  }
}

// Последовательность экарнов
class SplashSequenceScreen extends StatefulWidget {
  const SplashSequenceScreen({super.key});

  @override
  State<SplashSequenceScreen> createState() => _SplashSequenceScreenState();
}

class _SplashSequenceScreenState extends State<SplashSequenceScreen>
    with SingleTickerProviderStateMixin {
  bool _showHome = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showHome = true;
        });
        _fadeController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (!_showHome) const SplashScreen(),
        if (_showHome)
          FadeTransition(
            opacity: _fadeAnimation,
            child: const HomeScreen(),
          ),
      ],
    );
  }
}

// сплэш экран (заставка)
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.primaryDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/lotus.svg',
              width: 80,
              height: 80,
              colorFilter: ColorFilter.mode(
                theme.accentColor,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'AETHEL',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w300,
                color: theme.accentColor,
                letterSpacing: 8,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Дыхание тишины',
              style: TextStyle(
                fontSize: 14,
                color: theme.whiteVerySubtle,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// главный экран
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _fadeController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);

    return Scaffold(
      backgroundColor: theme.primaryDark,
      body: AnimatedBackground(
        behaviour: RandomParticleBehaviour(
          options: theme.particleOptions,
        ),
        vsync: this,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/images/lotus.svg',
                    width: 80,
                    height: 80,
                    colorFilter: ColorFilter.mode(
                      theme.accentColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'AETHEL',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w300,
                      color: theme.accentColor,
                      letterSpacing: 8,
                    ),
                  ),
                  const SizedBox(height: 60),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        _buildRectangularButton(
                          label: 'АСМР',
                          icon: Icons.headphones,
                          onPressed: () {
                            homeViewModel.navigateToAsmr(
                              context,
                              const AsmrScreen(),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildRectangularButton(
                          label: 'Библиотека',
                          icon: Icons.library_music_rounded,
                          onPressed: () {
                            homeViewModel.navigateToLibrary(
                              context,
                              const LibraryScreen(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRectangularButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return _RectangularButton(
      label: label,
      icon: icon,
      onPressed: onPressed,
    );
  }
}

class _RectangularButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _RectangularButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  State<_RectangularButton> createState() => _RectangularButtonState();
}

class _RectangularButtonState extends State<_RectangularButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
    });
    await _controller.forward();
    await _controller.reverse();
    await Future.delayed(const Duration(milliseconds: 50));
    if (mounted) {
      widget.onPressed();
    }
    setState(() {
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: double.infinity,
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.accentSubtle,
                    theme.accentVerySubtle,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.accentMedium,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.icon,
                    size: 28,
                    color: theme.accentColor,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 18,
                      color: theme.accentColor,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
