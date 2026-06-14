import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'screens/home_screen.dart';
import 'screens/favorites_screen.dart';

void main() {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const FishExplorerApp());
}

class FishExplorerApp extends StatefulWidget {
  const FishExplorerApp({super.key});

  @override
  State<FishExplorerApp> createState() => _FishExplorerAppState();
}

class _FishExplorerAppState extends State<FishExplorerApp> {
  int currentIndex = 0;
  int favoritesRefreshKey = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      FavoritesScreen(key: ValueKey(favoritesRefreshKey)),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fish Explorer',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: Scaffold(
        body: screens[currentIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              currentIndex = index;

              if (index == 1) {
                favoritesRefreshKey++;
              }
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.set_meal),
              label: 'Browse',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
          ],
        ),
      ),
    );
  }
}