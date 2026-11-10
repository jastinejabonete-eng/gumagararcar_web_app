import 'dart:convert';

import 'package:flutter/material.dart';

import '../data/cars.dart';
import '../models/car_product.dart';
import '../models/cart_line.dart';
import '../services/store_storage.dart';

class StoreController extends ChangeNotifier {
  StoreController({StoreStorage? storage})
    : _storage = storage ?? SharedPreferencesStoreStorage();

  final StoreStorage _storage;
  bool _isLoaded = false;
  String? _storageError;
  ThemeMode _themeMode = ThemeMode.light;
  bool _autoRotate = true;
  final List<CartLine> _cart = [];
  final Set<String> _favorites = {};
  final List<DemoOrder> _orders = [];
  final Map<String, CarProduct> _catalog = {
    for (final car in cars) car.id: car,
  };
  Future<void> _pendingSave = Future<void>.value();
  Future<void>? _initialization;
  bool _hasMutated = false;
  bool _disposed = false;

  bool get isLoaded => _isLoaded;
  String? get storageError => _storageError;
  ThemeMode get themeMode => _themeMode;
  bool get autoRotate => _autoRotate;
  List<CartLine> get cartLines => List.unmodifiable(_cart);
  Set<String> get favorites => Set.unmodifiable(_favorites);
  List<DemoOrder> get orders => List.unmodifiable(_orders);
  int get cartCount => _cart.fold(0, (sum, line) => sum + line.quantity);
  int get cartTotal => _cart.fold(0, (sum, line) => sum + line.total);

  void toggleFavorite(String carId) {
    if (!_catalog.containsKey(carId)) return;
    if (!_favorites.remove(carId)) _favorites.add(carId);
    _changed();
  }

  void setThemeMode(ThemeMode value) {
    if (themeMode == value) return;
    _themeMode = value;
    _changed();
  }

  void setAutoRotate(bool value) {
    if (autoRotate == value) return;
    _autoRotate = value;
    _changed();
  }

  void addToCart(CarProduct car, Color color) {
    final knownCar = _catalog[car.id];
    if (knownCar == null || !_validColor(knownCar, color.toARGB32())) return;
    car = knownCar;
    final line = CartLine(car: car, color: color, quantity: 1);
    final index = _cart.indexWhere((item) => item.id == line.id);
    if (index < 0) {
      _cart.add(line);
    } else {
      final previous = _cart[index];
      _cart[index] = CartLine(
        car: car,
        color: color,
        quantity: previous.quantity + 1,
      );
    }
    _changed();
  }

  void changeQuantity(String lineId, int delta) {
    final index = _cart.indexWhere((line) => line.id == lineId);
    if (index < 0 || delta == 0) return;
    final line = _cart[index];
    final quantity = line.quantity + delta;
    if (quantity <= 0) {
      _cart.removeAt(index);
    } else {
      _cart[index] = CartLine(
        car: line.car,
        color: line.color,
        quantity: quantity,
      );
    }
    _changed();
  }

  void removeLine(String lineId) {
    final index = _cart.indexWhere((line) => line.id == lineId);
    if (index < 0) return;
    _cart.removeAt(index);
    _changed();
  }

  DemoOrder? checkout() {
    if (_cart.isEmpty) return null;
    final now = DateTime.now();
    var suffix = 0;
    var id = 'demo-${now.microsecondsSinceEpoch}';
    while (_orders.any((order) => order.id == id)) {
      id = 'demo-${now.microsecondsSinceEpoch}-${++suffix}';
    }
    final receipt = DemoOrder(id: id, createdAt: now, lines: _cart);
    _orders.insert(0, receipt);
    _cart.clear();
    _changed();
    return receipt;
  }

  void clearLocalData() {
    _cart.clear();
    _favorites.clear();
    _orders.clear();
    _themeMode = ThemeMode.light;
    _autoRotate = true;
    _changed();
  }

  Map<String, Object> _encodeLine(CartLine line) => {
    'carId': line.car.id,
    'color': line.color.toARGB32(),
    'quantity': line.quantity,
  };

  void _changed() {
    _hasMutated = true;
    _queueSave(_encodeSnapshot());
    _notify();
  }

  String _encodeSnapshot() => jsonEncode({
    'version': 1,
    'cart': _cart.map(_encodeLine).toList(),
    'favorites': favorites.toList(),
    'theme': themeMode.name,
    'autoRotate': autoRotate,
    'orders': _orders
        .map(
          (order) => {
            'id': order.id,
            'createdAt': order.createdAt.toIso8601String(),
            'lines': order.lines.map(_encodeLine).toList(),
          },
        )
        .toList(),
  });

  Future<void> _queueSave(String snapshot) {
    _pendingSave = _pendingSave.then((_) async {
      final previousError = storageError;
      try {
        await _storage.write(snapshot);
        _storageError = null;
      } catch (error) {
        _storageError = 'Could not save local data: $error';
      }
      if (previousError != storageError) {
        _notify();
      }
    });
    return _pendingSave;
  }

  bool _validColor(CarProduct car, int argb) =>
      car.color.toARGB32() == argb ||
      car.colors.any((color) => color.toARGB32() == argb);

  List<CartLine> _decodeLines(Object? value) {
    if (value is! List) return [];
    final lines = <String, CartLine>{};
    for (final item in value) {
      if (item is! Map) continue;
      final car = _catalog[item['carId']];
      final color = item['color'];
      final quantity = item['quantity'];
      if (car == null ||
          color is! int ||
          color < 0 ||
          color > 0xFFFFFFFF ||
          !_validColor(car, color) ||
          quantity is! int ||
          quantity <= 0) {
        continue;
      }
      final line = CartLine(car: car, color: Color(color), quantity: quantity);
      final previous = lines[line.id];
      lines[line.id] = CartLine(
        car: car,
        color: line.color,
        quantity: quantity + (previous?.quantity ?? 0),
      );
    }
    return lines.values.toList();
  }

  /// Await before exposing the store's controls. Repeated calls share one load.
  Future<void> initialize() => _initialization ??= _load();

  Future<void> _load() async {
    try {
      final value = await _storage.read();
      // An explicit local edit (especially clear) takes precedence over a late read.
      if (_hasMutated) return;
      if (value != null) {
        final snapshot = jsonDecode(value);
        if (snapshot is! Map || snapshot['version'] != 1) {
          throw const FormatException('Unsupported storefront snapshot');
        }
        _cart.addAll(_decodeLines(snapshot['cart']));
        final savedFavorites = snapshot['favorites'];
        if (savedFavorites is List) {
          _favorites.addAll(
            savedFavorites.whereType<String>().where(_catalog.containsKey),
          );
        }
        _themeMode = switch (snapshot['theme']) {
          'dark' => ThemeMode.dark,
          'system' => ThemeMode.system,
          _ => ThemeMode.light,
        };
        final rotation = snapshot['autoRotate'];
        _autoRotate = rotation is bool ? rotation : true;
        final savedOrders = snapshot['orders'];
        if (savedOrders is List) {
          final ids = <String>{};
          for (final item in savedOrders) {
            if (item is! Map) continue;
            final id = item['id'];
            final date = item['createdAt'];
            final createdAt = date is String ? DateTime.tryParse(date) : null;
            final lines = _decodeLines(item['lines']);
            if (id is! String ||
                id.trim().isEmpty ||
                createdAt == null ||
                lines.isEmpty ||
                !ids.add(id)) {
              continue;
            }
            _orders.add(DemoOrder(id: id, createdAt: createdAt, lines: lines));
          }
        }
      }
    } catch (error) {
      _storageError = 'Could not load local data: $error';
    } finally {
      _isLoaded = true;
      _notify();
    }
  }

  Future<void> flush() => _pendingSave;

  Future<void> retrySave() {
    if (!_hasMutated) return _pendingSave;
    return _queueSave(_encodeSnapshot());
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
