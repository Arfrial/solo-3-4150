import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../models/fish.dart';

class ApiService {
  static Future<Fish> fetchRandomFish() async {
    final response = await http.get(
      Uri.parse('https://www.fishwatch.gov/api/species'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load fish');
    }

    final List<dynamic> data = jsonDecode(response.body);

    if (data.isEmpty) {
      throw Exception('No fish found');
    }

    final randomFish = data[Random().nextInt(data.length)];

    final name = randomFish['Species Name'] ?? 'Unknown Fish';

    String imageUrl = '';

    if (randomFish['Species Illustration Photo'] != null &&
        randomFish['Species Illustration Photo']['src'] != null) {
      imageUrl = randomFish['Species Illustration Photo']['src'];
    } else if (randomFish['Image Gallery'] != null &&
        randomFish['Image Gallery'] is List &&
        randomFish['Image Gallery'].isNotEmpty &&
        randomFish['Image Gallery'][0]['src'] != null) {
      imageUrl = randomFish['Image Gallery'][0]['src'];
    }

    if (imageUrl.isEmpty) {
      imageUrl = 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/13/No_image_available.svg/640px-No_image_available.svg.png';
    }

    return Fish(
      name: name,
      imageUrl: imageUrl,
      savedAt: DateTime.now().toString(),
    );
  }
}