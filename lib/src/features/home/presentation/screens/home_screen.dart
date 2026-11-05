import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seeker/src/core/consts/colors/app_colors.dart';
import 'package:seeker/src/features/home/model/place.dart';
import 'package:seeker/src/features/home/presentation/widgets/category_cards.dart';
import 'package:seeker/src/features/home/presentation/widgets/home_atmosphere.dart';
import 'package:seeker/src/features/home/presentation/widgets/home_category_chips.dart';
import 'package:seeker/src/features/home/presentation/widgets/home_headline.dart';
import 'package:seeker/src/features/home/presentation/widgets/home_search_bar.dart';
import 'package:seeker/src/features/home/presentation/widgets/home_top_bar.dart';
import 'package:seeker/src/features/home/presentation/widgets/page_dots.dart';
import 'package:seeker/src/features/home/presentation/widgets/place_carousel.dart';
import 'package:seeker/src/features/home/presentation/widgets/place_row.dart';
import 'package:seeker/src/features/home/presentation/widgets/reveal.dart';
import 'package:seeker/src/features/home/presentation/widgets/section_title.dart';
import 'package:seeker/src/features/home/presentation/widgets/trending_header.dart';

class HomeScreen extends StatefulWidget {
  final String userName;

  /// Места для показа (приходят из Strapi через HomeLoader)
  final List<Place> places;

  const HomeScreen({
    super.key,
    this.userName = 'Traveler',
    this.places = kPlaces,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scroll = ScrollController();
  final TextEditingController _search = TextEditingController();
  final ValueNotifier<int> _hint = ValueNotifier(0);
  PageController _pc = PageController(viewportFraction: 0.74);
  Timer? _hintTimer;

  String _category = 'All';

  List<String> get _hints => widget.places.isEmpty
      ? const ['a place']
      : widget.places.take(4).map((p) => p.name).toList();

  /// Категории берутся из самих данных (поле Category в Strapi)
  List<String> get _categoryNames {
    final set = <String>{};
    for (final p in widget.places) {
      if (p.category.trim().isNotEmpty) set.add(p.category.trim());
    }
    return ['All', ...set];
  }

  @override
  void initState() {
    super.initState();
    _hintTimer = Timer.periodic(const Duration(milliseconds: 2600), (_) {
      _hint.value = (_hint.value + 1) % _hints.length;
    });
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _hint.dispose();
    _scroll.dispose();
    _search.dispose();
    _pc.dispose();
    super.dispose();
  }

  void _pickCategory(String name) {
    if (name == _category) return;
    HapticFeedback.selectionClick();
    final old = _pc;
    setState(() {
      _category = name;
      _pc = PageController(viewportFraction: 0.74);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final cats = _categoryNames;

    final trending = widget.places
        .where((p) => _category == 'All' || p.category.trim() == _category)
        .toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.cream,
        body: Stack(
          children: [
            HomeAtmosphere(scroll: _scroll),
            SingleChildScrollView(
              controller: _scroll,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(bottom: 130 + mq.padding.bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: mq.padding.top + 14),
                  HomeTopBar(userName: widget.userName),
                  const SizedBox(height: 26),
                  const HomeHeadline(),
                  const SizedBox(height: 22),
                  HomeSearchBar(
                    controller: _search,
                    hint: _hint,
                    hints: _hints,
                  ),
                  const SizedBox(height: 26),
                  if (cats.length > 1) ...[
                    HomeCategoryChips(
                      categories: cats,
                      selected: _category,
                      onSelect: _pickCategory,
                    ),
                    const SizedBox(height: 26),
                  ],
                  TrendingHeader(count: trending.length, controller: _pc),
                  const SizedBox(height: 16),
                  if (trending.isEmpty)
                    _empty()
                  else ...[
                    PlaceCarousel(
                      places: trending,
                      controller: _pc,
                      category: _category,
                    ),
                    const SizedBox(height: 14),
                    PageDots(count: trending.length, controller: _pc),
                  ],
                  if (cats.length > 1) ...[
                    const SizedBox(height: 36),
                    Reveal(
                      controller: _scroll,
                      child: const SectionTitle(
                        title: 'Explore by category',
                        subtitle: 'Pick what you like',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Reveal(
                      controller: _scroll,
                      child: CategoryCards(
                        categories: cats,
                        allPlaces: widget.places,
                        scroll: _scroll,
                        onSelect: _pickCategory,
                      ),
                    ),
                  ],
                  const SizedBox(height: 30),
                  Reveal(
                    controller: _scroll,
                    child: SectionTitle(
                      title: 'All places',
                      subtitle: '${widget.places.length} places to discover',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        for (int i = 0; i < widget.places.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Reveal(
                              controller: _scroll,
                              delay: Duration(milliseconds: 90 * (i % 4)),
                              child: PlaceRow(place: widget.places[i]),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Center(
        child: Text(
          'No places yet',
          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
