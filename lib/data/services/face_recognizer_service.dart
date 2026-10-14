import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class FaceRecognizerService {
  late FaceDetector _faceDetector;
  Interpreter? _interpreter;
  bool _isModelLoaded = false;
  Future<void>? _initFuture;

  bool get isModelLoaded => _isModelLoaded;

  FaceRecognizerService() {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableLandmarks: false,
        enableClassification: false,
      ),
    );

    _initFuture = _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model/mobilefacenet.tflite');
      _isModelLoaded = true;
      debugPrint("🚀 MobileFaceNet TFLite engine successfully loaded!");
    } catch (e) {
      debugPrint("❌ Error initializing TFLite interpreter: $e");
    }
  }

  /// Ensures the model is fully initialized before attempting analysis
  Future<void> ensureInitialized() async {
    if (_initFuture != null) {
      await _initFuture;
    }
  }

  Future<Face?> detectFace(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final List<Face> faces = await _faceDetector.processImage(inputImage);
    if (faces.isEmpty) return null;
    return faces.first;
  }

  img.Image cropAndResizeFace(File imageFile, Face face) {
    final bytes = imageFile.readAsBytesSync();
    img.Image? decodedImage = img.decodeImage(bytes);
    if (decodedImage == null) throw Exception("Failed to decode image bytes.");

    // Fix EXIF orientation (crucial for mobile front camera photos)
    decodedImage = img.bakeOrientation(decodedImage);

    final imgWidth = decodedImage.width;
    final imgHeight = decodedImage.height;

    // Safely clamp bounding box within image boundaries
    int x = face.boundingBox.left.toInt().clamp(0, imgWidth - 1);
    int y = face.boundingBox.top.toInt().clamp(0, imgHeight - 1);
    int w = face.boundingBox.width.toInt().clamp(1, imgWidth - x);
    int h = face.boundingBox.height.toInt().clamp(1, imgHeight - y);

    final img.Image croppedFace = img.copyCrop(
      decodedImage,
      x: x,
      y: y,
      width: w,
      height: h,
    );

    return img.copyResize(croppedFace, width: 112, height: 112);
  }

  Float32List imageToByteBuffer(img.Image image) {
    var buffer = Float32List(1 * 112 * 112 * 3);
    int pixelIndex = 0;

    for (int y = 0; y < 112; y++) {
      for (int x = 0; x < 112; x++) {
        final pixel = image.getPixel(x, y);
        buffer[pixelIndex++] = (pixel.r.toDouble() - 127.5) / 128.0;
        buffer[pixelIndex++] = (pixel.g.toDouble() - 127.5) / 128.0;
        buffer[pixelIndex++] = (pixel.b.toDouble() - 127.5) / 128.0;
      }
    }
    return buffer;
  }

  Future<List<double>?> generateEmbedding(File imageFile) async {
    await ensureInitialized();

    if (!_isModelLoaded || _interpreter == null) return null;

    final face = await detectFace(imageFile);
    if (face == null) return null;

    final croppedFaceImage = cropAndResizeFace(imageFile, face);
    final byteBuffer = imageToByteBuffer(croppedFaceImage);

    var input = byteBuffer.reshape([1, 112, 112, 3]);
    var output = List<double>.filled(1 * 192, 0.0).reshape([1, 192]);

    _interpreter!.run(input, output);
    return List<double>.from(output[0]);
  }

  double compareEmbeddings(List<double> e1, List<double> e2) {
    if (e1.length != e2.length) return 0.0;

    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < e1.length; i++) {
      dotProduct += e1[i] * e2[i];
      normA += e1[i] * e1[i];
      normB += e2[i] * e2[i];
    }

    if (normA == 0.0 || normB == 0.0) return 0.0;
    return dotProduct / (sqrt(normA) * sqrt(normB));
  }

  void dispose() {
    _faceDetector.close();
    _interpreter?.close();
  }
}