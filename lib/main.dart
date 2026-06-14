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

  runApp(const DogBreedDiaryApp());
}

class DogBreedDiaryApp extends StatefulWidget {
  const DogBreedDiaryApp({super.key});

  @override
  State<DogBreedDiaryApp> createState() => _DogBreedDiaryAppState();
}

class _DogBreedDiaryAppState extends State<DogBreedDiaryApp> {
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
      title: 'Dog Breed Diary',
      theme: ThemeData(
        colorSchemeSeed: Colors.brown,
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
              icon: Icon(Icons.pets),
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