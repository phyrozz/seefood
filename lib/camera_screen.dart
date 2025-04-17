import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:seefood/result.dart';
import 'package:seefood/main.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      cameras[0], // Use the first available camera
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(imagePath: image.path),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SeeFood', style: TextStyle(fontWeight: FontWeight.bold)), centerTitle: true,),
      body: Column(
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(_controller);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'Capture your food and let SeeFood identify it!',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              IconButton.filled(onPressed: _takePicture, icon: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.camera_alt, size: 40),
              )),
            ],
          ),
        ],
      ),
    );
  }
}
