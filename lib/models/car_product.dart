import 'package:flutter/material.dart';

class CarProduct {
  const CarProduct({
    required this.id,
    required this.name,
    required this.model,
    required this.price,
    required this.owner,
    required this.category,
    required this.colorName,
    required this.color,
    required this.colors,
    required this.tagline,
    this.model3dPath,
  });

  final String id;
  final String name;
  final String model;
  final int price;
  final String owner;
  final String category;
  final String colorName;
  final Color color;
  final List<Color> colors;
  final String tagline;
  final String? model3dPath;
}