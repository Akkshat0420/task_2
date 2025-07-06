class Wallpaper {
  final String id;
  final String photographer;
  final String imageUrl;

  Wallpaper({required this.id, required this.photographer, required this.imageUrl});

  factory Wallpaper.fromJson(Map<String, dynamic> json) {
    return Wallpaper(
      id: json['id'].toString(),
      photographer: json['photographer'],
      imageUrl: json['src']['large2x'],
    );
  }
}
