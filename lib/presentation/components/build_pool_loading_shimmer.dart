import 'package:flutter/material.dart';
import 'package:kotiz_app/presentation/components/cagnotte_tiles_shimmer.dart';

Widget buildPoolLoadingShimmer() => Column(
  children: [
    SizedBox(
      height: 250,
      child: ListView.builder(
        primary: false,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8),
          child: const CagnotteTilesShimmer(),
        ),
      ),
    ),
    const SizedBox(height: 10),
    SizedBox(
      height: 250,
      child: ListView.builder(
        primary: false,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8),
          child: const CagnotteTilesShimmer(),
        ),
      ),
    ),
  ],
);
