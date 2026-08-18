import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import '../utils/constants.dart';
import '../data/mock_data.dart';

class CameraRecognitionScreen extends StatefulWidget {
  const CameraRecognitionScreen({super.key});

  @override
  State<CameraRecognitionScreen> createState() => _CameraRecognitionScreenState();
}

class _CameraRecognitionScreenState extends State<CameraRecognitionScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isSimulatingScan = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      _controller = CameraController(cameras[0], ResolutionPreset.max);
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _simulateProductScan() {
    setState(() {
      _isSimulatingScan = true;
    });

    // Simulate AI inference delay (YOLO + OCR)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isSimulatingScan = false;
        });
        // Navigate to the first mock product
        final productId = MockData.products.first.id;
        context.push('/productdetails/$productId');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan Product'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Camera Preview or Fallback
          if (_isCameraInitialized && _controller != null)
            SizedBox.expand(child: CameraPreview(_controller!))
          else
            const Center(
              child: Icon(Icons.camera_alt, size: 100, color: Colors.white24),
            ),
            
          // Scanning overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isSimulatingScan ? Colors.greenAccent : Colors.white54,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: _isSimulatingScan
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.greenAccent),
                    )
                  : null,
            ),
          ),
          
          // Instructions
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                const Text(
                  'Center the product in the frame',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _isSimulatingScan ? null : _simulateProductScan,
                  icon: const Icon(Icons.search),
                  label: const Text('Identify Product'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
