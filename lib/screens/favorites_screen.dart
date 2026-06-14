import 'package:flutter/material.dart';

import '../models/dog.dart';
import '../services/database_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Dog> savedDogs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSavedDogs();
  }

  Future<void> loadSavedDogs() async {
    final dogs = await DatabaseService.getDogs();

    setState(() {
      savedDogs = dogs;
      isLoading = false;
    });
  }

  Future<void> deleteDog(Dog dog) async {
    if (dog.id == null) return;

    await DatabaseService.deleteDog(dog.id!);
    await loadSavedDogs();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${formatBreed(dog.breed)} deleted.'),
      ),
    );
  }

  Future<void> clearAllDogs() async {
    await DatabaseService.clearAllDogs();
    await loadSavedDogs();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All saved dogs cleared.'),
      ),
    );
  }

  String formatBreed(String breed) {
    return breed
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    } else if (savedDogs.isEmpty) {
      content = const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_border, size: 72),
              SizedBox(height: 16),
              Text(
                'No saved dogs yet.',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Fetch a dog on the Browse screen and save it here.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    } else {
      content = ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: savedDogs.length,
        itemBuilder: (context, index) {
          final dog = savedDogs[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  dog.imageUrl,
                  width: 70,
                  height: 70,
                  fit: BoxFit.contain,
                ),
              ),
              title: Text(
                formatBreed(dog.breed),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Saved: ${dog.savedAt.substring(0, 16)}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => deleteDog(dog),
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Dogs'),
        actions: [
          if (savedDogs.isNotEmpty)
            IconButton(
              tooltip: 'Clear All',
              icon: const Icon(Icons.delete_sweep),
              onPressed: clearAllDogs,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadSavedDogs,
        child: content,
      ),
    );
  }
}