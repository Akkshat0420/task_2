import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:task_2/models/wallpaper_model.dart';

class DetailScreen extends StatelessWidget {
  final Wallpaper wallpaper;

  const DetailScreen({super.key, required this.wallpaper});

 Future<void> _downloadImage(BuildContext context, String imageUrl) async {
  try {
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission denied')),
      );
      return;
    }

    // Download the image using Dio
    final response = await Dio().get(
      imageUrl,
      options: Options(responseType: ResponseType.bytes),
    );

    // Save to a temporary file
     final tempDir = await getTemporaryDirectory();
      final fileName = "wallpaper_${DateTime.now().millisecondsSinceEpoch}.jpg";
      final filePath = '${tempDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(response.data);

   
    final mediaStore = MediaStore();
    await mediaStore.saveFile(
      tempFilePath: filePath,
        dirType: DirType.photo,
        dirName: DirName.dcim,
      relativePath: 'Pictures/Wallpapers',
     
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image saved to gallery!')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Download failed: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Image.network(
              wallpaper.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : const CircularProgressIndicator(),
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () => _downloadImage(context, wallpaper.imageUrl),
                child: const Text("Download Image"),
              ),
            ),
          )
        ],
      ),
    );
  }
}
