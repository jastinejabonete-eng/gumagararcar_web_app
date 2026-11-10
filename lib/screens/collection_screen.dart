import 'package:flutter/material.dart';
import '../data/cars.dart';
import '../models/car_product.dart';
import '../state/store_controller.dart';
import '../widgets/shared.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({
    super.key,
    required this.store,
    required this.onOpen,
    this.category = 'All',
    this.requestId = 0,
  });
  final StoreController store;
  final ValueChanged<CarProduct> onOpen;
  final String category;
  final int requestId;
  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  final _search = TextEditingController();
  late String _category = widget.category;
  String _sort = 'Featured';
  @override
  void didUpdateWidget(covariant CollectionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.requestId != widget.requestId) {
      _category = widget.category;
      _search.clear();
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _reset() => setState(() {
    _category = 'All';
    _search.clear();
    _sort = 'Featured';
  });
  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final filtered = cars
        .where(
          (car) =>
              (_category == 'All' || _category == car.category) &&
              '${car.name} ${car.model} ${car.owner} ${car.colorName} ${car.category}'
                  .toLowerCase()
                  .contains(query),
        )
        .toList();
    if (_sort == 'Price: low to high') {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    }
    if (_sort == 'Price: high to low') {
      filtered.sort((a, b) => b.price.compareTo(a.price));
    }
    if (_sort == 'Name: A–Z') filtered.sort((a, b) => a.name.compareTo(b.name));
    return PageBody(
      storageKey: 'collection',
      children: [
        const PageHeading(
          'Find your kind of drive.',
          'The full collection. Every concept has a story.',
        ),
        TextField(
          key: const ValueKey('catalog_search'),
          controller: _search,
          onChanged: (_) => setState(() {}),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            labelText: 'Search the collection',
            hintText: 'Name, creator, category or color',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: query.isNotEmpty
                ? IconButton(
                    tooltip: 'Clear search',
                    onPressed: () => setState(_search.clear),
                    icon: const Icon(Icons.close),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final category in categories)
              ChoiceChip(
                key: ValueKey('category_$category'),
                selected: _category == category,
                showCheckmark: false,
                label: Text(category == 'All' ? 'All cars' : category),
                onSelected: (_) => setState(() => _category = category),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) => Wrap(
            spacing: 24,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '${filtered.length} ${filtered.length == 1 ? 'concept' : 'concepts'}',
                key: const ValueKey('result_count'),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              SizedBox(
                width: constraints.maxWidth < 500 ? constraints.maxWidth : 220,
                child: DropdownButtonFormField<String>(
                  key: ValueKey('sort_$_sort'),
                  initialValue: _sort,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Sort by',
                    isDense: true,
                  ),
                  items: [
                    for (final sort in [
                      'Featured',
                      'Price: low to high',
                      'Price: high to low',
                      'Name: A–Z',
                    ])
                      DropdownMenuItem(value: sort, child: Text(sort)),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _sort = value);
                  },
                ),
              ),
              if (query.isNotEmpty || _category != 'All')
                TextButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                  label: const Text('Reset filters'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (filtered.isEmpty)
          EmptyState(
            icon: Icons.search_off,
            title: 'No matches this time.',
            message:
                'Try a different name or clear your filters to see all ${cars.length} concepts.',
            action: 'Reset filters',
            onAction: _reset,
          )
        else
          VehicleGrid(
            vehicles: filtered,
            favorites: widget.store.favorites,
            onSave: (car) => widget.store.toggleFavorite(car.id),
            onOpen: widget.onOpen,
          ),
        const SizedBox(height: 24),
        Text(
          'Concept vehicles · Illustrative photography · Prices in Philippine pesos',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class SavedScreen extends StatelessWidget {
  const SavedScreen({
    super.key,
    required this.store,
    required this.onOpen,
    required this.onBrowse,
  });
  final StoreController store;
  final ValueChanged<CarProduct> onOpen;
  final VoidCallback onBrowse;
  @override
  Widget build(BuildContext context) {
    final saved = cars
        .where((car) => store.favorites.contains(car.id))
        .toList();
    return PageBody(
      storageKey: 'saved',
      children: [
        PageHeading(
          'Your shortlist.',
          '${saved.length} saved ${saved.length == 1 ? 'concept' : 'concepts'}. Come back whenever inspiration strikes.',
        ),
        if (saved.isEmpty)
          EmptyState(
            icon: Icons.favorite_border,
            title: 'Something will catch your eye.',
            message:
                'Tap the heart on a car to keep it here. Your shortlist stays saved on this device.',
            action: 'Explore cars',
            onAction: onBrowse,
          )
        else
          VehicleGrid(
            vehicles: saved,
            favorites: store.favorites,
            onSave: (car) => store.toggleFavorite(car.id),
            onOpen: onOpen,
          ),
      ],
    );
  }
}
