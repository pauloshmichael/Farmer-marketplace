import 'package:flutter/material.dart';

extension CategoryExtension on String {
  IconData getCategoryIcon() {
    const icons = {
      'All': Icons.apps,
      'Vegetables': Icons.eco,
      'Fruits': Icons.apple,
      'Grains': Icons.grass,
      'Dairy': Icons.emoji_food_beverage,
      'Meat': Icons.restaurant,
      'Organic': Icons.spa,
      'Seeds': Icons.nature,
      'Equipment': Icons.build,
    };
    return icons[this] ?? Icons.category;
  }
}