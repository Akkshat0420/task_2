import 'package:flutter/material.dart';
import 'package:task_2/views/screens/detail_screen.dart';
import '../models/wallpaper_model.dart';

class WallpaperTile extends StatelessWidget {
  final Wallpaper wallpaper;
  final VoidCallback onTap;

  const WallpaperTile({super.key, required this.wallpaper, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(wallpaper: wallpaper),));},
      child: Container(
        
         decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: Colors.white,
      width: 3,
    ),),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            wallpaper.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}