import 'package:flutter/material.dart';
import '../data/cars.dart';
import '../state/store_controller.dart';
import '../utils/formatters.dart';
import '../widgets/shared.dart';
import 'garage_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.store});
  final StoreController store;
  static const roles = {
    'Jabacon': 'Documentation',
    'Oronos': 'Documentation',
    'Ladra': 'Documentation',
    'Jabonete': 'Programmer & Designer',
    'Antonio': 'Programmer & Designer',
    'Abadia': 'Programmer & Designer',
    'Castillo': 'Programmer & Designer',
    'Tapia': 'Documentation',
  };
  Future<void> _clear(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear local data?'),
        content: const Text(
          'This removes your garage, saved cars and demo receipts, and resets appearance and rotation settings. The collection itself stays unchanged.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const ValueKey('confirm_clear'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear data'),
          ),
        ],
      ),
    );
    if (result == true) store.clearLocalData();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => Scaffold(
      appBar: AppBar(title: const Text('Settings & team')),
      body: SafeArea(
        child: PageBody(
          maxWidth: 760,
          children: [
            const PageHeading(
              'Make yourself at home.',
              'Your preferences are saved on this device.',
            ),
            Text(
              'Appearance',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ThemeMode>(
              key: ValueKey('theme_${store.themeMode.name}'),
              initialValue: store.themeMode,
              decoration: const InputDecoration(
                labelText: 'Color theme',
                prefixIcon: Icon(Icons.contrast),
              ),
              items: const [
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('Follow device'),
                ),
              ],
              onChanged: (mode) {
                if (mode != null) store.setThemeMode(mode);
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile.adaptive(
              key: const ValueKey('auto_rotate'),
              contentPadding: EdgeInsets.zero,
              title: const Text('Rotate 3D previews'),
              subtitle: const Text(
                'Automatically turn the concept when its 3D view is open. Respects reduced-motion settings.',
              ),
              value: store.autoRotate,
              onChanged: store.setAutoRotate,
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 32),
            Text(
              'Demo receipts',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            if (store.orders.isEmpty)
              const Text(
                'No receipts yet. Complete a demo checkout to see one here.',
              ),
            for (final order in store.orders)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(formatPrice(order.total)),
                subtitle: Text(
                  '${receiptDate(order.createdAt)} · ${order.itemCount} vehicles',
                ),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ReceiptScreen(order: order),
                  ),
                ),
              ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 32),
            Text(
              'Meet the builders.',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 10),
            Text(
              'Group 1 · MOB DEV FINALS\n${cars.length} creators. One shared love of cars.',
            ),
            const SizedBox(height: 20),
            for (final car in cars)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      child: Text(car.owner.substring(0, 1)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            car.owner,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${roles[car.owner] ?? 'Vehicle concept creator'}\n${car.name}',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 32),
            Text(
              'About this concept store',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            const Text(
              'Gumagararcar is a Flutter student project. Vehicles, prices, and checkout are a demonstration, not a live dealership. No accounts, online payments, push notifications, or remote order processing are connected.',
            ),
            const SizedBox(height: 12),
            const Text(
              'Photography: illustrative vehicle references from Unsplash and Pexels. Fonts: Barlow and Barlow Condensed, SIL Open Font License. The existing bundled concept model is available on the Apex GT detail screen. Asset origins are recorded in assets/provenance.json.',
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => showLicensePage(
                context: context,
                applicationName: 'Gumagararcar',
                applicationVersion: '1.0.0',
              ),
              child: const Text('Open-source licenses'),
            ),
            const SizedBox(height: 32),
            Text(
              'Local storage',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            const Text(
              'Saved cars, cart finishes, preferences, and demo receipts stay on this device. Browser data may be removed by private browsing or clearing site storage.',
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              key: const ValueKey('clear_local'),
              onPressed: () => _clear(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Clear local data'),
            ),
          ],
        ),
      ),
    ),
  );
}
