// Import necessary packages
import 'package:camera/camera.dart'; // For camera functionalities
import 'package:flutter/material.dart'; // For Flutter UI components
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart'; // For face detection

// Import custom components
import 'detector_view.dart'; // Custom detector view widget
import 'painters/face_detector_painter.dart'; // Custom painter for face detection

// Define a stateful widget for face detection view
class FaceDetectorView extends StatefulWidget {
  @override
  State<FaceDetectorView> createState() =>
      _FaceDetectorViewState(); // Create state for the widget
}

// Define the state class for FaceDetectorView
class _FaceDetectorViewState extends State<FaceDetectorView> {
  // Initialize the face detector with specific options
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true, // Enable face contours detection
      enableLandmarks: true, // Enable face landmarks detection
    ),
  );
  bool _canProcess = true; // Flag to check if processing is allowed
  bool _isBusy = false; // Flag to check if processing is ongoing
  CustomPaint? _customPaint; // Custom painter for drawing on the canvas
  String? _text; // Text to display detected face information
  var _cameraLensDirection =
      CameraLensDirection.front; // Initial camera lens direction

  @override
  void dispose() {
    _canProcess = false; // Stop processing when disposing
    _faceDetector.close(); // Close the face detector
    super.dispose(); // Call the superclass dispose method
  }

  @override
  Widget build(BuildContext context) {
    // Build the UI for the face detector view
    return DetectorView(
      title: 'Face Detector', // Title of the view
      customPaint: _customPaint, // Custom painter for drawing faces
      text: _text, // Text to display face information
      onImage: _processImage, // Callback to process the image
      initialCameraLensDirection:
          _cameraLensDirection, // Initial camera lens direction
      onCameraLensDirectionChanged: (value) =>
          _cameraLensDirection = value, // Update camera lens direction
    );
  }

  // Method to process the input image
  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return; // Return if processing is not allowed
    if (_isBusy) return; // Return if already processing
    _isBusy = true; // Set busy flag to true
    setState(() {
      _text = ''; // Clear the text
    });
    final faces = await _faceDetector
        .processImage(inputImage); // Detect faces in the image
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      // If image metadata is available
      final painter = FaceDetectorPainter(
        faces, // Detected faces
        inputImage.metadata!.size, // Image size
        inputImage.metadata!.rotation, // Image rotation
        _cameraLensDirection, // Camera lens direction
      );
      _customPaint = CustomPaint(painter: painter); // Set custom painter
    } else {
      // If metadata is not available
      String text =
          'Faces found: ${faces.length}\n\n'; // Display number of faces found
      for (final face in faces) {
        text +=
            'face: ${face.boundingBox}\n\n'; // Display bounding box of each face
      }
      _text = text; // Set the text
      // TODO: set _customPaint to draw boundingRect on top of image
      _customPaint = null; // No custom painter
    }
    _isBusy = false; // Reset busy flag
    if (mounted) {
      setState(() {}); // Update the UI if the widget is still mounted
    }
  }
}
