import 'package:flutter/material.dart';
import 'package:animated_background/animated_background.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:marquee/marquee.dart';
import '../models/saved_audio.dart';
import '../viewmodels/library_viewmodel.dart';
import '../theme/app_theme.dart';
import '../views/asmr_offline_player_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LibraryViewModel(),
      child: Consumer<LibraryViewModel>(
        builder: (context, viewModel, _) {
          _tabController.index = viewModel.currentTab;

          if (!_tabController.hasListeners) {
            _tabController.addListener(() {
              if (_tabController.indexIsChanging) {
                viewModel.setCurrentTab(_tabController.index);
              }
            });
          }

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
                        _buildAppBar(),
                        const SizedBox(height: 20),
                        _buildTabs(viewModel),
                        const SizedBox(height: 15),
                        _buildStorageInfo(viewModel),
                        const SizedBox(height: 15),
                        Expanded(
                          child: viewModel.isLoading
                              ? Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(
                                theme.accentColor,
                              ),
                            ),
                          )
                              : viewModel.currentTab == 0
                              ? (viewModel.asmrAudios.isEmpty
                              ? _buildEmptyState()
                              : _buildAudioList(
                              viewModel, viewModel.asmrAudios))
                              : (viewModel.favoriteAudios.isEmpty
                              ? _buildEmptyFavoritesState()
                              : _buildAudioList(
                              viewModel, viewModel.favoriteAudios)),
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
                  'БИБЛИОТЕКА',
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

  Widget _buildTabs(LibraryViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: theme.secondaryDarkVerySubtle,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.accentSubtle,
                width: 1.5,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.accentSubtle,
                    theme.accentVerySubtle,
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: theme.accentColor,
              unselectedLabelColor: theme.accentMedium,
              labelStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              dividerColor: AppTheme.transparentColor,
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.library_music, size: 18),
                      SizedBox(width: 6),
                      Text('АСМР'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite, size: 18),
                      SizedBox(width: 6),
                      Text('Избранное'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStorageInfo(LibraryViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.secondaryDarkMedium,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.accentSubtle,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.storage,
                      color: theme.accentLight,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      viewModel.formatFileSize(viewModel.currentSize),
                      style: TextStyle(
                        color: theme.accentLight,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      viewModel.currentTab == 1
                          ? Icons.favorite
                          : Icons.music_note,
                      color: viewModel.currentTab == 1
                          ? Colors.red.withOpacity(0.7)
                          : theme.accentLight,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${viewModel.currentCount} ${viewModel.currentLabel}',
                      style: TextStyle(
                        color: theme.whiteLight,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_off,
            size: 80,
            color: theme.accentSubtle,
          ),
          const SizedBox(height: 20),
          Text(
            'Библиотека пуста',
            style: TextStyle(
              color: theme.whiteSubtle,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Скачайте АСМР треки для прослушивания офлайн',
            style: TextStyle(
              color: theme.whiteMinimal,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFavoritesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_outlined,
            size: 80,
            color: theme.accentSubtle,
          ),
          const SizedBox(height: 20),
          Text(
            'Нет избранных треков',
            style: TextStyle(
              color: theme.whiteSubtle,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Добавьте треки в избранное, нажав ♥ в плеере',
            style: TextStyle(
              color: theme.whiteMinimal,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAudioList(LibraryViewModel viewModel, List<SavedAudio> audios) {
    return Theme(
      data: Theme.of(context).copyWith(
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: MaterialStateProperty.all(theme.accentMedium),
          trackColor: MaterialStateProperty.all(theme.accentMinimal),
          trackBorderColor:
          MaterialStateProperty.all(AppTheme.transparentColor),
          radius: const Radius.circular(3),
          thickness: MaterialStateProperty.all(6),
        ),
      ),
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 20,
          ),
          itemCount: audios.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildAudioCard(viewModel, audios[index], audios),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAudioCard(
      LibraryViewModel viewModel,
      SavedAudio audio,
      List<SavedAudio> playlist,
      ) {
    return GestureDetector(
      onTap: () => _openPlayer(viewModel, audio, playlist),
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
                color: theme.accentSubtle,
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    audio.isFavorite
                        ? Icons.favorite
                        : Icons.music_note_rounded,
                    color: audio.isFavorite ? Colors.red : theme.accentLight,
                    size: 24,
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
                                  text: audio.name,
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
                                  text: audio.name,
                                  style: TextStyle(
                                    color: theme.trackTitle,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                  ),
                                  scrollAxis: Axis.horizontal,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  blankSpace: 40.0,
                                  velocity: 30.0,
                                  pauseAfterRound: const Duration(seconds: 2),
                                  startPadding: 0.0,
                                  accelerationDuration:
                                  const Duration(seconds: 1),
                                  accelerationCurve: Curves.linear,
                                  decelerationDuration:
                                  const Duration(milliseconds: 500),
                                  decelerationCurve: Curves.easeOut,
                                );
                              } else {
                                return Text(
                                  audio.name,
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
                              viewModel.formatDuration(audio.duration),
                              style: TextStyle(
                                color: theme.trackDuration,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                              ),
                            ),
                            Text(
                              ' • ${viewModel.formatFileSize(audio.fileSize)}',
                              style: TextStyle(
                                color: theme.whiteVerySubtle,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.accentVerySubtle,
                      border: Border.all(
                        color: theme.accentColor,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: theme.accentColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.errorColor.withOpacity(0.2),
                      border: Border.all(
                        color: AppTheme.errorColor,
                        width: 1.5,
                      ),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppTheme.errorColor,
                        size: 20,
                      ),
                      onPressed: () => _showDeleteConfirmation(viewModel, audio),
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

  void _openPlayer(
      LibraryViewModel viewModel,
      SavedAudio audio,
      List<SavedAudio> playlist,
      ) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (context, animation, secondaryAnimation) =>
            OfflineAsmrPlayerScreen(
              audio: audio,
              playlist: playlist,
            ),
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
    ).then((_) {
      viewModel.loadLibrary();
    });
  }

  Future<void> _showDeleteConfirmation(
      LibraryViewModel viewModel,
      SavedAudio audio,
      ) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Dialog(
          backgroundColor: AppTheme.transparentColor,
          child: _DeleteDialog(audio: audio, viewModel: viewModel),
        ),
      ),
    );

    if (confirm == true && mounted) {
      final success = await viewModel.deleteAudio(audio);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Аудио удалено'),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
          ),
        );
      }
    }
  }
}

class _DeleteDialog extends StatelessWidget {
  final SavedAudio audio;
  final LibraryViewModel viewModel;

  const _DeleteDialog({
    required this.audio,
    required this.viewModel,
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
                      color: AppTheme.errorColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: AppTheme.errorColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Удалить аудио?',
                      style: TextStyle(
                        color: AppTheme.errorColor,
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
                      audio.name,
                      style: TextStyle(
                        color: theme.trackTitle,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.storage,
                          color: theme.accentLight,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          viewModel.formatFileSize(audio.fileSize),
                          style: TextStyle(
                            color: theme.accentLight,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, false),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.secondaryDarkSubtle,
                                  theme.secondaryDarkVerySubtle,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.accentVerySubtle,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              'Отмена',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: theme.whiteSubtle,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, true),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
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
                            child: const Text(
                              'Удалить',
                              textAlign: TextAlign.center,
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
            ],
          ),
        ),
      ),
    );
  }
}
