import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final int starCount;
  final double size;
  final bool showLabel;

  const RatingStars({
    super.key,
    required this.rating,
    this.starCount = 5,
    this.size = 16,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final fullStars = rating.floor();
    final hasHalfStar = rating - fullStars >= 0.5;
    final emptyStars = starCount - fullStars - (hasHalfStar ? 1 : 0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Full stars
        ...List.generate(fullStars, (index) => Icon(Icons.star, size: size, color: Colors.amber)),
        
        // Half star
        if (hasHalfStar) Icon(Icons.star_half, size: size, color: Colors.amber),
        
        // Empty stars
        ...List.generate(emptyStars, (index) => Icon(Icons.star_border, size: size, color: Colors.amber)),
        
        if (showLabel) ...[
          const SizedBox(width: 8),
          Text(
            rating.toString(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}