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
            padding: const EdgeInsets.all(2),
            child: Icon(
              Icons.star,
              size: size,
              color: isActive ? activeColor : Colors.grey[300],
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
              rating > 0 ? '$rating/$maxRating' : 'Tap to rate',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: rating > 0 ? Colors.grey[600] : Colors.grey[400],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StarRatingWidget(
          rating: rating,
          maxRating: maxRating,
          onRatingChanged: onRatingChanged,
          enabled: enabled,
          size: 28,
        ),
      ],
    );
  }
}
