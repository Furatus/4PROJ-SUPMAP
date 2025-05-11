import 'package:flutter/material.dart';

class RouteInstructionsWidget extends StatelessWidget {
  final Map<String, dynamic> maneuver;
  final String distance;


  const RouteInstructionsWidget({
    super.key,
    required this.maneuver,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.teal,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                maneuver.containsKey('exited')
                    ? Icons.sync_rounded
                    : getGraphHopperIcon(maneuver['sign']),
                color: Colors.white,
                size: 80,
              ),
              if (maneuver.containsKey('exited'))
                CircleAvatar(
                  radius: 15,
                  child: Text(
                    maneuver['exit_number'].toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
            ],
          ),

          // Texte des instructions
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  distance,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 28,
                  ),
                ),
                Text(
                  maneuver['text'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis, // Ajoute "..." si trop long
                ),
              ],
            ),
          ),

          // Icône de fermeture avec fond rouge
          Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(6),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/');
              },
              child: const Icon(Icons.close, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  IconData getGraphHopperIcon(int sign) {
    switch (sign) {
    // U‑turns
      case -98:          // U‑turn (sens inconnu)
        return Icons.u_turn_left_rounded;   // pictogramme générique
      case -8:           // U‑turn gauche
        return Icons.u_turn_left_rounded;
      case 8:            // U‑turn droite
        return Icons.u_turn_right_rounded;

    // Keep left / right
      case -7:           // keep left
        return Icons.turn_slight_left_rounded;
      case 7:            // keep right
        return Icons.turn_slight_right_rounded;

    // Sharp / normal / slight LEFT
      case -3:           // sharp left
        return Icons.turn_sharp_left_rounded;
      case -2:           // left
        return Icons.turn_left_rounded;
      case -1:           // slight left
        return Icons.turn_slight_left_rounded;

    // Continue straight
      case 0:            // continue on street
        return Icons.straight_rounded;

    // Slight / normal / sharp RIGHT
      case 1:            // slight right
        return Icons.turn_slight_right_rounded;
      case 2:            // right
        return Icons.turn_right_rounded;
      case 3:            // sharp right
        return Icons.turn_sharp_right_rounded;

    // Special points
      case 4:            // finish instruction (avant destination)
        return Icons.flag_rounded;
      case 5:            // via point
        return Icons.place_rounded;

    // Roundabout
      case 6:            // enter roundabout
        return Icons.sync_rounded;
      default:
        return Icons.navigation;            // par défaut
    }
  }

}
