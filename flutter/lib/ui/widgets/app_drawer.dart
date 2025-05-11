import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supmap/providers/user_provider.dart';
import 'package:supmap/ui/widgets/snackbar_info.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    return Column(
                      children: [
                        if (userProvider.isLogged && userProvider.userPicture != null)
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(userProvider.userPicture!),
                            backgroundColor: Colors.grey[200],
                          )
                        else
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey[300],
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey[600],
                            ),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          userProvider.isLogged
                              ? 'Bonjour, ${userProvider.userName}'
                              : 'Bienvenue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          userProvider.isLogged
                              ? '${userProvider.userEmail}'
                              : 'Connectez-vous',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          Divider(
            color: Colors.grey[300],
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              if (userProvider.isLogged) {
                return Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.account_circle_rounded,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text(
                        'Mon compte',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/account');
                      },
                    ),
                    Divider(
                      color: Colors.grey[300],
                      thickness: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.settings_rounded,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text(
                        'Paramètres',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/settings');
                      },
                    ),
                    Divider(
                      color: Colors.grey[300],
                      thickness: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.logout_rounded,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text(
                        'Déconnexion',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      onTap: () {
                        // Code de déconnexion
                        userProvider.removeUser(); // Effacer l'utilisateur
                        Navigator.pop(context);
                        SnackbarInfo.show(
                          context,
                          'Vous êtes déconnecté avec succès',
                           2,
                        );
                      },
                    ),

                  ],
                );
              } else {
                return ListTile(
                  leading: Icon(
                    Icons.login_rounded,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(
                    'Connexion',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/login');
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
