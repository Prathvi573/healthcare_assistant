import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../pill_preview_screen.dart';

class PillCaptureScreen extends StatefulWidget {
  const PillCaptureScreen({super.key});

  @override
  State<PillCaptureScreen> createState() => _PillCaptureScreenState();
}

class _PillCaptureScreenState extends State<PillCaptureScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _openCamera() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);

    if (image != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PillPreviewScreen(
            imageFile: File(image.path),
            isBlindUser: false,
          ),
        ),
      );
    }
  }

  Future<void> _openGallery() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);

    if (image != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PillPreviewScreen(
            imageFile: File(image.path),
            isBlindUser: false,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pill Recognition")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.medication_liquid,
                size: 110, color: Colors.teal),
            const SizedBox(height: 30),

            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text("Capture with Camera"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _openCamera,
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              icon: const Icon(Icons.photo_library),
              label: const Text("Choose from Gallery"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _openGallery,
            ),
          ],
        ),
      ),
    );
  }
}
