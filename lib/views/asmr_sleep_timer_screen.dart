import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/asmr_sleep_timer_viewmodel.dart';
import '../theme/app_theme.dart';

class SleepTimerScreen extends StatefulWidget {
  final bool isTimerActive;
  final Duration? currentDuration;
  final Duration? remainingTime;
  final bool currentEndOfTrack;

  const SleepTimerScreen({
    super.key,
    this.isTimerActive = false,
    this.currentDuration,
    this.remainingTime,
    this.currentEndOfTrack = false,
  });

  @override
  State<SleepTimerScreen> createState() => _SleepTimerScreenState();
}

class _SleepTimerScreenState extends State<SleepTimerScreen>
    with TickerProviderStateMixin {
  final FixedExtentScrollController _hourController =
  FixedExtentScrollController();
  final FixedExtentScrollController _minuteController =
  FixedExtentScrollController();
  final FixedExtentScrollController _secondController =
  FixedExtentScrollController();

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    _secondController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SleepTimerViewModel(
        isTimerActive: widget.isTimerActive,
        currentDuration: widget.currentDuration,
        remainingTime: widget.remainingTime,
        currentEndOfTrack: widget.currentEndOfTrack,
      ),
      child: Consumer<SleepTimerViewModel>(
        builder: (context, viewModel, _) {
          // Синхронизация контроллеров с ViewModel
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_hourController.hasClients && !viewModel.isRunning) {
              _hourController.jumpToItem(viewModel.selectedHours);
            }
            if (_minuteController.hasClients && !viewModel.isRunning) {
              _minuteController.jumpToItem(viewModel.selectedMinutes);
            }
            if (_secondController.hasClients && !viewModel.isRunning) {
              _secondController.jumpToItem(viewModel.selectedSeconds);
            }
          });

          return Scaffold(
            backgroundColor: theme.primaryDark,
            body: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: Column(
                      children: [
                        const SizedBox(height: 32),
                        _buildEndOfTrackToggle(viewModel),
                        const Spacer(),
                        _buildCircularTimerWithPicker(viewModel),
                        const Spacer(),
                        _buildActionButton(viewModel),
                        const SizedBox(height: 32),
                      ],
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

  Widget _buildAppBar() {
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
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                Text(
                  'Таймер сна',
                  style: TextStyle(
                    color: theme.accentColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
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

  Widget _buildEndOfTrackToggle(SleepTimerViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: theme.controlCardGradient,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.whiteColor.withOpacity(0.08),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Завершение при достижении конца трека',
                    style: TextStyle(
                      color: viewModel.endOfTrackMode
                          ? theme.controlButtonIcon
                          : theme.controlButtonIcon.withOpacity(0.6),
                      fontSize: 14,
                      fontWeight: viewModel.endOfTrackMode
                          ? FontWeight.w600
                          : FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Transform.scale(
                  scale: 0.9,
                  child: Switch(
                    value: viewModel.endOfTrackMode,
                    onChanged: viewModel.isRunning
                        ? null
                        : (_) => viewModel.toggleEndOfTrackMode(),
                    activeColor: theme.accentColor,
                    inactiveThumbColor: theme.accentVerySubtle,
                    inactiveTrackColor:
                    theme.controlButtonIcon.withOpacity(0.4),
                    trackOutlineColor: MaterialStateProperty.resolveWith(
                          (Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)) {
                          return null;
                        }
                        return theme.controlButtonIcon.withOpacity(0.4);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircularTimerWithPicker(SleepTimerViewModel viewModel) {
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 300,
            height: 300,
            child: TweenAnimationBuilder(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              tween: Tween(begin: viewModel.progress, end: viewModel.progress),
              builder: (context, value, child) {
                return Transform.rotate(
                  angle: -1.5708,
                  child: CustomPaint(
                    painter: CircularProgressPainter(
                      progress: value,
                      strokeWidth: 5.0,
                      backgroundColor: theme.secondaryDarkSubtle,
                      progressColor: theme.accentColor,
                    ),
                  ),
                );
              },
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(140),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: theme.controlCardGradient,
                  border: Border.all(
                    color: AppTheme.whiteColor.withOpacity(0.08),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: viewModel.isRunning
                      ? _buildCountdownDisplay(viewModel)
                      : _buildTimePickers(viewModel),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickers(SleepTimerViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTimePickerWheel(
          _hourController,
          24,
          viewModel.selectedHours,
          viewModel.onHourSelected,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            ':',
            style: TextStyle(
              color: theme.accentColor,
              fontSize: 36,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        _buildTimePickerWheel(
          _minuteController,
          60,
          viewModel.selectedMinutes,
          viewModel.onMinuteSelected,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            ':',
            style: TextStyle(
              color: theme.accentColor,
              fontSize: 36,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        _buildTimePickerWheel(
          _secondController,
          60,
          viewModel.selectedSeconds,
          viewModel.onSecondSelected,
        ),
      ],
    );
  }

  Widget _buildTimePickerWheel(
      FixedExtentScrollController controller,
      int itemCount,
      int selectedValue,
      ValueChanged<int> onSelectedItemChanged,
      ) {
    return SizedBox(
      width: 52,
      height: 110,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 36,
        physics: const FixedExtentScrollPhysics(),
        perspective: 0.003,
        diameterRatio: 1.2,
        onSelectedItemChanged: onSelectedItemChanged,
        childDelegate: ListWheelChildLoopingListDelegate(
          children: List.generate(itemCount, (index) {
            final isSelected = selectedValue == index;
            return Center(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                style: TextStyle(
                  color: theme.controlButtonIcon
                      .withOpacity(isSelected ? 1.0 : 0.3),
                  fontSize: isSelected ? 32.0 : 20.0,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  letterSpacing: 1,
                ),
                child: Text(index.toString().padLeft(2, '0')),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCountdownDisplay(SleepTimerViewModel viewModel) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (0.02 * _pulseController.value),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCountdownUnit(viewModel.selectedHours),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  ':',
                  style: TextStyle(
                    color: theme.controlButtonIcon,
                    fontSize: 40,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              _buildCountdownUnit(viewModel.selectedMinutes),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  ':',
                  style: TextStyle(
                    color: theme.controlButtonIcon,
                    fontSize: 40,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              _buildCountdownUnit(viewModel.selectedSeconds),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCountdownUnit(int value) {
    return SizedBox(
      width: 56,
      child: Center(
        child: Text(
          value.toString().padLeft(2, '0'),
          style: TextStyle(
            color: theme.controlButtonIcon,
            fontSize: 40,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(SleepTimerViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () {
          if (viewModel.isRunning) {
            Navigator.pop(context, {'action': 'stop'});
          } else {
            if (!viewModel.validateDuration()) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Установите время больше 0'),
                  backgroundColor: AppTheme.errorColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
              return;
            }
            Navigator.pop(context, {
              'action': 'start',
              'duration': viewModel.selectedDuration,
              'endOfTrack': viewModel.endOfTrackMode,
            });
          }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: viewModel.isRunning
                      ? [
                    AppTheme.errorColor.withOpacity(0.25),
                    AppTheme.errorColor.withOpacity(0.15),
                  ]
                      : [
                    theme.accentSubtle,
                    theme.accentVerySubtle,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: viewModel.isRunning
                      ? AppTheme.errorColor.withOpacity(0.4)
                      : theme.accentMedium,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    viewModel.isRunning
                        ? Icons.stop_rounded
                        : Icons.play_arrow_rounded,
                    color: viewModel.isRunning
                        ? AppTheme.errorColor
                        : theme.accentColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    viewModel.isRunning ? 'Остановить' : 'Запустить',
                    style: TextStyle(
                      color: viewModel.isRunning
                          ? AppTheme.errorColor
                          : theme.accentColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
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
          colors: [progressColor, progressColor.withOpacity(0.6)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress;
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
