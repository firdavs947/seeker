import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seeker/src/core/consts/colors/app_colors.dart';
import 'package:seeker/src/features/home/model/place.dart';
import 'package:seeker/src/features/saved/presentation/bloc/saved_bloc.dart';
import 'package:seeker/src/features/saved/presentation/bloc/saved_event.dart';
import 'package:seeker/src/features/saved/presentation/bloc/saved_state.dart';
import 'package:seeker/src/features/saved/presentation/widgets/clear_saved_dialog.dart';
import 'package:seeker/src/features/saved/presentation/widgets/saved_empty_state.dart';
import 'package:seeker/src/features/saved/presentation/widgets/saved_header.dart';
import 'package:seeker/src/features/saved/presentation/widgets/saved_place_card.dart';

class SavedScreen extends StatefulWidget {
  /// Нажатие «Explore places» в пустом состоянии (переключить на Home)
  final VoidCallback? onExplore;

  const SavedScreen({super.key, this.onExplore});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _removeWithUndo(Place p) {
    context.read<SavedBloc>().add(SavedRemoveRequested(p.id));

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.ink,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 120),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Text(
            'saved.removed'.tr(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          action: SnackBarAction(
            label: 'saved.undo'.tr(),
            textColor: AppColors.accent,
            onPressed: () =>
                context.read<SavedBloc>().add(SavedRestoreRequested(p)),
          ),
        ),
      );
  }

  Future<void> _confirmClear() async {
    final bloc = context.read<SavedBloc>();
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withAlpha(110),
      builder: (_) => const ClearSavedDialog(),
    );
    if (ok == true) {
      HapticFeedback.mediumImpact();
      bloc.add(const SavedClearRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Подписка на смену языка
    // ignore: unnecessary_statements
    context.locale;

    final mq = MediaQuery.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.cream,
        body: Stack(
          children: [
            Positioned(
              right: -130,
              top: -110,
              child: _glow(AppColors.coral, 360),
            ),
            Positioned(
              left: -150,
              top: 230,
              child: _glow(AppColors.secondaryLight, 340),
            ),
            BlocBuilder<SavedBloc, SavedState>(
              builder: (context, state) {
                final places = state.places;

                return CustomScrollView(
                  controller: _scroll,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: SavedHeader(
                        count: places.length,
                        topInset: mq.padding.top,
                        onClear: _confirmClear,
                      ),
                    ),
                    if (places.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: SavedEmptyState(
                          bottomInset: mq.padding.bottom,
                          onExplore: widget.onExplore,
                        ),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          24,
                          6,
                          24,
                          120 + mq.padding.bottom,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((context, i) {
                            final p = places[i];
                            return Dismissible(
                              key: ValueKey(p.id),
                              direction: DismissDirection.endToStart,
                              background: const SavedDismissBackground(),
                              onDismissed: (_) => _removeWithUndo(p),
                              child:
                                  SavedPlaceCard(
                                        place: p,
                                        onRemoved: () => _removeWithUndo(p),
                                      )
                                      .animate()
                                      .fadeIn(
                                        delay: ((i < 6 ? i : 6) * 70).ms,
                                        duration: 450.ms,
                                      )
                                      .slideY(
                                        begin: 0.15,
                                        end: 0,
                                        curve: Curves.easeOutCubic,
                                      ),
                            );
                          }, childCount: places.length),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _glow(Color c, double size) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [c.withAlpha(64), c.withAlpha(0)]),
        ),
      ),
    );
  }
}
