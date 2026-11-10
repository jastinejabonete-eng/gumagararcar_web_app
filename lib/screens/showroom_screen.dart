import 'package:flutter/material.dart';
import '../data/cars.dart';
import '../models/car_product.dart';
import '../state/store_controller.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/shared.dart';

class ShowroomScreen extends StatelessWidget {
  const ShowroomScreen({
    super.key,
    required this.store,
    required this.onBrowse,
    required this.onOpen,
  });
  final StoreController store;
  final ValueChanged<String> onBrowse;
  final ValueChanged<CarProduct> onOpen;
  @override
  Widget build(BuildContext context) => PageBody(
    storageKey: 'showroom',
    children: [
      LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 760;
          final intro = Padding(
            padding: EdgeInsets.all(wide ? 36 : 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'FEATURED CONCEPT  /  01',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: const Color(0xFFB8D3D5),
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  cars.first.name,
                  style:
                      (wide
                              ? Theme.of(context).textTheme.displayLarge
                              : Theme.of(context).textTheme.displayMedium)
                          ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  cars.first.tagline,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFFD5E5E6),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '${cars.first.category}  ·  ${cars.first.model}  ·  ${formatPrice(cars.first.price)}',
                  style: const TextStyle(
                    color: Color(0xFFB8D3D5),
                    fontSize: 14,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  key: const ValueKey('explore_collection'),
                  onPressed: () => onOpen(cars.first),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.petrol,
                  ),
                  iconAlignment: IconAlignment.end,
                  icon: const Icon(Icons.arrow_outward, size: 19),
                  label: const Text('View concept'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => onBrowse('All'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  child: Text('Browse all ${cars.length} concepts'),
                ),
              ],
            ),
          );
          final photo = Stack(
            children: [
              CarPhoto(cars.first, aspectRatio: wide ? 1.28 : 1.75),
              Positioned(
                left: 16,
                bottom: 14,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFF10191B).withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Text(
                      'ILLUSTRATIVE REFERENCE PHOTO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
          return ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: DecoratedBox(
              decoration: const BoxDecoration(color: AppTheme.petrol),
              child: wide
                  ? Row(
                      children: [
                        Expanded(flex: 5, child: intro),
                        Expanded(flex: 6, child: photo),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [photo, intro],
                    ),
            ),
          );
        },
      ),
      const SizedBox(height: 28),
      Row(
        children: [
          Text(
            'EXPLORE BY CATEGORY',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              letterSpacing: 1.2,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          for (final category in categories.skip(1))
            TextButton(
              onPressed: () => onBrowse(category),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                foregroundColor: Theme.of(context).colorScheme.onSurface,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [Text(category)],
              ),
            ),
        ],
      ),
      const SizedBox(height: 40),
      PageHeading(
        'The collection',
        '${cars.length} concepts. Each with its own point of view.',
        action: TextButton(
          onPressed: () => onBrowse('All'),
          child: const Text('View all'),
        ),
      ),
      VehicleGrid(
        vehicles: cars.take(3).toList(),
        favorites: store.favorites,
        onSave: (car) => store.toggleFavorite(car.id),
        onOpen: onOpen,
      ),
      const SizedBox(height: 40),
      const Divider(),
      const SizedBox(height: 24),
      Text(
        'Independent concept vehicles by Group 1.',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 8),
      Text(
        'Prices are concept prices in Philippine pesos. Photography is illustrative; no real vehicles or transactions are represented.',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    ],
  );
}
