import 'package:flutter/material.dart';
import '../models/cart_line.dart';
import '../state/store_controller.dart';
import '../utils/formatters.dart';
import '../widgets/shared.dart';

class GarageScreen extends StatelessWidget {
  const GarageScreen({super.key, required this.store, required this.onBrowse});
  final StoreController store;
  final VoidCallback onBrowse;
  Future<void> _checkout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete demo checkout?'),
        content: Text(
          'Total: ${formatPrice(store.cartTotal)}\n\nThis saves a receipt on this device and clears your garage. No payment is taken and no real order is placed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep browsing'),
          ),
          FilledButton(
            key: const ValueKey('confirm_checkout'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Complete demo'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final order = store.checkout();
    if (order != null && context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => ReceiptScreen(order: order)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lines = store.cartLines;
    final summary = Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Your selection',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          Text(
            '${store.cartCount} ${store.cartCount == 1 ? 'vehicle' : 'vehicles'} · ${lines.length} ${lines.length == 1 ? 'finish' : 'finishes'}',
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          const Text('Demo total'),
          const SizedBox(height: 6),
          Text(
            formatPrice(store.cartTotal),
            key: const ValueKey('cart_total'),
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 24),
          FilledButton(
            key: const ValueKey('checkout'),
            onPressed: () => _checkout(context),
            child: const Text('Review demo checkout'),
          ),
          const SizedBox(height: 16),
          Text(
            'Demo only. No charge, shipping, or real order. Your receipt is stored on this device.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
    return PageBody(
      storageKey: 'garage',
      children: [
        PageHeading(
          'Your garage.',
          'The right cars. The right finishes. All in one place.',
          action: lines.isEmpty
              ? null
              : TextButton(
                  onPressed: onBrowse,
                  child: const Text('Keep exploring'),
                ),
        ),
        if (lines.isEmpty)
          EmptyState(
            icon: Icons.shopping_bag_outlined,
            title: 'Room for your next favorite.',
            message:
                'Choose a concept and its paint finish, then add it to your garage. Your selections stay on this device.',
            action: 'Explore the collection',
            onAction: onBrowse,
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final items = Column(
                children: [
                  for (final line in lines)
                    _GarageLine(line: line, store: store),
                ],
              );
              return constraints.maxWidth >= 950
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 7, child: items),
                        const SizedBox(width: 32),
                        Expanded(flex: 4, child: summary),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [items, const SizedBox(height: 24), summary],
                    );
            },
          ),
        if (store.orders.isNotEmpty) ...[
          const SizedBox(height: 36),
          Text(
            'Recent demo receipts',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          for (final order in store.orders.take(3))
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.receipt_long_outlined),
              title: Text(formatPrice(order.total)),
              subtitle: Text(
                '${order.itemCount} vehicles · ${receiptDate(order.createdAt)}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ReceiptScreen(order: order),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _GarageLine extends StatelessWidget {
  const _GarageLine({required this.line, required this.store});
  final CartLine line;
  final StoreController store;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.sizeOf(context).width < 420 ? 88 : 128,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CarPhoto(line.car, aspectRatio: 1),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    line.car.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    colorLabel(line.color),
                    key: ValueKey('line_color_${line.id}'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${formatPrice(line.car.price)} each',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatPrice(line.total),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 20,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  key: ValueKey('decrease_${line.id}'),
                  tooltip: 'Decrease ${line.car.name} quantity',
                  onPressed: () => store.changeQuantity(line.id, -1),
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Semantics(
                  label: '${line.car.name} quantity',
                  child: Text(
                    '${line.quantity}',
                    key: ValueKey('quantity_${line.id}'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  key: ValueKey('increase_${line.id}'),
                  tooltip: 'Increase ${line.car.name} quantity',
                  onPressed: () => store.changeQuantity(line.id, 1),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            TextButton.icon(
              key: ValueKey('remove_${line.id}'),
              onPressed: () => store.removeLine(line.id),
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Remove'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(),
      ],
    ),
  );
}

String receiptDate(DateTime date) {
  final local = date.toLocal();
  return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
}

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key, required this.order});
  final DemoOrder order;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Demo receipt')),
    body: SafeArea(
      child: PageBody(
        maxWidth: 720,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 20),
          const PageHeading(
            'Your demo is complete.',
            'No payment was taken. No real order was placed.',
          ),
          Text(
            'Receipt ${order.id}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(receiptDate(order.createdAt)),
          const SizedBox(height: 24),
          const Divider(),
          for (final line in order.lines)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    line.car.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text('${colorLabel(line.color)} · Quantity ${line.quantity}'),
                  const SizedBox(height: 6),
                  Text(
                    formatPrice(line.total),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          const Divider(),
          const SizedBox(height: 20),
          const Text('Demo total'),
          const SizedBox(height: 8),
          Text(
            formatPrice(order.total),
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 28),
          const Text(
            'This receipt is saved locally. You can find it in your garage or Settings & team. Clearing local data removes it.',
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to garage'),
          ),
        ],
      ),
    ),
  );
}
