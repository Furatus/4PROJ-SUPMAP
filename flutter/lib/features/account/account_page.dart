import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supmap/providers/user_provider.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final pseudo = userProvider.userName ?? 'Utilisateur';
    final email = userProvider.userEmail ?? 'Email non disponible';
    final picture = userProvider.userPicture;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Compte'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).primaryColor,
              backgroundImage: picture != null ? NetworkImage(picture) : null,
              child: picture == null
                  ? Text(
                pseudo.isNotEmpty ? pseudo[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 40, color: Colors.white),
              )
                  : null,
            ),
            const SizedBox(height: 20),
            Text(
              pseudo,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              email,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Se déconnecter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                userProvider.removeUser();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}
