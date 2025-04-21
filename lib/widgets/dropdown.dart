import 'package:flutter/material.dart';

class DropdownMenu extends StatelessWidget {
  final List<String> items;
  final String hint;
  final Function(String?) onChanged;

  const DropdownMenu({super.key, required this.items, required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      margin: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(color: Colors.grey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
          hint: Text(hint),
          isExpanded: true,
        ),
      ),
    );
  }
}