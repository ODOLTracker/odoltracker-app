import 'package:flutter/material.dart';

class ImageSection extends StatelessWidget {
  final String title;
  final Widget child;  // Images or Placeholder

  const ImageSection({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          child,  // You can pass images or placeholders here
        ],
      ),
    );
  }
}