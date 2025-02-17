// Importing necessary Dart and Flutter packages
import 'dart:io'; // Provides access to platform-specific information
import 'package:camera/camera.dart'; // Camera package for capturing images
import 'package:flutter/material.dart'; // Flutter framework for building UI
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart'; // ML Kit package for face mesh detection

// Importing local files
import 'detector_view.dart'; // Custom widget for displaying the detector view
import 'painters/face_mesh_detector_painter.dart'; // Custom painter for drawing face meshes

// Defining a stateful widget for the face mesh detector view
class FaceMeshDetectorView extends StatefulWidget {
  @override
  State<FaceMeshDetectorView> createState() =>
      _FaceMeshDetectorViewState(); // Creating the state for this widget
}

// State class for FaceMeshDetectorView
class _FaceMeshDetectorViewState extends State<FaceMeshDetectorView> {
  // Initializing the face mesh detector with specific options
  final FaceMeshDetector _meshDetector =
      FaceMeshDetector(option: FaceMeshDetectorOptions.faceMesh);
  bool _canProcess = true; // Flag to control if processing is allowed
  bool _isBusy = false; // Flag to indicate if the detector is currently busy
  CustomPaint? _customPaint; // Custom painter for drawing on the canvas
  String? _text; // Text to display face mesh information
  var _cameraLensDirection =
      CameraLensDirection.front; // Initial camera lens direction

  // Overriding the dispose method to clean up resources
  @override
  void dispose() {
    _canProcess = false; // Stop processing
    _meshDetector.close(); // Close the face mesh detector
    super.dispose(); // Call the superclass dispose method
  }

  // Building the widget tree
  @override
  Widget build(BuildContext context) {
    // Check if the platform is iOS
    if (Platform.isIOS) {
      return Scaffold(
        appBar: AppBar(
            title:
                Text('Under construction')), // Display an app bar with a title
        body: Center(
            child: Text(
          'Not implemented yet for iOS :(\nTry Android', // Display a message for iOS users
          textAlign: TextAlign.center, // Center align the text
        )),
      );
    }
    // Return the detector view for non-iOS platforms
    return DetectorView(
      title: 'Face Mesh Detector', // Title of the detector view
      customPaint: _customPaint, // Custom painter for drawing face meshes
      text: _text, // Text to display face mesh information
      onImage: _processImage, // Callback to process the image
      initialCameraLensDirection:
          _cameraLensDirection, // Initial camera lens direction
      onCameraLensDirectionChanged: (value) => _cameraLensDirection =
          value, // Callback to change camera lens direction
    );
  }

  // Method to process the input image
  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return; // Return if processing is not allowed
    if (_isBusy) return; // Return if the detector is busy
    _isBusy = true; // Set the busy flag to true
    setState(() {
      _text = ''; // Clear the text
    });
    final meshes = await _meshDetector
        .processImage(inputImage); // Process the image to detect face meshes
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      final painter = FaceMeshDetectorPainter(
        meshes, // Detected face meshes
        inputImage.metadata!.size, // Size of the input image
        inputImage.metadata!.rotation, // Rotation of the input image
        _cameraLensDirection, // Camera lens direction
      );
      _customPaint = CustomPaint(
          painter: painter); // Set the custom painter to draw face meshes
    } else {
      String text =
          'Face meshes found: ${meshes.length}\n\n'; // Display the number of face meshes found
      for (final mesh in meshes) {
        text +=
            'face: ${mesh.boundingBox}\n\n'; // Display the bounding box of each face mesh
      }
      _text = text; // Set the text to display face mesh information
      // TODO: set _customPaint to draw boundingRect on top of image
      _customPaint = null; // Clear the custom painter
    }
    _isBusy = false; // Set the busy flag to false
    if (mounted) {
      setState(() {}); // Update the state if the widget is still mounted
    }
  }
}
