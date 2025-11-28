import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:animated_background/animated_background.dart';
import 'package:provider/provider.dart';
import '../models/asmr_track.dart';
import '../viewmodels/asmr_player_viewmodel.dart';
import '../services/download_queue_service.dart';
import '../theme/app_theme.dart';

class AsmrPlayerScreen extends StatefulWidget {
  final AsmrTrack track;

  const AsmrPlayerScreen({super.key, required this.track});

  @override
  State<AsmrPlayerScreen> createState() => _AsmrPlayerScreenState();
}

class _AsmrPlayerScreenState extends State<AsmrPlayerScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AsmrPlayerViewModel(
        widget.track,
        Provider.of<DownloadQueueManager>(context, listen: false),
      ),
      child: Consumer<AsmrPlayerViewModel>(
        builder: (context, viewModel, _) {
          return WillPopScope(
            onWillPop: () async {
              viewModel.pausePlayer();
              return true;
            },
            child: Scaffold(
              backgroundColor: theme.primaryDark,
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
                            child: Column(
                              children: [
                                Expanded(
                                  child: Center(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          _buildPlayer(viewModel),
                                          const SizedBox(height: 30),
                                          _buildTrackInfo(viewModel),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
                                  child: _buildDownloadButton(viewModel),
                                ),
                              ],
                            ),
                          ),
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

  Widget _buildAppBar(AsmrPlayerViewModel viewModel) {
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
                        viewModel.pausePlayer();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                Text(
                  'Воспроизведение',
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

  Widget _buildPlayer(AsmrPlayerViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.accentSubtle,
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: YoutubePlayer(
            controller: viewModel.controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: theme.accentColor,
            onReady: () => viewModel.setPlayerReady(),
            bottomActions: [
              CurrentPosition(),
              ProgressBar(
                isExpanded: true,
                colors: ProgressBarColors(
                  playedColor: theme.accentColor,
                  handleColor: theme.accentColor,
                ),
              ),
              RemainingDuration(),
              const PlaybackSpeedButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrackInfo(AsmrPlayerViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Text(
            viewModel.track.name,
            style: TextStyle(
              color: theme.trackTitle,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Text(
            viewModel.formatDuration(viewModel.track.duration),
            style: TextStyle(
              color: theme.accentLight,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(AsmrPlayerViewModel viewModel) {
    final task = viewModel.getTaskStatus();

    if (viewModel.isDownloaded) {
      return _GlassButton(
        onTap: null,
        gradient: LinearGradient(
          colors: [
            AppTheme.successColor.withOpacity(0.25),
            AppTheme.successColor.withOpacity(0.15),
          ],
        ),
        borderColor: AppTheme.successColor.withOpacity(0.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppTheme.successColor,
                    size: 24,
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            const Text(
              'Добавлено в библиотеку',
              style: TextStyle(
                color: AppTheme.successColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      );
    }

    if (task != null &&
        (task.status == DownloadStatus.preparing ||
            task.status == DownloadStatus.queued ||
            task.status == DownloadStatus.downloading)) {
      return _buildDownloadCard(viewModel, task);
    }

    if (viewModel.isPreparingToAdd) {
      return _GlassButton(
        onTap: null,
        isLoading: true,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hourglass_empty_rounded,
              color: theme.accentColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Подготовка...',
              style: TextStyle(
                color: theme.accentColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      );
    }

    return _GlassButton(
      onTap: () async {
        final hasInfo = await viewModel.startDownload();
        if (!hasInfo) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Нет подключения к интернету'),
                backgroundColor: AppTheme.errorColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
              ),
            );
          }
          return;
        }

        final info = await viewModel.getAudioInfo();
        if (!mounted) return;

        final shouldDownload = await _showDownloadConfirmation(viewModel, info);
        if (!mounted) return;

        if (shouldDownload) {
          final added = await viewModel.addToQueue();
          if (!added && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Трек уже в очереди или скачан'),
                backgroundColor: theme.accentColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
              ),
            );
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${viewModel.track.name} добавлен в очередь'),
                backgroundColor: AppTheme.successColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.download_rounded,
            color: theme.accentColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            'Добавить в библиотеку',
            style: TextStyle(
              color: theme.accentColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadCard(AsmrPlayerViewModel viewModel, DownloadTask task) {
    final bool isCurrentlyDownloading = viewModel.isCurrentlyDownloading();

    String statusText;
    bool showProgress = false;
    bool showPercentage = false;

    if (isCurrentlyDownloading) {
      if (task.totalBytes > 0 && task.receivedBytes > 0) {
        statusText =
        '${viewModel.formatFileSize(task.receivedBytes)} / ${viewModel.formatFileSize(task.totalBytes)}';
        showProgress = true;
        showPercentage = true;
      } else if (task.receivedBytes > 0) {
        statusText = '${viewModel.formatFileSize(task.receivedBytes)} скачано...';
        showProgress = false;
        showPercentage = false;
      } else {
        statusText = 'Подготовка...';
        showProgress = false;
        showPercentage = false;
      }
    } else if (task.status == DownloadStatus.queued) {
      final index = viewModel.getQueue().indexOf(task);
      final queuePosition = index >= 0 ? index + 1 : 0;
      statusText = '№$queuePosition в очереди';
      showProgress = false;
      showPercentage = false;
    } else if (task.status == DownloadStatus.preparing) {
      statusText = 'Подготовка...';
      showProgress = false;
      showPercentage = false;
    } else {
      statusText = 'Загрузка...';
      showProgress = false;
      showPercentage = false;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.accentVerySubtle,
                theme.accentMinimal,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.accentSubtle,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Скачивание...',
                    style: TextStyle(
                      color: theme.trackTitle,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (showPercentage && task.progress > 0)
                    Text(
                      '${(task.progress * 100).toInt()}%',
                      style: TextStyle(
                        color: theme.accentColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Stack(
                children: [
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: theme.accentVerySubtle,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  if (showProgress && task.progress > 0)
                    FractionallySizedBox(
                      widthFactor: task.progress.clamp(0.0, 1.0),
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.accentColor,
                              theme.accentLight,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              color: theme.accentMedium,
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: theme.whiteSubtle,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      viewModel.cancelDownload();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Скачивание отменено'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: theme.accentColor,
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
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.errorColor.withOpacity(0.3),
                            AppTheme.errorColor.withOpacity(0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.errorColor.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      child: const Text(
                        'Отменить',
                        style: TextStyle(
                          color: AppTheme.errorColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showDownloadConfirmation(
      AsmrPlayerViewModel viewModel,
      Map<String, dynamic>? info,
      ) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Dialog(
          backgroundColor: AppTheme.transparentColor,
          child: _GlassDialog(
            viewModel: viewModel,
            info: info,
          ),
        ),
      ),
    ) ??
        false;
  }
}

class _GlassButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;
  final Gradient? gradient;
  final Color? borderColor;
  final bool isLoading;

  const _GlassButton({
    required this.onTap,
    required this.child,
    this.gradient,
    this.borderColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder(
        tween: Tween(begin: 1.0, end: onTap == null ? 0.7 : 1.0),
        duration: const Duration(milliseconds: 200),
        builder: (context, opacity, _) {
          return Opacity(
            opacity: opacity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: gradient ??
                        LinearGradient(
                          colors: [
                            theme.accentSubtle,
                            theme.accentVerySubtle,
                          ],
                        ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: borderColor ?? theme.accentMedium,
                      width: 1.5,
                    ),
                  ),
                  child: child,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GlassDialog extends StatelessWidget {
  final AsmrPlayerViewModel viewModel;
  final Map<String, dynamic>? info;

  const _GlassDialog({
    required this.viewModel,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.secondaryDark.withOpacity(0.95),
                theme.secondaryDark.withOpacity(0.85),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.accentSubtle,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.accentSubtle,
                          theme.accentMinimal,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.download_rounded,
                      color: theme.accentColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Скачать в библиотеку?',
                      style: TextStyle(
                        color: theme.accentColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      viewModel.track.name,
                      style: const TextStyle(
                        color: AppTheme.whiteColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      Icons.timer_outlined,
                      'Длительность',
                      viewModel.formatDuration(viewModel.track.duration),
                      0.7,
                    ),
                    if (info != null) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.video_file_outlined,
                        'Видео',
                        viewModel.formatFileSize(info!['videoSize'] ?? 0),
                        0.5,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.audio_file_outlined,
                        'Аудио',
                        viewModel.formatFileSize(
                          ((info!['audioSize'] ?? info!['size'] ?? 0) / 1.5).round(),
                        ),
                        0.8,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.whiteColor.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          'Отмена',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: theme.whiteLight,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.accentColor,
                              const Color(0xFFA08860),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: theme.accentMedium,
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Text(
                          'Скачать',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: theme.primaryDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      IconData icon,
      String label,
      String value,
      double iconOpacity,
      ) {
    return Row(
      children: [
        Icon(
          icon,
          color: theme.accentColor.withOpacity(iconOpacity),
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            color: theme.whiteSubtle,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: theme.accentColor.withOpacity(iconOpacity + 0.2),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
