/// # Kategorifilter-chip
///
/// Ett litet valbart chip för toppen av feeden. Visar kategorinamnet med
/// en färgmarkerad kant och bakgrund beroende på om det är valt.
library;

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/post.dart';

class CategoryChip extends StatelessWidget {
  final WpCategory category;
  final bool selected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = category.color;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(category.name),
        selected: selected,
        onSelected: (_) => onTap(),
        labelStyle: TextStyle(
          color: selected ? Colors.white : color,
          fontWeight: FontWeight.w600,
        ),
        selectedColor: color,
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: color, width: 1.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),
    );
  }
}
