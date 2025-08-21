import 'package:flutter/material.dart';

class CagnotteTile extends StatelessWidget {
  const CagnotteTile({
    super.key,
    required this.image,
    required this.title,
    required this.currency,
    required this.amount,
  });
  final String image;
  final String title;
  final String currency;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(child: Image.asset(image, width: 160, height: 160)),
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
            child: Text("$amount$currency atteint"),
          ),
        ],
      ),
    );
  }
}
