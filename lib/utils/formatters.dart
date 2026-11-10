import 'package:flutter/material.dart';

String formatPrice(int price) {
  final digits = price.toString();
  final formatted = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) {
      formatted.write(',');
    }
    formatted.write(digits[index]);
  }
  return '₱$formatted';
}

String colorLabel(Color color) {
  return switch (color.toARGB32()) {
    0xFF090909 => 'Obsidian Black',
    0xFF202020 => 'Onyx Black',
    0xFF252525 || 0xFF343434 => 'Midnight Black',
    0xFF5E0000 => 'Black Cherry',
    0xFF830000 => 'Deep Maroon',
    0xFF9E0010 => 'Ruby Red',
    0xFF9B9B9B => 'Gunmetal',
    0xFFB8B8B8 || 0xFFC8C8C8 => 'Silver',
    0xFFE3E3E3 || 0xFFE6E6E6 => 'Pearl White',
    0xFFBC0202 => 'Crimson Red',
    0xFFFF0000 => 'Racing Red',
    _ => 'Custom color',
  };
}