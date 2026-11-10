import 'package:flutter/material.dart';
import '../models/car_product.dart';
import '../state/store_controller.dart';
import '../theme/app_theme.dart';
import 'collection_screen.dart';
import 'detail_screen.dart';
import 'garage_screen.dart';
import 'settings_screen.dart';
import 'showroom_screen.dart';

class StoreShell extends StatefulWidget {
  const StoreShell({super.key, required this.store});
  final StoreController store;
  @override
  State<StoreShell> createState() => _StoreShellState();
}

class _StoreShellState extends State<StoreShell> {
  int _tab = 0;
  String _category = 'All';
  int _browseRequest = 0;
  void _browse(String category) => setState(() {
    _category = category;
    _browseRequest++;
    _tab = 1;
  });
  void _open(CarProduct car) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => DetailScreen(
        car: car,
        store: widget.store,
        onViewGarage: () {
          Navigator.of(context).pop();
          setState(() => _tab = 3);
        },
      ),
    ),
  );
  static const labels = ['Showroom', 'Collection', 'Saved', 'Garage'];
  static const icons = [
    Icons.home_outlined,
    Icons.grid_view_outlined,
    Icons.favorite_border,
    Icons.shopping_bag_outlined,
  ];
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) {
      final store = widget.store;
      final desktop = MediaQuery.sizeOf(context).width >= 900;
      Widget navIcon(int index) => index == 3
          ? Badge(
              isLabelVisible: store.cartCount > 0,
              label: Text('${store.cartCount}'),
              child: Icon(icons[index]),
            )
          : Icon(icons[index]);
      return Scaffold(
        appBar: AppBar(
          toolbarHeight: desktop ? 80 : 64,
          titleSpacing: desktop ? 40 : 20,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppTheme.petrol,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                child: Text(
                  'G.',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 26,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'GUMAGARARCAR',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          actions: [
            if (desktop) ...[
              for (var i = 0; i < labels.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: TextButton.icon(
                    key: ValueKey('nav_$i'),
                    onPressed: () => setState(() => _tab = i),
                    style: TextButton.styleFrom(
                      foregroundColor: _tab == i
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      backgroundColor: _tab == i
                          ? Theme.of(context).colorScheme.primaryContainer
                                .withValues(alpha: 0.35)
                          : Colors.transparent,
                    ),
                    icon: navIcon(i),
                    label: Text(labels[i]),
                  ),
                ),
              const SizedBox(width: 12),
            ],
            IconButton(
              tooltip: 'Settings & team',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => SettingsScreen(store: store),
                ),
              ),
              icon: const Icon(Icons.settings_outlined),
            ),
            SizedBox(width: desktop ? 30 : 8),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              if (store.storageError != null)
                MaterialBanner(
                  content: Text(store.storageError!),
                  leading: const Icon(Icons.warning_amber),
                  actions: [
                    TextButton(
                      onPressed: () => store.retrySave(),
                      child: const Text('Retry save'),
                    ),
                  ],
                ),
              Expanded(
                child: IndexedStack(
                  index: _tab,
                  children: [
                    ShowroomScreen(
                      store: store,
                      onBrowse: _browse,
                      onOpen: _open,
                    ),
                    CollectionScreen(
                      store: store,
                      onOpen: _open,
                      category: _category,
                      requestId: _browseRequest,
                    ),
                    SavedScreen(
                      store: store,
                      onOpen: _open,
                      onBrowse: () => _browse('All'),
                    ),
                    GarageScreen(store: store, onBrowse: () => _browse('All')),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: desktop
            ? null
            : NavigationBar(
                selectedIndex: _tab,
                onDestinationSelected: (index) => setState(() => _tab = index),
                destinations: [
                  for (var i = 0; i < labels.length; i++)
                    NavigationDestination(
                      key: ValueKey('nav_$i'),
                      icon: navIcon(i),
                      label: labels[i],
                    ),
                ],
              ),
      );
    },
  );
}
