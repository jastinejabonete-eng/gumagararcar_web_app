import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gumagararcar/data/cars.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gumagararcar/services/store_storage.dart';
import 'package:gumagararcar/state/store_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Federated platform boundary of shared_preferences, used only in this test.
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  test('initialize is shared and never reapplies stored state', () async {
    final storage = _ReadGateStorage();
    final store = StoreController(storage: storage);
    addTearDown(store.dispose);
    final first = store.initialize();
    final second = store.initialize();
    expect(storage.reads, 1);
    storage.result.complete(
      jsonEncode({
        'version': 1,
        'cart': [
          {
            'carId': cars.first.id,
            'color': cars.first.color.toARGB32(),
            'quantity': 1,
          },
        ],
      }),
    );
    await Future.wait([first, second]);
    expect(store.cartCount, 1);
    store.addToCart(cars.first, cars.first.color);
    await store.initialize();
    expect(store.cartCount, 2);
    expect(storage.reads, 1);
    await store.flush();
  });

  test('clear during loading cannot resurrect old local data', () async {
    final storage = _ReadGateStorage();
    final store = StoreController(storage: storage);
    addTearDown(store.dispose);
    final loading = store.initialize();
    store.clearLocalData();
    storage.result.complete(
      jsonEncode({
        'version': 1,
        'favorites': [cars.first.id],
        'theme': 'dark',
        'autoRotate': false,
        'cart': [
          {
            'carId': cars.first.id,
            'color': cars.first.color.toARGB32(),
            'quantity': 1,
          },
        ],
      }),
    );
    await loading;
    await store.flush();
    expect(store.cartLines, isEmpty);
    expect(store.favorites, isEmpty);
    expect(store.themeMode, ThemeMode.light);
    expect(store.autoRotate, isTrue);
  });

  test(
    'read errors finish loading and late completion after dispose is safe',
    () async {
      final storage = _ReadGateStorage();
      final store = StoreController(storage: storage);
      var notifications = 0;
      store.addListener(() => notifications++);
      final loading = store.initialize();
      store.dispose();
      storage.result.completeError(StateError('read failed'));
      await loading;
      expect(store.isLoaded, isTrue);
      expect(store.storageError, contains('read failed'));
      expect(notifications, 0);
    },
  );

  test('runtime default round-trips through SharedPreferencesAsync', () async {
    final previous = SharedPreferencesAsyncPlatform.instance;
    final platform = _PreferencesPlatform();
    SharedPreferencesAsyncPlatform.instance = platform;
    addTearDown(() => SharedPreferencesAsyncPlatform.instance = previous);
    platform.values['unrelated-key'] = 'keep me';
    final store = StoreController();
    addTearDown(store.dispose);
    await store.initialize();
    store.addToCart(cars.first, cars.first.colors.last);
    await store.flush();
    expect(platform.values, hasLength(2));
    final restored = StoreController();
    addTearDown(restored.dispose);
    await restored.initialize();
    expect(restored.cartLines.single.color, cars.first.colors.last);
    restored.clearLocalData();
    await restored.flush();
    expect(platform.values['unrelated-key'], 'keep me');
    final storage = SharedPreferencesStoreStorage();
    expect(jsonDecode((await storage.read())!)['cart'], isEmpty);
  });

  test(
    'save failures are visible and retry persists the latest snapshot',
    () async {
      final storage = _FailingStorage();
      final store = StoreController(storage: storage);
      addTearDown(store.dispose);
      await store.initialize();
      final errors = <String?>[];
      store.addListener(() => errors.add(store.storageError));
      store.addToCart(cars.first, cars.first.color);
      await store.flush();
      expect(store.cartCount, 1);
      expect(store.storageError, contains('write failed'));
      expect(errors.last, store.storageError);

      await store.retrySave();
      expect(store.storageError, isNull);
      final retried = StoreController(storage: storage);
      addTearDown(retried.dispose);
      await retried.initialize();
      expect(retried.cartCount, 1);

      store.setThemeMode(ThemeMode.dark);
      await store.flush();
      expect(store.storageError, isNull);
      expect(errors.last, isNull);
      final updated = StoreController(storage: storage);
      addTearDown(updated.dispose);
      await updated.initialize();
      expect(updated.cartCount, 1);
      expect(updated.themeMode, ThemeMode.dark);
    },
  );

  test(
    'rapid writes remain serialized and flush waits for the final snapshot',
    () async {
      final storage = _GatedStorage();
      final store = StoreController(storage: storage);
      addTearDown(store.dispose);
      await store.initialize();
      for (var i = 0; i < 3; i++) {
        store.addToCart(cars.first, cars.first.color);
      }
      var flushed = false;
      final flushing = store.flush().then((_) => flushed = true);
      await Future<void>.delayed(Duration.zero);
      expect(storage.started, hasLength(1));
      expect(flushed, isFalse);
      storage.gate.complete();
      await flushing;
      expect(storage.maxConcurrent, 1);
      expect(
        storage.started.map(
          (value) => (jsonDecode(value)['cart'] as List).single['quantity'],
        ),
        [1, 2, 3],
      );
      expect(jsonDecode((await storage.read())!)['cart'][0]['quantity'], 3);
    },
  );

  test(
    'checkout makes immutable local receipts and clear persists defaults',
    () async {
      final storage = MemoryStoreStorage();
      final store = StoreController(storage: storage);
      addTearDown(store.dispose);
      await store.initialize();
      expect(store.checkout(), isNull);
      expect(store.orders, isEmpty);
      final car = cars.first;
      store.addToCart(car, car.color);
      store.changeQuantity(store.cartLines.single.id, 2);
      store.addToCart(car, car.colors[1]);
      final beforeCheckout = DateTime.now();
      final receipt = store.checkout()!;
      expect(receipt.id, isNotEmpty);
      expect(receipt.createdAt.isBefore(beforeCheckout), isFalse);
      expect(receipt.itemCount, 4);
      expect(receipt.total, car.price * 4);
      expect(receipt.lines, hasLength(2));
      expect(store.cartLines, isEmpty);
      expect(store.orders.single, same(receipt));
      expect(() => receipt.lines.clear(), throwsUnsupportedError);
      expect(() => store.orders.clear(), throwsUnsupportedError);

      store.addToCart(car, car.color);
      store.changeQuantity(store.cartLines.single.id, 4);
      final second = store.checkout()!;
      expect(second.id, isNot(receipt.id));
      expect(receipt.itemCount, 4);
      expect(receipt.lines.first.quantity, 3);
      store.toggleFavorite(car.id);
      store.setThemeMode(ThemeMode.dark);
      store.setAutoRotate(false);
      await store.flush();

      final restored = StoreController(storage: storage);
      addTearDown(restored.dispose);
      await restored.initialize();
      expect(restored.orders, hasLength(2));
      final restoredReceipt = restored.orders.firstWhere(
        (o) => o.id == receipt.id,
      );
      expect(restoredReceipt.createdAt, receipt.createdAt);
      expect(restoredReceipt.total, receipt.total);
      expect(restoredReceipt.itemCount, receipt.itemCount);
      expect(restoredReceipt.lines.last.color, car.colors[1]);
      restored.addToCart(car, car.color);
      restored.clearLocalData();
      expect(restored.cartLines, isEmpty);
      expect(restored.orders, isEmpty);
      expect(restored.favorites, isEmpty);
      expect(restored.themeMode, ThemeMode.light);
      expect(restored.autoRotate, isTrue);
      expect(receipt.itemCount, 4);
      await restored.flush();
      final cleared = StoreController(storage: storage);
      addTearDown(cleared.dispose);
      await cleared.initialize();
      expect(cleared.orders, isEmpty);
      expect(cleared.cartLines, isEmpty);
      expect(cleared.favorites, isEmpty);
      expect(cleared.themeMode, ThemeMode.light);
      expect(cleared.autoRotate, isTrue);
    },
  );

  test('ignores invalid entries and preserves valid default colors', () async {
    final car = cars[1]; // Its default is intentionally absent from colors.
    final valid = {
      'carId': car.id,
      'color': car.color.toARGB32(),
      'quantity': 2,
    };
    final storage = MemoryStoreStorage(
      jsonEncode({
        'version': 1,
        'cart': [
          valid,
          {...valid, 'quantity': 1},
          {...valid, 'carId': 'missing'},
          {...valid, 'quantity': 0},
          {...valid, 'quantity': -1},
          {...valid, 'quantity': 1.5},
          {...valid, 'quantity': '2'},
          {...valid, 'color': -1},
          {...valid, 'color': 0x100000000},
          {...valid, 'color': '0xFF252525'},
          {...valid, 'color': 0xFFFFFFFF},
          null,
          false,
          'bad',
          {},
        ],
        'favorites': [car.id, car.id, 'missing', null, 12],
        'theme': 'not-a-theme',
        'autoRotate': 'true',
        'orders': 'invalid',
      }),
    );
    final store = StoreController(storage: storage);
    addTearDown(store.dispose);
    await store.initialize();
    expect(store.isLoaded, isTrue);
    expect(store.cartLines, hasLength(1));
    expect(store.cartLines.single.color, car.color);
    expect(store.cartCount, 3);
    expect(store.favorites, {car.id});
    expect(store.themeMode, ThemeMode.light);
    expect(store.autoRotate, isTrue);
    expect(store.orders, isEmpty);

    final before = store.cartCount;
    store.addToCart(car, const Color(0xFFFFFFFF));
    expect(store.cartCount, before);
  });

  for (final payload in ['not json', 'null', '[]', '{"version":2}', '{}']) {
    test('handles unsupported or malformed root: $payload', () async {
      final store = StoreController(storage: MemoryStoreStorage(payload));
      addTearDown(store.dispose);
      await store.initialize();
      expect(store.isLoaded, isTrue);
      expect(store.cartLines, isEmpty);
      expect(store.storageError, isNotNull);
    });
  }

  test('restores variants, favorites and both preferences from JSON', () async {
    final storage = MemoryStoreStorage();
    final store = StoreController(storage: storage);
    addTearDown(store.dispose);
    await store.initialize();
    for (final car in cars) {
      store.addToCart(car, car.color);
      for (final color in car.colors) {
        store.addToCart(car, color);
      }
    }
    store.toggleFavorite(cars.first.id);
    store.toggleFavorite(cars.last.id);
    store.toggleFavorite(cars.last.id);
    store.toggleFavorite('not-in-the-catalog');
    store.setThemeMode(ThemeMode.dark);
    store.setAutoRotate(false);
    await store.flush();

    final restored = StoreController(storage: storage);
    addTearDown(restored.dispose);
    await restored.initialize();
    expect(restored.cartCount, store.cartCount);
    expect(restored.cartTotal, store.cartTotal);
    expect(
      restored.cartLines.map((line) => line.id),
      store.cartLines.map((line) => line.id),
    );
    expect(
      restored.cartLines.map((line) => line.quantity),
      store.cartLines.map((line) => line.quantity),
    );
    expect(restored.favorites, {cars.first.id});
    expect(() => restored.favorites.clear(), throwsUnsupportedError);
    expect(restored.themeMode, ThemeMode.dark);
    expect(restored.autoRotate, isFalse);
    restored.setThemeMode(ThemeMode.system);
    await restored.flush();
    final third = StoreController(storage: storage);
    addTearDown(third.dispose);
    await third.initialize();
    expect(third.themeMode, ThemeMode.system);
  });

  test(
    'keeps color variants separate, updates totals and saves each change',
    () async {
      final storage = MemoryStoreStorage();
      final store = StoreController(storage: storage);
      addTearDown(store.dispose);
      await store.initialize();
      var notifications = 0;
      store.addListener(() => notifications++);
      final car = cars.first;

      store.addToCart(car, car.color);
      store.addToCart(car, car.color);
      store.addToCart(car, car.colors[1]);

      expect(store.cartLines, hasLength(2));
      expect(
        store.cartLines.first.id,
        '${car.id}:${car.color.toARGB32().toRadixString(16)}',
      );
      expect(store.cartLines.first.quantity, 2);
      expect(store.cartLines.last.color, car.colors[1]);
      expect(store.cartCount, 3);
      expect(store.cartTotal, car.price * 3);
      expect(store.cartLines.first.total, car.price * 2);
      expect(notifications, 3);
      expect(() => store.cartLines.clear(), throwsUnsupportedError);

      store.changeQuantity(store.cartLines.first.id, -1);
      expect(store.cartCount, 2);
      store.changeQuantity(store.cartLines.first.id, -5);
      expect(store.cartLines, hasLength(1));
      store.changeQuantity('unknown', 1);
      store.removeLine('unknown');
      store.removeLine(store.cartLines.single.id);
      expect(store.cartTotal, 0);
      await store.flush();
      final snapshot = jsonDecode((await storage.read())!) as Map;
      expect(snapshot['version'], 1);
      expect(snapshot['cart'], isEmpty);
    },
  );

  test('initializes empty with light theme and rotation enabled', () async {
    final storage = MemoryStoreStorage();
    final store = StoreController(storage: storage);
    addTearDown(store.dispose);

    expect(store.isLoaded, isFalse);
    await store.initialize();

    expect(store.isLoaded, isTrue);
    expect(store.storageError, isNull);
    expect(store.themeMode, ThemeMode.light);
    expect(store.autoRotate, isTrue);
    expect(store.cartLines, isEmpty);
    expect(store.favorites, isEmpty);
    expect(store.orders, isEmpty);
    expect(store.cartCount, 0);
    expect(store.cartTotal, 0);
    await store.flush();
    expect(await storage.read(), isNull);
  });
}

class _ReadGateStorage extends MemoryStoreStorage {
  final result = Completer<String?>();
  int reads = 0;

  @override
  Future<String?> read() {
    reads++;
    return result.future;
  }
}

final class _PreferencesPlatform extends SharedPreferencesAsyncPlatform {
  final Map<String, String> values = {};

  @override
  Future<String?> getString(
    String key,
    SharedPreferencesOptions options,
  ) async => values[key];

  @override
  Future<void> setString(
    String key,
    String value,
    SharedPreferencesOptions options,
  ) async {
    values[key] = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName}');
}

class _FailingStorage extends MemoryStoreStorage {
  bool failNext = true;

  @override
  Future<void> write(String value) async {
    if (failNext) {
      failNext = false;
      throw StateError('write failed');
    }
    await super.write(value);
  }
}

class _GatedStorage extends MemoryStoreStorage {
  final gate = Completer<void>();
  final List<String> started = [];
  int concurrent = 0;
  int maxConcurrent = 0;

  @override
  Future<void> write(String value) async {
    started.add(value);
    concurrent++;
    if (concurrent > maxConcurrent) maxConcurrent = concurrent;
    await gate.future;
    await super.write(value);
    concurrent--;
  }
}
