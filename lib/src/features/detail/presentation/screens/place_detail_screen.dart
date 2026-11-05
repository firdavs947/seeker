import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:seeker/src/core/consts/colors/app_colors.dart';
import 'package:seeker/src/core/router/app_router.dart';
import 'package:seeker/src/features/detail/presentation/widgets/gallery_dots.dart';
import 'package:seeker/src/features/detail/presentation/widgets/map_button.dart';
import 'package:seeker/src/features/detail/presentation/widgets/place_info_sheet.dart';
import 'package:seeker/src/features/detail/presentation/widgets/round_icon_button.dart';
import 'package:seeker/src/features/home/model/place.dart';
import 'package:seeker/src/features/home/presentation/widgets/place_image.dart';
import 'package:seeker/src/features/saved/presentation/widgets/save_button.dart';
import 'package:url_launcher/url_launcher.dart';

/// Открывает детали места через go_router.
///
/// [place] — обязательный аргумент (передаётся через `extra`),
/// [heroTag] — необязательный, для анимации Hero при переходе.
void openPlaceDetails(BuildContext context, Place place, {String? heroTag}) {
  context.pushNamed(
    AppRouteNames.place,
    pathParameters: {'id': place.id},
    queryParameters: {'hero': ?heroTag},
    extra: PlaceDetailsArgs(place: place, heroTag: heroTag),
  );
}

class PlaceDetailsScreen extends StatefulWidget {
  final Place place;

  /// Если не задан, используется `place_<id>` (переход с Home).
  final String? heroTag;

  const PlaceDetailsScreen({super.key, required this.place, this.heroTag});

  @override
  State<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  static const double _minExtent = 0.58;
  static const double _maxExtent = 0.92;

  final ValueNotifier<double> _extent = ValueNotifier(_minExtent);
  final ValueNotifier<int> _page = ValueNotifier(0);
  final PageController _pageCtrl = PageController();

  Place get _place => widget.place;
  int get _count => _place.images.isEmpty ? 1 : _place.images.length;
  bool get _hasMap => _place.locationLink.trim().isNotEmpty;
  String get _tag => widget.heroTag ?? 'place_${_place.id}';

  @override
  void dispose() {
    _extent.dispose();
    _page.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _selectImage(int index) => _pageCtrl.animateToPage(
    index,
    duration: const Duration(milliseconds: 450),
    curve: Curves.easeOutCubic,
  );

  Future<void> _openMap() async {
    var link = _place.locationLink.trim();
    if (!link.startsWith('http')) link = 'https://$link';

    var ok = false;
    try {
      ok = await launchUrl(
        Uri.parse(link),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {}

    if (!ok && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: const Text(
              'Could not open the map',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final h = mq.size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Галерея растёт вместе с подъёмом листа.
            ValueListenableBuilder<double>(
              valueListenable: _extent,
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: _count,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (i) => _page.value = i,
                itemBuilder: (_, i) => i == 0
                    ? Hero(
                        tag: _tag,
                        child: PlaceImage(place: _place, index: 0),
                      )
                    : PlaceImage(place: _place, index: i),
              ),
              builder: (_, extent, child) {
                final t = ((extent - _minExtent) / (_maxExtent - _minExtent))
                    .clamp(0.0, 1.0);
                return Positioned(
                  top: -t * h * 0.06,
                  left: 0,
                  right: 0,
                  height: h * 0.56,
                  child: Transform.scale(scale: 1 + t * 0.12, child: child),
                );
              },
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 130,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withAlpha(90), Colors.transparent],
                    ),
                  ),
                ),
              ),
            ),
            if (_count > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: h * _minExtent + 16,
                child: IgnorePointer(
                  child: GalleryDots(page: _page, count: _count),
                ),
              ),
            Positioned.fill(
              child: NotificationListener<DraggableScrollableNotification>(
                onNotification: (n) {
                  _extent.value = n.extent;
                  return false;
                },
                child: DraggableScrollableSheet(
                  initialChildSize: _minExtent,
                  minChildSize: _minExtent,
                  maxChildSize: _maxExtent,
                  snap: true,
                  builder: (context, controller) => PlaceInfoSheet(
                    place: _place,
                    controller: controller,
                    bottomInset: mq.padding.bottom,
                    hasMap: _hasMap,
                    page: _page,
                    onSelectImage: _selectImage,
                  ),
                ),
              ),
            ),
            Positioned(
              top: mq.padding.top + 12,
              left: 20,
              child:
                  RoundIconButton(
                        onTap: () => context.pop(),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: AppColors.textPrimary,
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 350.ms)
                      .scale(
                        begin: const Offset(0.5, 0.5),
                        curve: Curves.easeOutBack,
                      ),
            ),
            Positioned(
              top: mq.padding.top + 12,
              right: 20,
              child: SaveButton(place: _place, glass: false)
                  .animate()
                  .fadeIn(delay: 450.ms)
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    curve: Curves.easeOutBack,
                  ),
            ),
            if (_hasMap)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child:
                    Container(
                          padding: EdgeInsets.fromLTRB(
                            24,
                            36,
                            24,
                            16 + mq.padding.bottom,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.white.withAlpha(0), Colors.white],
                              stops: const [0, 0.45],
                            ),
                          ),
                          child: MapButton(onTap: _openMap),
                        )
                        .animate()
                        .slideY(
                          begin: 1,
                          end: 0,
                          delay: 500.ms,
                          duration: 700.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .fadeIn(delay: 500.ms),
              ),
          ],
        ),
      ),
    );
  }
}
