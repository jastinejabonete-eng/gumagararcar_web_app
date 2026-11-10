import 'package:flutter/material.dart';
import '../models/car_product.dart';
import '../utils/formatters.dart';

class PageBody extends StatelessWidget {
  const PageBody({
    super.key,
    required this.children,
    this.storageKey,
    this.maxWidth = 1240,
  });
  final List<Widget> children;
  final String? storageKey;
  final double maxWidth;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final gutter = constraints.maxWidth < 600 ? 20.0 : 40.0;
      return SingleChildScrollView(
        key: storageKey == null ? null : PageStorageKey(storageKey),
        padding: EdgeInsets.fromLTRB(gutter, 28, gutter, 40),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      );
    },
  );
}

class PageHeading extends StatelessWidget {
  const PageHeading(this.title, this.subtitle, {super.key, this.action});
  final String title;
  final String subtitle;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 20,
          runSpacing: 8,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineLarge),
            ?action,
          ],
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 15,
          ),
        ),
      ],
    ),
  );
}

class CarPhoto extends StatelessWidget {
  const CarPhoto(
    this.car, {
    super.key,
    this.aspectRatio = 1.6,
    this.fit = BoxFit.cover,
  });
  final CarProduct car;
  final double aspectRatio;
  final BoxFit fit;
  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: aspectRatio,
    child: Image.asset(
      'assets/images/${car.id}.jpg',
      fit: fit,
      semanticLabel: 'Illustrative vehicle photograph for ${car.name}',
      errorBuilder: (context, error, stack) => ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(child: Text('Image unavailable')),
      ),
    ),
  );
}

class VehicleTile extends StatelessWidget {
  const VehicleTile({
    super.key,
    required this.car,
    required this.saved,
    required this.onSave,
    required this.onOpen,
  });
  final CarProduct car;
  final bool saved;
  final VoidCallback onSave;
  final VoidCallback onOpen;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      clipBehavior: Clip.antiAlias,
      shape: Border.all(color: scheme.outlineVariant),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              InkWell(
                key: ValueKey('open_${car.id}'),
                onTap: onOpen,
                child: CarPhoto(car),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.surface.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: IconButton(
                    key: ValueKey('save_${car.id}'),
                    tooltip: saved ? 'Unsave ${car.name}' : 'Save ${car.name}',
                    onPressed: onSave,
                    icon: Icon(
                      saved ? Icons.favorite : Icons.favorite_border,
                      color: saved ? scheme.primary : scheme.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${car.category}  ·  ${car.model}',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: onOpen,
                  child: Text(
                    car.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'By ${car.owner}',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 16,
                  runSpacing: 4,
                  children: [
                    Text(
                      formatPrice(car.price),
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: onOpen,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('View'),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VehicleGrid extends StatelessWidget {
  const VehicleGrid({
    super.key,
    required this.vehicles,
    required this.favorites,
    required this.onSave,
    required this.onOpen,
  });
  final List<CarProduct> vehicles;
  final Set<String> favorites;
  final ValueChanged<CarProduct> onSave;
  final ValueChanged<CarProduct> onOpen;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      // Intrinsic-height tiles support large system fonts, unlike fixed-aspect grids.
      final columns = constraints.maxWidth >= 1000
          ? 3
          : constraints.maxWidth >= 620
          ? 2
          : 1;
      final width = (constraints.maxWidth - 20 * (columns - 1)) / columns;
      return Wrap(
        spacing: 20,
        runSpacing: 24,
        children: [
          for (final car in vehicles)
            SizedBox(
              width: width,
              child: VehicleTile(
                car: car,
                saved: favorites.contains(car.id),
                onSave: () => onSave(car),
                onOpen: () => onOpen(car),
              ),
            ),
        ],
      );
    },
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.action,
    required this.onAction,
  });
  final IconData icon;
  final String title, message, action;
  final VoidCallback onAction;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: onAction, child: Text(action)),
          ],
        ),
      ),
    ),
  );
}

class PaintSelector extends StatelessWidget {
  const PaintSelector({
    super.key,
    required this.car,
    required this.selected,
    required this.onSelected,
  });
  final CarProduct car;
  final Color selected;
  final ValueChanged<Color> onSelected;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final color in {car.color, ...car.colors})
        Semantics(
          selected: selected == color,
          button: true,
          label: colorLabel(color),
          child: Tooltip(
            message: colorLabel(color),
            child: InkWell(
              key: ValueKey('paint_${color.toARGB32()}'),
              borderRadius: BorderRadius.circular(8),
              onTap: () => onSelected(color),
              child: Container(
                width: 52,
                height: 52,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: selected == color
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outlineVariant,
                    width: selected == color ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: selected == color
                      ? Icon(
                          Icons.check,
                          size: 20,
                          color: color.computeLuminance() > 0.45
                              ? Colors.black
                              : Colors.white,
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
    ],
  );
}
