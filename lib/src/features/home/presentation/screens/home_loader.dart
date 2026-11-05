import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seeker/src/core/consts/colors/app_colors.dart';
import 'package:seeker/src/features/home/presentation/bloc/places_bloc.dart';
import 'package:seeker/src/features/home/presentation/bloc/places_event.dart';
import 'package:seeker/src/features/home/presentation/bloc/places_state.dart';
import 'package:seeker/src/features/home/presentation/screens/home_screen.dart';

/// Загружает список мест через [PlacesBloc] и отдаёт его в [HomeScreen].
class HomeLoader extends StatefulWidget {
  const HomeLoader({super.key});

  @override
  State<HomeLoader> createState() => _HomeLoaderState();
}

class _HomeLoaderState extends State<HomeLoader> {
  @override
  void initState() {
    super.initState();
    // Запрос инициируется при появлении экрана (как и раньше — только после входа).
    context.read<PlacesBloc>().add(const PlacesRequested());
  }

  void _retry() => context.read<PlacesBloc>().add(const PlacesRequested());

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlacesBloc, PlacesState>(
      builder: (context, state) {
        return switch (state) {
          PlacesInitial() || PlacesLoading() => const ColoredBox(
            color: AppColors.cream,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
          PlacesFailure(:final message) => _error(message),
          PlacesLoaded(:final places) => HomeScreen(places: places),
        };
      },
    );
  }

  Widget _error(String message) {
    return ColoredBox(
      color: AppColors.cream,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 56,
                color: AppColors.textHint,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _retry,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
