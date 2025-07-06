import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:task_2/utils/constant.dart';
import '../models/wallpaper_model.dart';
//import 'task_2/utils/constant.dart';

class ApiService {
  final http.Client client;
  ApiService({http.Client? client}) : client = client ?? http.Client();

  Future<List<Wallpaper>> fetchWallpapers({int page = 1}) async {
    final response = await client.get(
      Uri.parse('${baseUrl}curated?page=$page&per_page=20'),
      headers: {'Authorization': pexelsApiKey},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['photos'] as List).map((e) => Wallpaper.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load wallpapers');
    }
  }

  Future<List<Wallpaper>> searchWallpapers(String query, {int page = 1}) async {
    final response = await client.get(
      Uri.parse('${baseUrl}search?query=$query&page=$page&per_page=20'),
      headers: {'Authorization': pexelsApiKey},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['photos'] as List).map((e) => Wallpaper.fromJson(e)).toList();
    } else {
      throw Exception('Failed to search wallpapers');
    }
  }


   Future<String?> fetchCategoryImage(String category) async {
    final url = Uri.parse('https://api.pexels.com/v1/search?query=$category&per_page=1');

    final response = await http.get(url, headers: {
      'Authorization': pexelsApiKey,
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final photos = data['photos'];
      if (photos != null && photos.isNotEmpty) {
        return photos[0]['src']['portrait'];
      }
    }
    return null;
  }

   Future<List<Wallpaper>> fetchWallpapersByCategory(String category) async {
    final url = Uri.parse('$baseUrl/search?query=$category&per_page=40');

    final response = await http.get(
      url,
      headers: {
        'Authorization': pexelsApiKey,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List photos = data['photos'];
      return photos.map((json) => Wallpaper.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load wallpapers for $category');
    }
  }
}
