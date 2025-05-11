import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BottomInstructionsBarWidget extends StatelessWidget {
  final int currentSpeed;
  final String totalRemainingDistance;
  final DateTime estimatedArrivalTime;
  final int totalRemainingTime; // En minutes

  const BottomInstructionsBarWidget({
    super.key,
    required this.currentSpeed,
    required this.totalRemainingDistance,
    required this.estimatedArrivalTime,
    required this.totalRemainingTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
      decoration: BoxDecoration(
        color: Colors.lightBlue.shade700, // Bleu plus moderne
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 📍 **Bloc gauche : Distance restante et durée estimée**
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.directions_car, color: Colors.white70, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    totalRemainingDistance,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.access_time_filled,
                      color: Colors.white70, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    formatDuration(totalRemainingTime),
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 🚀 **Bloc central : Limite de vitesse**
          Column(
            children: [
              Text(
                '$currentSpeed',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'KM/H',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // ⏳ **Bloc droit : Heure d’arrivée prévue**
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Arrivée',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.schedule, color: Colors.greenAccent, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat.Hm().format(estimatedArrivalTime.toLocal()),
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🕒 **Formate la durée en "2h 15m" ou "15m" si moins d'une heure**
  String formatDuration(int duration) {
    final int hours = duration ~/ 60;
    final int minutes = duration % 60;

    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
    } else {
      return '$minutes min';
    }
  }
}
