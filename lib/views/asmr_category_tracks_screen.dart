import 'package:flutter/material.dart';
import 'package:animated_background/animated_background.dart';
import 'dart:ui';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import '../models/asmr_track.dart';
import '../viewmodels/asmr_category_tracks_viewmodel.dart';
import '../theme/app_theme.dart';
import '../views/asmr_player_screen.dart';

class CategoryTracksScreen extends StatefulWidget {
  final String categoryName;
  final List<String> searchTags;
  final List<String> searchTagsRu;

  const CategoryTracksScreen({
    super.key,
    required this.categoryName,
    required this.searchTags,
    required this.searchTagsRu,
  });

  @override
  State<CategoryTracksScreen> createState() => _CategoryTracksScreenState();
}

class _CategoryTracksScreenState extends State<CategoryTracksScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CategoryTracksViewModel(
        categoryName: widget.categoryName,
        searchTags: widget.searchTags,
        searchTagsRu: widget.searchTagsRu,
      ),
      child: Consumer<CategoryTracksViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
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
                        const SizedBox(height: 20),
                        Expanded(
                          child: _buildTracksList(viewModel),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(CategoryTracksViewModel viewModel) {
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
                  widget.categoryName.toUpperCase(),
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
                      icon: viewModel.isLoading
                          ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(theme.accentColor),
                        ),
                      )
                          : Icon(
                        Icons.refresh_rounded,
                        color: theme.accentColor,
                        size: 22,
                      ),
                      onPressed: viewModel.isLoading ? null : viewModel.loadCategoryTracks,
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

  Widget _buildTracksList(CategoryTracksViewModel viewModel) {
    if (viewModel.isLoading && viewModel.tracks.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: theme.accentColor,
        ),
      );
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(
              color: AppTheme.transparentColor,
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
                  viewModel.errorMessage!,
                  style: TextStyle(
                    color: theme.whiteLight,
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: viewModel.loadCategoryTracks,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.errorColor.withOpacity(0.3),
                              AppTheme.errorColor.withOpacity(0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.errorColor.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Повторить',
                            style: TextStyle(
                              color: AppTheme.errorColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
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
      );
    }

    if (viewModel.tracks.isEmpty) {
      return Center(
        child: Text(
          'Треки не найдены',
          style: TextStyle(
            color: theme.whiteVerySubtle,
            fontSize: 14,
          ),
        ),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: MaterialStateProperty.all(theme.accentMedium),
          trackColor: MaterialStateProperty.all(theme.accentMinimal),
          trackBorderColor: MaterialStateProperty.all(AppTheme.transparentColor),
          radius: const Radius.circular(3),
          thickness: MaterialStateProperty.all(6),
        ),
      ),
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: RefreshIndicator(
          color: theme.accentColor,
          backgroundColor: theme.secondaryDark,
          onRefresh: viewModel.loadCategoryTracks,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 10,
              bottom: 20,
            ),
            itemCount: viewModel.tracks.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Text(
                    'Треки',
                    style: TextStyle(
                      color: theme.accentColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildTrackCard(viewModel, viewModel.tracks[index - 1]),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTrackCard(CategoryTracksViewModel viewModel, AsmrTrack track) {
    final isDownloaded = viewModel.downloadedTrackIds.contains(track.id);

    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).push(
          PageRouteBuilder(
            opaque: true,
            pageBuilder: (context, animation, secondaryAnimation) =>
                AsmrPlayerScreen(track: track),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final value = animation.value;
              double opacity;
              if (value <= 0.25) {
                opacity = 0.0;
              } else {
                final normalized = (value - 0.25) / 0.75;
                opacity = Curves.easeOut.transform(normalized);
              }
              return Container(
                color: theme.primaryDark,
                child: Opacity(
                  opacity: opacity,
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 1200),
          ),
        );
        viewModel.refreshDownloadStatus();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: theme.secondaryDarkMedium,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDownloaded
                    ? AppTheme.successColor.withOpacity(0.5)
                    : theme.accentSubtle,
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Icon(
                        Icons.music_note_rounded,
                        color: theme.accentLight,
                        size: 24,
                      ),
                      if (isDownloaded)
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: AppTheme.successColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.secondaryDark,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 8,
                              color: AppTheme.whiteColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final textPainter = TextPainter(
                                text: TextSpan(
                                  text: track.name,
                                  style: TextStyle(
                                    color: theme.trackTitle,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                maxLines: 1,
                                textDirection: TextDirection.ltr,
                              )..layout(maxWidth: constraints.maxWidth);

                              if (textPainter.didExceedMaxLines) {
                                return Marquee(
                                  text: track.name,
                                  style: TextStyle(
                                    color: theme.trackTitle,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                  ),
                                  scrollAxis: Axis.horizontal,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  blankSpace: 40.0,
                                  velocity: 30.0,
                                  pauseAfterRound: const Duration(seconds: 2),
                                  startPadding: 0.0,
                                  accelerationDuration: const Duration(seconds: 1),
                                  accelerationCurve: Curves.linear,
                                  decelerationDuration: const Duration(milliseconds: 500),
                                  decelerationCurve: Curves.easeOut,
                                );
                              } else {
                                return Text(
                                  track.name,
                                  style: TextStyle(
                                    color: theme.trackTitle,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              viewModel.formatDuration(track.duration),
                              style: TextStyle(
                                color: theme.trackDuration,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                              ),
                            ),
                            if (isDownloaded) ...[
                              const SizedBox(width: 6),
                              Icon(
                                Icons.offline_pin_rounded,
                                size: 14,
                                color: AppTheme.successColor.withOpacity(0.8),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDownloaded
                          ? AppTheme.successColor.withOpacity(0.2)
                          : theme.accentVerySubtle,
                      border: Border.all(
                        color: isDownloaded ? AppTheme.successColor : theme.accentColor,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      isDownloaded ? Icons.check_rounded : Icons.download_rounded,
                      color: isDownloaded ? AppTheme.successColor : theme.accentColor,
                      size: 20,
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
