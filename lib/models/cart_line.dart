import 'package:flutter/material.dart';

import 'car_product.dart';

@immutable
class CartLine {
  CartLine({required this.car, required this.color, required this.quantity})
    : id = '${car.id}:${color.toARGB32().toRadixString(16).padLeft(8, '0')}',
      total = car.price * quantity;

  final String id;
  final CarProduct car;
  final Color color;
  final int quantity;

  final int total;
}

/// An immutable receipt for a local demo, never a real purchase.
@immutable
class DemoOrder {
  DemoOrder({
    required this.id,
    required this.createdAt,
    required List<CartLine> lines,
  }) : lines = List.unmodifiable(lines),
       total = lines.fold(0, (sum, line) => sum + line.total),
       itemCount = lines.fold(0, (sum, line) => sum + line.quantity);

  final String id;
  final DateTime createdAt;
  final List<CartLine> lines;

  final int total;
  final int itemCount;
}
