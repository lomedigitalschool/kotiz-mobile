import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CagnotteTilesDashboard9 extends StatelessWidget {
  const CagnotteTilesDashboard9({
    super.key,
    this.image,
    required this.title,
    required this.poolId,
  });
  final String poolId;
  final String? image;
  final String title;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push("/poolDetails/$poolId"),
      child: Row(
        spacing: 8,
        children: [
          Card(
            child: Image.network(
              image!,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }
                return Container(
                  width: 100,
                  height: 100,
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (_, __, ___) => Image.asset(
                'assets/images/Logo.png',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              title,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
