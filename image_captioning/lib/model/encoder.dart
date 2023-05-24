import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'package:image/image.dart' as imageLib;

class Encoder {

  ///Singleton
  static Encoder? _instance;

  /// Model
  Interpreter? _interpreter;
  static const String modelFileName = "tflite_models/resnet101.tflite";
  // Shapes of output tensors
  late List<List<int>> _outputShapes;

  /// Image Preprocessing
  // Input size of image (height = width)
  static const int inputImgSize = 224;
  // [ImageProcessor] used to pre-process the image
  late ImageProcessor imageProcessor;

  /// Methods
  // Private constructor
  Encoder._create();

  // Get function for getting Encoder instance
  static Future<Encoder> get instance async {
    if (_instance == null) {
      print('Initializing Encoder...');
      _instance = Encoder._create();

      await _instance!._loadModel();
    }
    return _instance!;
  }

  /// Loads interpreter from asset
  Future<void> _loadModel() async {
    try {
      _interpreter =
          await Interpreter.fromAsset(
            modelFileName,
            options: InterpreterOptions()..threads = 4,
          );

      var outputTensors = _interpreter?.getOutputTensors();
      _outputShapes = [];
      outputTensors?.forEach((tensor) {
        _outputShapes.add(tensor.shape);
      });

    } catch (e) {
      print("Error while creating interpreter: $e");
    }
  }

  /// Pre-process the image
  Future<TensorBuffer?> _getProcessedImage(Uint8List imageBytes) async {

    imageLib.Image? image = imageLib.decodeImage(imageBytes);

    if (image == null) {
      print("Could not load image");
      return null;
    }

    // Convert RGB to BGR
    imageLib.remapColors(image, red: imageLib.Channel.blue, blue: imageLib.Channel.red);

    // Create TensorImage from image
    TensorImage inputImage = TensorImage(TfLiteType.float32);
    inputImage.loadImage(image);


    // Create ImageProcessor
    imageProcessor = ImageProcessorBuilder()
    // Resizing to input size
        .add(ResizeOp(inputImgSize, inputImgSize, ResizeMethod.BILINEAR))
        .add(NormalizeOp.multipleChannels([103.939, 116.779, 123.68], [1, 1, 1]))
        .build();

    inputImage = imageProcessor.process(inputImage);

    TensorBuffer inputBuffer = TensorBuffer.createFrom(inputImage.getTensorBuffer(), TfLiteType.float32);
    inputBuffer.resize([inputImgSize,inputImgSize,3,1]);

    return inputBuffer;
  }

  /// Runs object detection on the input image
  Future<ByteBuffer?> predict(Uint8List imageBytes) async {

    if (_interpreter == null) {
      print("Interpreter not initialized");
      return null;
    }

    // Pre-process input image to get input TensorBuffer
    TensorBuffer? inputBuffer = await _getProcessedImage(imageBytes);
    if (inputBuffer == null) {
      return null;
    }

    // TensorBuffers for output tensors
    TensorBuffer outputFeatures = TensorBufferFloat(_outputShapes[0]);

    _interpreter?.run(inputBuffer.buffer, outputFeatures.buffer);

    return outputFeatures.getBuffer();
  }

  /// Gets the interpreter instance
  Interpreter? get interpreter => _interpreter;

}