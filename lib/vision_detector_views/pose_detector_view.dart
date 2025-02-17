// Importing necessary packages
import 'package:camera/camera.dart'; // For camera functionalities
import 'package:flutter/cupertino.dart'; // For Cupertino widgets
import 'package:flutter/material.dart'; // For Material Design widgets
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart'; // For pose detection

// Importing custom files
import 'detector_view.dart'; // Custom detector view widget
import 'painters/pose_painter.dart'; // Custom painter for drawing poses

// Defining a stateful widget for pose detection view
class PoseDetectorView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() =>
      _PoseDetectorViewState(); // Creating state for the widget
}

// State class for PoseDetectorView
class _PoseDetectorViewState extends State<PoseDetectorView> {
  // Initializing pose detector with default options
  final PoseDetector _poseDetector =
      PoseDetector(options: PoseDetectorOptions());
  bool _canProcess = true; // Flag to check if processing can be done
  bool _isBusy = false; // Flag to check if processing is ongoing
  CustomPaint? _customPaint; // Custom painter for drawing poses
  String? _text; // Text to display pose information
  var _cameraLensDirection =
      CameraLensDirection.back; // Initial camera lens direction

  // Overriding dispose method to clean up resources
  @override
  void dispose() async {
    _canProcess = false; // Stop processing
    _poseDetector.close(); // Close pose detector
    super.dispose(); // Call super dispose
  }

  // Building the widget tree
  @override
  Widget build(BuildContext context) {
    return DetectorView(
      title: 'Pose Detector', // Title of the detector view
      customPaint: _customPaint, // Custom painter for drawing poses
      text: _text, // Text to display pose information
      onImage: _processImage, // Callback to process image
      initialCameraLensDirection:
          _cameraLensDirection, // Initial camera lens direction
      onCameraLensDirectionChanged: (value) => _cameraLensDirection =
          value, // Callback for camera lens direction change
    );
  }

  // Method to process the input image
  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return; // Return if processing is not allowed
    if (_isBusy) return; // Return if already processing
    _isBusy = true; // Set busy flag to true
    setState(() {
      _text = ''; // Clear text
    });
    final poses = await _poseDetector
        .processImage(inputImage); // Process image to detect poses
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      // If image metadata is available
      final painter = PosePainter(
        poses, // Detected poses
        inputImage.metadata!.size, // Image size
        inputImage.metadata!.rotation, // Image rotation
        _cameraLensDirection, // Camera lens direction
      );
      _customPaint =
          CustomPaint(painter: painter); // Set custom painter to draw poses
    } else {
      _text =
          'Poses found: ${poses.length}\n\n'; // Set text with number of poses found
      // TODO: set _customPaint to draw landmarks on top of image
      _customPaint = null; // Clear custom painter
    }
    _isBusy = false; // Set busy flag to false
    if (mounted) {
      setState(() {}); // Update state if widget is mounted
    }
  }
}
