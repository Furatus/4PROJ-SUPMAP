import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ValueNotifier pour gérer le thème
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
final FlutterSecureStorage _storage = const FlutterSecureStorage();

Future<void> loadTheme() async {
  final theme = await _storage.read(key: 'theme');
  themeNotifier.value = theme == 'dark' ? ThemeMode.dark : ThemeMode.light;
}

Future<void> saveTheme(ThemeMode theme) async {
  await _storage.write(key: 'theme', value: theme == ThemeMode.dark ? 'dark' : 'light');
}
