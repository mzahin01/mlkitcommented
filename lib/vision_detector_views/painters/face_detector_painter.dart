// Importing necessary Dart and Flutter packages
import 'dart:math'; // For mathematical functions and constants
import 'package:camera/camera.dart'; // For camera functionalities
import 'package:flutter/material.dart'; // For Flutter UI components
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart'; // For face detection functionalities

// Importing a custom utility for coordinate translation
import 'coordinates_translator.dart';

// Custom painter class to draw face detection results on a canvas
class FaceDetectorPainter extends CustomPainter {
  // Constructor for the FaceDetectorPainter class
  FaceDetectorPainter(
    this.faces, // List of detected faces
    this.imageSize, // Size of the image
    this.rotation, // Rotation of the input image
    this.cameraLensDirection, // Direction of the camera lens
  );

  // Fields to store the constructor parameters
  final List<Face> faces; // List of detected faces
  final Size imageSize; // Size of the image
  final InputImageRotation rotation; // Rotation of the input image
  final CameraLensDirection cameraLensDirection; // Direction of the camera lens

  // Override the paint method to draw on the canvas
  @override
  void paint(Canvas canvas, Size size) {
    // Define a paint object for drawing face bounding boxes
    final Paint paint1 = Paint()
      ..style = PaintingStyle.stroke // Stroke style for outlines
      ..strokeWidth = 1.0 // Width of the stroke
      ..color = Colors.red; // Color of the stroke

    // Define a paint object for drawing face landmarks
    final Paint paint2 = Paint()
      ..style = PaintingStyle.fill // Fill style for filled shapes
      ..strokeWidth = 1.0 // Width of the stroke
      ..color = Colors.green; // Color of the fill

    // Iterate over each detected face
    for (final Face face in faces) {
      // Translate the bounding box coordinates from image space to canvas space
      final left = translateX(
        face.boundingBox.left,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final top = translateY(
        face.boundingBox.top,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final right = translateX(
        face.boundingBox.right,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final bottom = translateY(
        face.boundingBox.bottom,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );

      // Draw the bounding box on the canvas
      canvas.drawRect(
        Rect.fromLTRB(left, top, right, bottom),
        paint1,
      );

      // Function to draw face contours
      void paintContour(FaceContourType type) {
        final contour =
            face.contours[type]; // Get the contour of the specified type
        if (contour?.points != null) {
          // Check if the contour has points
          for (final Point point in contour!.points) {
            // Iterate over each point in the contour
            // Draw a circle at each point of the contour
            canvas.drawCircle(
                Offset(
                  translateX(
                    point.x.toDouble(),
                    size,
                    imageSize,
                    rotation,
                    cameraLensDirection,
                  ),
                  translateY(
                    point.y.toDouble(),
                    size,
                    imageSize,
                    rotation,
                    cameraLensDirection,
                  ),
                ),
                1, // Radius of the circle
                paint1); // Use the paint1 object for drawing
          }
        }
      }

      // Function to draw face landmarks
      void paintLandmark(FaceLandmarkType type) {
        final landmark =
            face.landmarks[type]; // Get the landmark of the specified type
        if (landmark?.position != null) {
          // Check if the landmark has a position
          // Draw a circle at the landmark position
          canvas.drawCircle(
              Offset(
                translateX(
                  landmark!.position.x.toDouble(),
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                ),
                translateY(
                  landmark.position.y.toDouble(),
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                ),
              ),
              2, // Radius of the circle
              paint2); // Use the paint2 object for drawing
        }
      }

      // Draw all face contours
      for (final type in FaceContourType.values) {
        paintContour(type);
      }

      // Draw all face landmarks
      for (final type in FaceLandmarkType.values) {
        paintLandmark(type);
      }
    }
  }

  // Override the shouldRepaint method to determine when to repaint
  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    // Repaint if the image size or detected faces have changed
    return oldDelegate.imageSize != imageSize || oldDelegate.faces != faces;
  }
}
