import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dog.dart';

class ApiService {
  static Future<Dog> fetchRandomDog() async {
    final response = await http.get(
      Uri.parse('https://dog.ceo/api/breeds/image/random'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load dog');
    }

    final data = jsonDecode(response.body);

    final imageUrl = data['message'];

    final breed = _extractBreed(imageUrl);

    return Dog(
      breed: breed,
      imageUrl: imageUrl,
      savedAt: DateTime.now().toString(),
    );
  }

  static String _extractBreed(String imageUrl) {
    final parts = imageUrl.split('/');

    final breedIndex = parts.indexOf('breeds');

    if (breedIndex != -1 && breedIndex + 1 < parts.length) {
      return parts[breedIndex + 1].replaceAll('-', ' ');
    }

    return 'Unknown Breed';
  }
}