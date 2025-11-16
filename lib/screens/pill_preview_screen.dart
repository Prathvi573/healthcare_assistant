import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class PillPreviewScreen extends StatefulWidget {
  final File imageFile;
  final bool isBlindUser;

  const PillPreviewScreen({
    super.key,
    required this.imageFile,
    required this.isBlindUser,
  });

  @override
  State<PillPreviewScreen> createState() => _PillPreviewScreenState();
}

class _PillPreviewScreenState extends State<PillPreviewScreen> {
  String prediction = "Processing...";
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    if (widget.isBlindUser) {
      _speak("Processing the pill image. Please wait.");
    }
    _simulateProcessing();
  }

  Future<void> _speak(String text) async {
    if (widget.isBlindUser) {
      await _tts.setLanguage("en-US");
      await _tts.setSpeechRate(0.5);
      await _tts.speak(text);
    }
  }

  Future<void> _simulateProcessing() async {
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      prediction = "Pill name will appear here";
    });

    if (widget.isBlindUser) {
      _speak("Processing complete.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pill Analysis"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.file(widget.imageFile, height: 260, fit: BoxFit.cover),
            const SizedBox(height: 20),

            Card(
              elevation: 5,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text("Prediction",
                        style:
                            TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(
                      prediction,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
