import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../pill_preview_screen.dart';

class PillCaptureScreen extends StatefulWidget {
  const PillCaptureScreen({super.key});

  @override
  State<PillCaptureScreen> createState() => _PillCaptureScreenState();
}

class _PillCaptureScreenState extends State<PillCaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _speak("Pill recognition opened. Choose camera or gallery.");
  }

  Future<void> _speak(String text) async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
    await _tts.speak(text);
  }

  Future<void> _openCamera() async {
    _speak("Opening camera.");

    final XFile? image =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);

    if (image != null) {
      _speak("Image captured. Processing.");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PillPreviewScreen(
            imageFile: File(image.path),
            isBlindUser: true,
          ),
        ),
      );
    }
  }

  Future<void> _openGallery() async {
    _speak("Opening gallery.");

    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);

    if (image != null) {
      _speak("Image selected. Processing.");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PillPreviewScreen(
            imageFile: File(image.path),
            isBlindUser: true,
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
