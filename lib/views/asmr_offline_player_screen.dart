import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:animated_background/animated_background.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import '../models/saved_audio.dart';
import '../viewmodels/asmr_offline_player_viewmodel.dart';
import '../theme/app_theme.dart';
import '../views/asmr_sleep_timer_screen.dart';

class OfflineAsmrPlayerScreen extends StatefulWidget {
  final SavedAudio audio;
  final List<SavedAudio> playlist;

  const OfflineAsmrPlayerScreen({
    super.key,
    required this.audio,
    required this.playlist,
  });

  @override
  State<OfflineAsmrPlayerScreen> createState() =>
      _OfflineAsmrPlayerScreenState();
}

class _OfflineAsmrPlayerScreenState extends State<OfflineAsmrPlayerScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
      lowerBound: 0.95,
      upperBound: 1.0,
    );
    _scaleController.value = 1.0;
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OfflineAsmrPlayerViewModel(widget.audio, widget.playlist),
      child: Consumer<OfflineAsmrPlayerViewModel>(
        builder: (context, viewModel, _) {
          // Синхронизация анимации с состоянием плеера
          if (viewModel.isPlaying && !_rotationController.isAnimating) {
            _rotationController.repeat();
          } else if (!viewModel.isPlaying && _rotationController.isAnimating) {
            _rotationController.stop();
          }

          return WillPopScope(
            onWillPop: () async {
              viewModel.stopPlayer();
              return true;
            },
            child: Scaffold(
              backgroundColor: theme.primaryDark,
              resizeToAvoidBottomInset: false,
              body: Stack(
                children: [
                  AnimatedBackground(
                    behaviour: RandomParticleBehaviour(
                      options: theme.particleOptions,
                    ),
                    vsync: this,
                    child: SafeArea(
                      child: Column(
                        children: [
                          _buildAppBar(viewModel),
                          Expanded(
                            child: viewModel.isLoading
                                ? _buildLoadingState()
                                : viewModel.errorMessage != null
                                ? _buildErrorState(viewModel)
                                : _buildPlayerContent(viewModel),
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
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

  Widget _buildAppBar(OfflineAsmrPlayerViewModel viewModel) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: SizedBox(
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.secondaryDarkLight,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: theme.accentColor,
                        size: 20,
                      ),
                      onPressed: () {
                        viewModel.stopPlayer();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                Text(
                  'Плеер',
                  style: TextStyle(
                    color: theme.accentColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.secondaryDarkLight,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        viewModel.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border_rounded,
                        color: viewModel.isFavorite
                            ? Colors.redAccent
                            : theme.accentColor,
                        size: 22,
                      ),
                      onPressed: () async {
                        await viewModel.toggleFavorite();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(viewModel.isFavorite
                                  ? 'Добавлено в избранное'
                                  : 'Удалено из избранного'),
                              duration: const Duration(seconds: 1),
                              backgroundColor: viewModel.isFavorite
                                  ? theme.accentColor
                                  : AppTheme.errorColor,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              margin: const EdgeInsets.only(
                                  bottom: 16, left: 16, right: 16),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.transparentColor,
                  theme.accentSubtle,
                  AppTheme.transparentColor,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              color: theme.accentColor,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Загрузка плейлиста...',
            style: TextStyle(
              color: theme.accentLight,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(OfflineAsmrPlayerViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: theme.secondaryDarkMedium,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppTheme.whiteColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline_rounded,
                      color: AppTheme.errorColor,
                      size: 56,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Ошибка загрузки',
                    style: TextStyle(
                      color: AppTheme.errorColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    viewModel.errorMessage ?? 'Неизвестная ошибка',
                    style: TextStyle(
                      color: theme.whiteLight,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [theme.accentColor, const Color(0xFFA08860)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Material(
                      color: AppTheme.transparentColor,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(12),
                        child: const Center(
                          child: Text(
                            'Вернуться',
                            style: TextStyle(
                              color: AppTheme.whiteColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildPlayerContent(OfflineAsmrPlayerViewModel viewModel) {
    final progress = viewModel.duration.inMilliseconds > 0
        ? viewModel.position.inMilliseconds /
        viewModel.duration.inMilliseconds
        : 0.0;

    return Padding(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 0),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildCircularProgress(progress, size: 200),
          const SizedBox(height: 16),
          _buildTrackInfo(viewModel),
          const Spacer(),
          _buildVolumeSlider(viewModel),
          const SizedBox(height: 16),
          _buildControlPanel(viewModel),
        ],
      ),
    );
  }

  Widget _buildCircularProgress(double progress, {double size = 200}) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: Transform.rotate(
              angle: -1.5708,
              child: CustomPaint(
                painter: CircularProgressPainter(
                  progress: progress,
                  strokeWidth: 5.0,
                  backgroundColor: theme.secondaryDarkSubtle,
                  progressColor: theme.accentColor,
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationController.value * 2 * 3.14159,
                child: SvgPicture.asset(
                  'assets/images/vinyl_record.svg',
                  width: size,
                  height: size,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTrackInfo(OfflineAsmrPlayerViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        viewModel.currentAudio.name,
        style: const TextStyle(
          color: Color(0xFFA08860),
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          height: 1.3,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildVolumeSlider(OfflineAsmrPlayerViewModel viewModel) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.secondaryDarkMedium,
                theme.secondaryDarkSubtle,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.whiteColor.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                viewModel.volume == 0
                    ? Icons.volume_off_rounded
                    : viewModel.volume < 0.3
                    ? Icons.volume_mute_rounded
                    : viewModel.volume < 0.7
                    ? Icons.volume_down_rounded
                    : Icons.volume_up_rounded,
                color: theme.accentColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 5),
                    overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 12),
                    activeTrackColor: theme.accentColor,
                    inactiveTrackColor: theme.accentVerySubtle,
                    thumbColor: theme.accentColor,
                    overlayColor: theme.accentVerySubtle,
                  ),
                  child: Slider(
                    value: viewModel.volume,
                    min: 0.0,
                    max: 1.0,
                    onChanged: viewModel.setVolume,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 38,
                child: Text(
                  '${(viewModel.volume * 100).toInt()}%',
                  style: TextStyle(
                    color: theme.accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlPanel(OfflineAsmrPlayerViewModel viewModel) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.secondaryDarkMedium,
                theme.secondaryDarkSubtle,
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppTheme.whiteColor.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              _buildTimeProgress(viewModel),
              const SizedBox(height: 18),
              _buildMainControls(viewModel),
              const SizedBox(height: 14),
              _buildAdditionalControls(viewModel),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeProgress(OfflineAsmrPlayerViewModel viewModel) {
    final progress = viewModel.duration.inMilliseconds > 0
        ? viewModel.position.inMilliseconds /
        viewModel.duration.inMilliseconds
        : 0.0;

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            activeTrackColor: theme.accentColor,
            inactiveTrackColor: theme.accentVerySubtle,
            thumbColor: theme.accentColor,
            overlayColor: theme.accentVerySubtle,
          ),
          child: Slider(
            value: progress.clamp(0.0, 1.0),
            onChanged: (value) {
              final position = viewModel.duration * value;
              viewModel.seek(position);
            },
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              viewModel.formatDuration(viewModel.position),
              style: TextStyle(
                color: theme.accentColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              viewModel.formatDuration(viewModel.duration),
              style: TextStyle(
                color: theme.accentColor,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainControls(OfflineAsmrPlayerViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlButton(
          Icons.skip_previous_rounded,
          viewModel.previousTrack,
          size: 34,
        ),
        _buildControlButton(
          Icons.fast_rewind,
          viewModel.skipBackward,
          size: 40,
        ),
        _buildPlayPauseButton(viewModel),
        _buildControlButton(
          Icons.fast_forward,
          viewModel.skipForward,
          size: 40,
        ),
        _buildControlButton(
          Icons.skip_next_rounded,
          viewModel.nextTrack,
          size: 34,
        ),
      ],
    );
  }

  Widget _buildPlayPauseButton(OfflineAsmrPlayerViewModel viewModel) {
    return ScaleTransition(
      scale: _scaleController,
      child: GestureDetector(
        onTap: () {
          _scaleController.reverse().then((_) => _scaleController.forward());
          viewModel.togglePlayPause();
        },
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: theme.playButtonGradient,
            boxShadow: theme.playButtonShadowEffect,
          ),
          child: Icon(
            viewModel.isPlaying
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded,
            color: theme.primaryDark,
            size: 34,
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton(
      IconData icon,
      VoidCallback onPressed, {
        required double size,
      }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: theme.sideButtonGradient,
          border: Border.all(
            color: theme.sideButtonBorder,
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          color: theme.controlButtonIcon.withOpacity(0.5),
          size: size * 0.48,
        ),
      ),
    );
  }

  Widget _buildAdditionalControls(OfflineAsmrPlayerViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildIconButton(
          icon: viewModel.loopMode == LoopMode.one
              ? Icons.repeat_one_rounded
              : Icons.repeat_rounded,
          isActive: viewModel.loopMode != LoopMode.off,
          onTap: viewModel.toggleLoop,
        ),
        _buildIconButton(
          icon: Icons.timer_outlined,
          isActive: viewModel.isSleepTimerActive,
          onTap: () => _openSleepTimer(viewModel),
        ),
        _buildIconButton(
          icon: Icons.shuffle_rounded,
          isActive: viewModel.isShuffle,
          onTap: viewModel.toggleShuffle,
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? theme.accentMinimal : AppTheme.transparentColor,
        ),
        child: Icon(
          icon,
          color: isActive
              ? theme.accentColor
              : theme.controlButtonIcon.withOpacity(0.3),
          size: 22,
        ),
      ),
    );
  }

  Future<void> _openSleepTimer(OfflineAsmrPlayerViewModel viewModel) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            SleepTimerScreen(
              isTimerActive: viewModel.isSleepTimerActive,
              currentDuration: viewModel.sleepTimerDuration,
              remainingTime: viewModel.sleepTimerRemaining,
              currentEndOfTrack: viewModel.sleepTimerEndOfTrack,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween =
          Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
        reverseTransitionDuration: const Duration(milliseconds: 600),
      ),
    );

    if (result != null && mounted) {
      final action = result['action'] as String?;
      if (action == 'stop') {
        viewModel.stopSleepTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Таймер сна остановлен'),
            duration: const Duration(seconds: 2),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
          ),
        );
      } else if (action == 'start') {
        final duration = result['duration'] as Duration?;
        final endOfTrack = result['endOfTrack'] as bool? ?? false;
        if (duration != null) {
          viewModel.startSleepTimer(
            duration: duration,
            endOfTrack: endOfTrack,
            onComplete: () {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Таймер сна завершён'),
                    backgroundColor: theme.accentColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(
                      bottom: 16,
                      left: 16,
                      right: 16,
                    ),
                  ),
                );
              }
            },
          );

          final hours = duration.inHours;
          final minutes = duration.inMinutes % 60;
          final seconds = duration.inSeconds % 60;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                endOfTrack
                    ? 'Таймер: ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} (до конца трека)'
                    : 'Таймер: ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
              ),
              duration: const Duration(seconds: 2),
              backgroundColor: theme.accentColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
            ),
          );
        }
      }
    }
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;

  CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = LinearGradient(
          colors: [progressColor, progressColor.withOpacity(0.7)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * 3.14159 * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        0,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
