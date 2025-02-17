// Import necessary packages
import 'package:camera/camera.dart'; // For camera functionalities
import 'package:flutter/material.dart'; // For Flutter UI components
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart'; // For barcode scanning

import 'detector_view.dart'; // Custom widget for the detector view
import 'painters/barcode_detector_painter.dart'; // Custom painter for drawing barcode bounding boxes

// Define a stateful widget for the barcode scanner view
class BarcodeScannerView extends StatefulWidget {
  @override
  State<BarcodeScannerView> createState() => _BarcodeScannerViewState();
}

// Define the state class for the BarcodeScannerView
class _BarcodeScannerViewState extends State<BarcodeScannerView> {
  // Initialize the barcode scanner
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  // Flags to control processing state
  bool _canProcess = true;
  bool _isBusy = false;
  // Custom painter for drawing on the canvas
  CustomPaint? _customPaint;
  // Text to display barcode information
  String? _text;
  // Camera lens direction (default is back camera)
  var _cameraLensDirection = CameraLensDirection.back;

  // Dispose method to clean up resources
  @override
  void dispose() {
    _canProcess = false; // Stop processing
    _barcodeScanner.close(); // Close the barcode scanner
    super.dispose(); // Call the superclass dispose method
  }

  // Build method to create the widget tree
  @override
  Widget build(BuildContext context) {
    return DetectorView(
      title: 'Barcode Scanner', // Title of the view
      customPaint: _customPaint, // Custom painter for drawing
      text: _text, // Text to display barcode information
      onImage: _processImage, // Callback to process the image
      initialCameraLensDirection:
          _cameraLensDirection, // Initial camera lens direction
      onCameraLensDirectionChanged: (value) => _cameraLensDirection =
          value, // Callback for camera lens direction change
    );
  }

  // Method to process the input image
  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return; // If processing is not allowed, return
    if (_isBusy) return; // If already busy, return
    _isBusy = true; // Set busy flag to true
    setState(() {
      _text = ''; // Clear the text
    });
    // Process the image to detect barcodes
    final barcodes = await _barcodeScanner.processImage(inputImage);
    // Check if image metadata is available
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      // Create a custom painter to draw barcode bounding boxes
      final painter = BarcodeDetectorPainter(
        barcodes,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );
      _customPaint = CustomPaint(painter: painter); // Set the custom painter
    } else {
      // If metadata is not available, display barcode information as text
      String text = 'Barcodes found: ${barcodes.length}\n\n';
      for (final barcode in barcodes) {
        text += 'Barcode: ${barcode.rawValue}\n\n';
      }
      _text = text; // Set the text
      // TODO: set _customPaint to draw boundingRect on top of image
      _customPaint = null; // No custom painting
    }
    _isBusy = false; // Set busy flag to false
    if (mounted) {
      setState(() {}); // Update the state if the widget is still mounted
    }
  }
}
