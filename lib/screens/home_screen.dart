import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/dog.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Dog? currentDog;
  bool isLoading = false;
  String? errorMessage;
  String lastBreed = 'None yet';

  @override
  void initState() {
    super.initState();
    loadLastBreed();
  }

  Future<void> loadLastBreed() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      lastBreed = prefs.getString('lastBreed') ?? 'None yet';
    });
  }

  Future<void> fetchDog() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final dog = await ApiService.fetchRandomDog();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastBreed', dog.breed);

      setState(() {
        currentDog = dog;
        lastBreed = dog.breed;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Could not load a dog. Check your internet and try again.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> simulateError() async {
    setState(() {
      currentDog = null;
      errorMessage = 'Simulated error: the dog API failed to load.';
      isLoading = false;
    });
  }

  Future<void> saveDog() async {
    if (currentDog == null) return;

    await DatabaseService.insertDog(currentDog!);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${currentDog!.breed} saved to favorites!'),
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
      content = const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Fetching a random dog...'),
        ],
      );
    } else if (errorMessage != null) {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64),
          const SizedBox(height: 16),
          Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: fetchDog,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      );
    } else if (currentDog == null) {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.pets, size: 72),
          const SizedBox(height: 16),
          const Text(
            'Welcome to Dog Breed Diary!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Last viewed breed: ${formatBreed(lastBreed)}',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Press the button below to discover a random dog.',
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            formatBreed(currentDog!.breed),
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              currentDog!.imageUrl,
              height: 400,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: saveDog,
            icon: const Icon(Icons.favorite),
            label: const Text('Save Favorite'),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dog Breed Diary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(child: content),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'fetchDog',
            onPressed: fetchDog,
            icon: const Icon(Icons.pets),
            label: const Text('Fetch Dog'),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'errorDog',
            onPressed: simulateError,
            icon: const Icon(Icons.warning),
            label: const Text('Test Error'),
          ),
        ],
      ),
    );
  }
}