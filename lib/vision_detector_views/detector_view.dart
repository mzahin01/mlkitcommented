// Importing necessary packages
import 'package:camera/camera.dart'; // For camera functionalities
import 'package:flutter/material.dart'; // For Flutter UI components
import 'package:google_mlkit_commons/google_mlkit_commons.dart'; // For Google ML Kit functionalities

// Importing custom views
import 'camera_view.dart'; // Custom camera view
import 'gallery_view.dart'; // Custom gallery view

// Enum to define the modes of the detector view
enum DetectorViewMode { liveFeed, gallery }

// Stateful widget for the detector view
class DetectorView extends StatefulWidget {
  // Constructor for the DetectorView widget
  DetectorView({
    Key? key, // Optional key for the widget
    required this.title, // Title of the view
    required this.onImage, // Callback function when an image is detected
    this.customPaint, // Optional custom paint for the view
    this.text, // Optional text to display
    this.initialDetectionMode =
        DetectorViewMode.liveFeed, // Initial mode of the detector view
    this.initialCameraLensDirection =
        CameraLensDirection.back, // Initial camera lens direction
    this.onCameraFeedReady, // Callback when the camera feed is ready
    this.onDetectorViewModeChanged, // Callback when the detector view mode changes
    this.onCameraLensDirectionChanged, // Callback when the camera lens direction changes
  }) : super(key: key); // Calling the superclass constructor

  // Defining the properties of the DetectorView widget
  final String title;
  final CustomPaint? customPaint;
  final String? text;
  final DetectorViewMode initialDetectionMode;
  final Function(InputImage inputImage) onImage;
  final Function()? onCameraFeedReady;
  final Function(DetectorViewMode mode)? onDetectorViewModeChanged;
  final Function(CameraLensDirection direction)? onCameraLensDirectionChanged;
  final CameraLensDirection initialCameraLensDirection;

  // Creating the state for the DetectorView widget
  @override
  State<DetectorView> createState() => _DetectorViewState();
}

// State class for the DetectorView widget
class _DetectorViewState extends State<DetectorView> {
  // Variable to hold the current mode of the detector view
  late DetectorViewMode _mode;

  // Initializing the state
  @override
  void initState() {
    _mode = widget.initialDetectionMode; // Setting the initial mode
    super.initState(); // Calling the superclass initState method
  }

  // Building the widget tree
  @override
  Widget build(BuildContext context) {
    // Returning the appropriate view based on the current mode
    return _mode == DetectorViewMode.liveFeed
        ? CameraView(
            customPaint: widget.customPaint, // Passing custom paint
            onImage: widget.onImage, // Passing the onImage callback
            onCameraFeedReady: widget
                .onCameraFeedReady, // Passing the onCameraFeedReady callback
            onDetectorViewModeChanged:
                _onDetectorViewModeChanged, // Passing the mode change callback
            initialCameraLensDirection: widget
                .initialCameraLensDirection, // Passing the initial camera lens direction
            onCameraLensDirectionChanged: widget
                .onCameraLensDirectionChanged, // Passing the lens direction change callback
          )
        : GalleryView(
            title: widget.title, // Passing the title
            text: widget.text, // Passing the text
            onImage: widget.onImage, // Passing the onImage callback
            onDetectorViewModeChanged:
                _onDetectorViewModeChanged); // Passing the mode change callback
  }

  // Method to handle the change in detector view mode
  void _onDetectorViewModeChanged() {
    // Toggling the mode between live feed and gallery
    if (_mode == DetectorViewMode.liveFeed) {
      _mode = DetectorViewMode.gallery;
    } else {
      _mode = DetectorViewMode.liveFeed;
    }
    // Calling the callback if it's provided
    if (widget.onDetectorViewModeChanged != null) {
      widget.onDetectorViewModeChanged!(_mode);
    }
    // Updating the state to reflect the change
    setState(() {});
  }
}
