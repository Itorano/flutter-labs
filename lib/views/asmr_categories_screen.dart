import 'package:flutter/material.dart';
import 'package:animated_background/animated_background.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../viewmodels/asmr_categories_viewmodel.dart';
import '../models/asmr_category.dart';
import '../theme/app_theme.dart';
import '../views/asmr_category_tracks_screen.dart';

class AsmrCategoriesScreen extends StatefulWidget {
  const AsmrCategoriesScreen({super.key});

  @override
  State<AsmrCategoriesScreen> createState() => _AsmrCategoriesScreenState();
}

class _AsmrCategoriesScreenState extends State<AsmrCategoriesScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AsmrCategoriesViewModel(),
      child: Consumer<AsmrCategoriesViewModel>(
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
                        _buildAppBar(),
                        const SizedBox(height: 20),
                        Expanded(
                          child: _buildCategoriesGrid(viewModel),
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
                  'КАТЕГОРИИ',
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

  Widget _buildCategoriesGrid(AsmrCategoriesViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableHeight = constraints.maxHeight - 20;

          const rowCount = 6;
          const spacing = 8.0;

          final totalSpacing = spacing * (rowCount - 1);
          final cardHeight = (availableHeight - totalSpacing) / rowCount;
          final cardWidth = (constraints.maxWidth - (spacing * 2)) / 3;
          final aspectRatio = cardWidth / cardHeight;

          return Center(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 20),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: aspectRatio,
              ),
              itemCount: viewModel.categories.length,
              itemBuilder: (context, index) {
                return _buildCategoryCard(viewModel.categories[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(AsmrCategory category) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            opaque: true,
            pageBuilder: (context, animation, secondaryAnimation) =>
                CategoryTracksScreen(
                  categoryName: category.name,
                  searchTags: category.searchTags,
                  searchTagsRu: category.searchTagsRu,
                ),
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
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.accentSubtle,
                  theme.accentVerySubtle,
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: theme.accentMedium,
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  category.icon,
                  color: theme.accentColor,
                  size: 28,
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Text(
                    category.name,
                    style: TextStyle(
                      color: theme.accentColor,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
