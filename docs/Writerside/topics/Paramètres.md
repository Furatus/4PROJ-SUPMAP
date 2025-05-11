# Paramètres



###### Mode sombre

**Description** : Permet à l'utilisateur d'activer ou désactiver le mode sombre de l'application.

**Stockage** : Change la valeur du themeNotifier (gestionnaire global de thème), et sauvegarde ce choix via saveTheme(...).

```dart
ListTile(
    leading: const Icon(Icons.dark_mode),
    title: const Text('Mode sombre'),
    subtitle: const Text('Activez le mode sombre pour l\'application'),
    trailing: Switch(
      value: _darkMode,
      onChanged: (value) {
        setState(() {
          _darkMode = value;
        });
        final newTheme = _darkMode ? ThemeMode.dark : ThemeMode.light;
        themeNotifier.value = newTheme;
        saveTheme(newTheme);
      },
    ),
)
```

###### Unités de distance
**Description** : L'utilisateur peut choisir entre les "Kilomètres" ou les "Miles" comme unité de mesure des distances (utile pour l'affichage sur cartes, navigation...).

```dart
ListTile(
    leading: const Icon(Icons.straighten),
    title: const Text('Unités de distance'),
    subtitle: const Text('Choisissez l\'unité de distance préférée'),
    trailing: DropdownButton<String>(
      value: _distanceUnit,
      items: <String>['Kilomètres', 'Miles'].map((String value) {
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
)
```

###### Éviter les péages
**Description** : Active ou désactive l’option de navigation évitant les routes à péage.

```dart
ListTile(
    leading: const Icon(Icons.toll),
    title: const Text('Éviter les péages'),
    subtitle:
        const Text('Évitez les routes à péage lors de la navigation'),
    trailing: Switch(
      value: _avoidTolls,
      onChanged: (value) {
        setState(() {
          _avoidTolls = value;
        });
        // TODO: Appliquer la préférence d'évitement des péages
      },
    ),
  )
```