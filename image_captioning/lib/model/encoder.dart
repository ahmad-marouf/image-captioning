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

      // print('Encoder Inputs:');
      // var inputTensors = _interpreter?.getInputTensors();
      // inputTensors?.forEach((tensor) {
      //   print(tensor.type);
      // });

      // print('Encoder Outputs:');
      var outputTensors = _interpreter?.getOutputTensors();
      _outputShapes = [];
      outputTensors?.forEach((tensor) {
        _outputShapes.add(tensor.shape);
        // print(tensor.shape);
      });

      // print(_interpreter?.getInputTensors());
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
    // imageLib.normalize(image, 0, 1);
    // imageLib.colorOffset(image, red: 123.68.toInt(), green: 116.779.toInt(), blue: 103.939.toInt());
    // imageLib.colorOffset(image, red: -103.939.toInt(), green: -116.779.toInt(), blue: -123.68.toInt());

    // Create TensorImage from image
    TensorImage inputImage = TensorImage.fromImage(image);


    // Create ImageProcessor
    imageProcessor = ImageProcessorBuilder()
    // Resizing to input size
        .add(ResizeOp(inputImgSize, inputImgSize, ResizeMethod.BILINEAR))
        // .add(NormalizeOp.multipleChannels([0.406, 0.456, 0.485], [0.225, 0.224, 0.229]))
        // .add(NormalizeOp.multipleChannels([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]))
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