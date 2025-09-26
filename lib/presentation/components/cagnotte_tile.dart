import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CagnotteTile extends StatelessWidget {
  const CagnotteTile({
    super.key,
    this.image,
    required this.title,
    required this.currency,
    required this.amount,
    required this.poolId,
  });
  final String poolId;
  final String? image;
  final String title;
  final String currency;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push("/poolDetails/$poolId"),
      child: SizedBox(
        height: 250,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Image.network(
                image!,
                width: 160,
                height: 160,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Container(
                    width: 160,
                    height: 160,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/images/Logo.png',
                  width: 160,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 12),
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
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text("$amount $currency collectés"),
            ),
          ],
        ),
      ),
    );
  }
}
