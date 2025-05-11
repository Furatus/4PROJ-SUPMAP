import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/user_provider.dart';
import '../../../utils/theme_notifier.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  String _distanceUnit = 'Kilomètres';

  @override
  void initState() {
    super.initState();
    _darkMode = themeNotifier.value == ThemeMode.dark;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<UserProvider>(
          builder: (context, userProvider, child) => ListView(
            children: [
              SettingCard(
                icon: Icons.dark_mode,
                title: 'Mode sombre',
                subtitle: 'Activez le mode sombre pour l\'application',
                trailing: Switch.adaptive(
                  value: _darkMode,
                  onChanged: (value) {
                    setState(() {
                      _darkMode = value;
                    });
                    final newTheme =
                    _darkMode ? ThemeMode.dark : ThemeMode.light;
                    themeNotifier.value = newTheme;
                    saveTheme(newTheme);
                  },
                ),
              ),
              const SizedBox(height: 12),
              SettingCard(
                icon: Icons.straighten,
                title: 'Unités de distance',
                subtitle: 'Choisissez l\'unité de distance préférée',
                trailing: DropdownButton<String>(
                  value: _distanceUnit,
                  borderRadius: BorderRadius.circular(12),
                  items: const ['Kilomètres', 'Miles'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _distanceUnit = newValue!;
                    });
                    // TODO: Appliquer le changement d'unités
                  },
                ),
              ),
              const SizedBox(height: 12),
              SettingCard(
                icon: Icons.toll,
                title: 'Utiliser les péages',
                subtitle:
                'Utiliser les routes à péage lors de la navigation',
                trailing: Switch.adaptive(
                  value: userProvider.useToll,
                  onChanged: userProvider.setUseToll,
                ),
              ),
              const SizedBox(height: 24),
              Card(
                color: Colors.red.shade50,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading:
                  const Icon(Icons.logout_rounded, color: Colors.red),
                  title: const Text(
                    'Déconnexion',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    userProvider.removeUser();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SettingCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  const SettingCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: trailing,
      ),
    );
  }
}
