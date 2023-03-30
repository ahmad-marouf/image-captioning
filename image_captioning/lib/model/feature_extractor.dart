import 'dart:math';

import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'package:image/image.dart' as imageLib;

class FeatureExtractor {

  /// Instance of Interpreter
  Interpreter? _interpreter;

  static const String MODEL_FILE_NAME = "tflite_models/resnet101.tflite";

  /// Shapes of output tensors
  late List<List<int>> _outputShapes;
  late List<TfLiteType> _outputTypes;

  /// Input size of image (height = width)
  static const int INPUT_SIZE = 224;

  /// [ImageProcessor] used to pre-process the image
  late ImageProcessor imageProcessor;

  /// Padding the image to transform into square
  late int padSize;

  FeatureExtractor({Interpreter? interpreter}) {
    _loadModel(interpreter: interpreter);
  }

  /// Loads interpreter from asset
  void _loadModel({Interpreter? interpreter}) async {
    try {
      _interpreter = interpreter ??
          await Interpreter.fromAsset(
            MODEL_FILE_NAME,
            options: InterpreterOptions()..threads = 4,
          );

      var outputTensors = _interpreter?.getOutputTensors();
      _outputShapes = [];
      _outputTypes = [];
      outputTensors?.forEach((tensor) {
        _outputShapes.add(tensor.shape);
        _outputTypes.add(tensor.type);
      });
      // print(_outputShapes);
    } catch (e) {
      print("Error while creating interpreter: $e");
    }
  }

  /// Pre-process the image
  TensorBuffer _getProcessedImage(TensorImage inputImage) {
    padSize = max(inputImage.height, inputImage.width);

    // create ImageProcessor
    imageProcessor = ImageProcessorBuilder()
    // Padding the image
        .add(ResizeWithCropOrPadOp(padSize, padSize))
    // Resizing to input size
        .add(ResizeOp(INPUT_SIZE, INPUT_SIZE, ResizeMethod.BILINEAR))
        .build();

    inputImage = imageProcessor.process(inputImage);

    TensorBuffer inputBuffer = TensorBuffer.createFrom(inputImage.getTensorBuffer(), TfLiteType.float32);
    inputBuffer.resize([INPUT_SIZE,INPUT_SIZE,3,1]);

    return inputBuffer;
  }

  /// Runs object detection on the input image
  Future<List<double>?> predict(String fileName) async {

    if (_interpreter == null) {
      print("Interpreter not initialized");
      return null;
    }

    ByteData imageByteData = await rootBundle.load('assets/$fileName');
    List<int> values = imageByteData.buffer.asUint8List();
    imageLib.Image? image = imageLib.decodeImage(values);

    if (image == null) {
      print("Could not load image");
      return null;
    }

    // Create TensorImage from image
    TensorImage inputImage = TensorImage.fromImage(image);
    // Pre-process TensorImage
    TensorBuffer inputBuffer = _getProcessedImage(inputImage);
    print("Input shape: ${inputBuffer.getShape()}");
    // print(inputBuffer.getDoubleList());

    // TensorBuffers for output tensors
    TensorBuffer outputFeatures = TensorBufferFloat(_outputShapes[0]);

    _interpreter?.run(inputBuffer.buffer, outputFeatures.buffer);
    print("Output shape: ${outputFeatures.getShape()}");

    return outputFeatures.getDoubleList();
  }

  /// Gets the interpreter instance
  Interpreter? get interpreter => _interpreter;

}