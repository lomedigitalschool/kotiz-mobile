import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CagnotteTilesShimmer extends StatelessWidget {
  const CagnotteTilesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[200]!,
      child: SizedBox(
        height: 250,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(width: 160, height: 160, color: Colors.grey),
              ),
            ),
            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: SizedBox(
                width: 100,
                child: Container(height: 15, width: 50, color: Colors.grey),
              ),
            ),
            SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Container(height: 10, width: 30, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
