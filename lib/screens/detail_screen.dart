import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../models/car_product.dart';
import '../state/store_controller.dart';
import '../utils/formatters.dart';
import '../widgets/shared.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({
    super.key,
    required this.car,
    required this.store,
    required this.onViewGarage,
  });
  final CarProduct car;
  final StoreController store;
  final VoidCallback onViewGarage;
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Color _paint = widget.car.color;
  bool _show3d = false;
  bool _added = false;
  bool get _supports3d =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) {
      final car = widget.car;
      final theme = Theme.of(context);
      final saved = widget.store.favorites.contains(car.id);
      final media = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _show3d
                ? SizedBox(
                    height: 360,
                    child: ModelViewer(
                      key: ValueKey('viewer_${widget.store.autoRotate}'),
                      src: car.model3dPath!,
                      alt: '${car.name} concept 3D preview',
                      backgroundColor: theme.colorScheme.surface,
                      autoRotate:
                          widget.store.autoRotate &&
                          !MediaQuery.disableAnimationsOf(context),
                      cameraControls: true,
                      disableZoom: false,
                      shadowIntensity: 0.5,
                      ar: false,
                    ),
                  )
                : CarPhoto(car, aspectRatio: 1.35),
          ),
          const SizedBox(height: 12),
          if (car.model3dPath != null && _supports3d)
            OutlinedButton.icon(
              key: const ValueKey('toggle_3d'),
              onPressed: () => setState(() => _show3d = !_show3d),
              icon: Icon(
                _show3d ? Icons.photo_outlined : Icons.view_in_ar_outlined,
              ),
              label: Text(_show3d ? 'Back to photo' : 'Explore in 3D'),
            ),
          if (_show3d)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Drag to rotate · Pinch or scroll to zoom. If the preview cannot load, return to the photo.',
              ),
            ),
          const SizedBox(height: 12),
          Text(
            'Illustrative reference photo, not the actual concept. Paint selection is saved with your cart; it does not recolor the photograph or 3D preview.',
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
      final info = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(car.name, style: theme.textTheme.displayMedium),
          const SizedBox(height: 10),
          Text(
            '${car.category}  ·  ${car.model}  ·  By ${car.owner}',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 24),
          Text(car.tagline, style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(
            'An original ${car.category.toLowerCase()} concept from ${car.owner}, part of the Gumagararcar collection. Make it yours with a finish that fits your style.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 28),
          const Divider(),
          const SizedBox(height: 24),
          Text(formatPrice(car.price), style: theme.textTheme.headlineLarge),
          const SizedBox(height: 4),
          Text(
            'Concept price · Philippine pesos',
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 28),
          Text(
            'Paint finish: ${colorLabel(_paint)}',
            key: const ValueKey('selected_paint'),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 12),
          PaintSelector(
            car: car,
            selected: _paint,
            onSelected: (value) => setState(() {
              _paint = value;
              _added = false;
            }),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const ValueKey('add_to_garage'),
              onPressed: () {
                widget.store.addToCart(car, _paint);
                setState(() => _added = true);
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        '${car.name} · ${colorLabel(_paint)} added',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
              },
              icon: const Icon(Icons.add_shopping_cart, size: 20),
              label: Text(_added ? 'Add another to garage' : 'Add to garage'),
            ),
          ),
          if (_added)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: widget.onViewGarage,
                  child: const Text('View garage'),
                ),
              ),
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => widget.store.toggleFavorite(car.id),
              icon: Icon(saved ? Icons.favorite : Icons.favorite_border),
              label: Text(saved ? 'Saved to your shortlist' : 'Save for later'),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'A student concept store. Checkout is a local demo, not a real purchase.',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      );
      return Scaffold(
        appBar: AppBar(title: const Text('The collection')),
        body: SafeArea(
          child: PageBody(
            maxWidth: 1160,
            children: [
              LayoutBuilder(
                builder: (context, constraints) => constraints.maxWidth >= 850
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 6, child: media),
                          const SizedBox(width: 48),
                          Expanded(flex: 5, child: info),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [media, const SizedBox(height: 28), info],
                      ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
