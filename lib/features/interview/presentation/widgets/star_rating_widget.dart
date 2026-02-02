import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Interactive star rating widget for evaluation
class StarRatingWidget extends StatelessWidget {
  final int rating;
  final int maxRating;
  final ValueChanged<int>? onRatingChanged;
  final bool enabled;
  final double size;
  final Color activeColor;
  final Color inactiveColor;

  const StarRatingWidget({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.onRatingChanged,
    this.enabled = true,
    this.size = 32.0,
    this.activeColor = AppColors.primary,
    this.inactiveColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        final starIndex = index + 1;
        final isActive = starIndex <= rating;

        return GestureDetector(
          onTap: enabled && onRatingChanged != null
              ? () => onRatingChanged!(starIndex)
              : null,
          child: Container(
            padding: const EdgeInsets.all(4),
            child: Icon(
              isActive ? Icons.star : Icons.star_border,
              size: size,
              color: isActive ? activeColor : inactiveColor,
            ),
          ),
        );
      }),
    );
  }
}

/// Star rating widget with label and rating display
class LabeledStarRating extends StatelessWidget {
  final String label;
  final int rating;
  final int maxRating;
  final ValueChanged<int>? onRatingChanged;
  final bool enabled;

  const LabeledStarRating({
    super.key,
    required this.label,
    required this.rating,
    this.maxRating = 5,
    this.onRatingChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            Text(
              '$rating/$maxRating',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        StarRatingWidget(
          rating: rating,
          maxRating: maxRating,
          onRatingChanged: onRatingChanged,
          enabled: enabled,
        ),
      ],
    );
  }
}
