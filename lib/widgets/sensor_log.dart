import 'package:flutter/material.dart';

class SensorLog extends StatelessWidget {
  final String log;

  const SensorLog({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Sensor Log', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Container(
            color: Colors.grey[200],
            child: ListTile(
              title: Text(log),
              subtitle: const Text('More details about the logs'),
            ),
          ),
        ],
      ),
    );
  }
}