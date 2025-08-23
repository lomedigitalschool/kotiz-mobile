import 'package:flutter/material.dart';

class Pagebuilder extends StatelessWidget {
  const Pagebuilder({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFFFFFFF),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            spacing: 25,
            children: [
              SizedBox(
                child: Text(
                  softWrap: true,
                  textAlign: TextAlign.center,
                  title,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(
                width: 287,
                height: 241,
                child: Text(
                  maxLines: 3,
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
