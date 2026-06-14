import 'package:flutter/material.dart';

import '../models/fish.dart';
import '../services/database_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Fish> savedFish = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSavedFish();
  }

  Future<void> loadSavedFish() async {
    try {
      final fish = await DatabaseService.getFish();

      setState(() {
        savedFish = fish;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        savedFish = [];
        isLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Database error: $e'),
        ),
      );
    }
  }

  Future<void> deleteFish(Fish fish) async {
    if (fish.id == null) return;

    await DatabaseService.deleteFish(fish.id!);
    await loadSavedFish();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${fish.name} deleted.'),
      ),
    );
  }

  Future<void> clearAllFish() async {
    await DatabaseService.clearAllFish();
    await loadSavedFish();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All saved fish cleared.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    } else if (savedFish.isEmpty) {
      content = const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_border, size: 72),
              SizedBox(height: 16),
              Text(
                'No saved fish yet.',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Fetch a fish on the Browse screen and save it here.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    } else {
      content = ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: savedFish.length,
        itemBuilder: (context, index) {
          final fish = savedFish[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  fish.imageUrl,
                  width: 70,
                  height: 70,
                  fit: BoxFit.contain,
                ),
              ),
              title: Text(
                fish.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Saved: ${fish.savedAt.substring(0, 16)}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => deleteFish(fish),
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Fish'),
        actions: [
          if (savedFish.isNotEmpty)
            IconButton(
              tooltip: 'Clear All',
              icon: const Icon(Icons.delete_sweep),
              onPressed: clearAllFish,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadSavedFish,
        child: content,
      ),
    );
  }
}