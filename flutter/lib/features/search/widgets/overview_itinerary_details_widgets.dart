import 'package:flutter/material.dart';

class OverviewItineraryDetailsWidgets extends StatelessWidget {
  const OverviewItineraryDetailsWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/navigation', arguments: {
                'lat': 48.8588443,
                'lon': 2.2943506,
              });
            },
            child: const Text('Start Navigation'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/settings');
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }
}
