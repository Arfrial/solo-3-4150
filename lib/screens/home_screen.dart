import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/fish.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Fish? currentFish;
  bool isLoading = false;
  String? errorMessage;
  String lastFish = 'None yet';

  @override
  void initState() {
    super.initState();
    loadLastFish();
  }

  Future<void> loadLastFish() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      lastFish = prefs.getString('lastFish') ?? 'None yet';
    });
  }

  Future<void> fetchFish() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final fish = await ApiService.fetchRandomFish();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastFish', fish.name);

      setState(() {
        currentFish = fish;
        lastFish = fish.name;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Could not load a fish. Check your internet and try again.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> simulateError() async {
    setState(() {
      currentFish = null;
      errorMessage = 'Simulated error: the fish API failed to load.';
      isLoading = false;
    });
  }

  Future<void> saveFish() async {
    if (currentFish == null) return;

    await DatabaseService.insertFish(currentFish!);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${currentFish!.name} saved to favorites!'),
      ),
    );
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
          Text('Fetching a random fish...'),
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
            onPressed: fetchFish,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      );
    } else if (currentFish == null) {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.set_meal, size: 72),
          const SizedBox(height: 16),
          const Text(
            'Welcome to Fish Explorer!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Last viewed fish: $lastFish',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Press the button below to discover a random fish species.',
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else {
      content = SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              currentFish!.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                currentFish!.imageUrl,
                height: 400,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: saveFish,
              icon: const Icon(Icons.favorite),
              label: const Text('Save Favorite'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fish Explorer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(child: content),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'fetchFish',
            onPressed: fetchFish,
            icon: const Icon(Icons.set_meal),
            label: const Text('Fetch Fish'),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'errorFish',
            onPressed: simulateError,
            icon: const Icon(Icons.warning),
            label: const Text('Test Error'),
          ),
        ],
      ),
    );
  }
}