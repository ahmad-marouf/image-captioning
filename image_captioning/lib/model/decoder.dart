import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class Decoder {

  ///Singleton
  static Decoder? _instance;

  /// Model
  Interpreter? _interpreter;
  static const String modelFileName = "tflite_models/model.tflite";
  // Shapes of output tensors
  late List<List<int>> _inputShapes;
  late List<List<int>> _outputShapes;


  /// Text Processing
  final _vocabFile = "tflite_models/word_dict.json";
  late Map vocabDict;

  final int _maxLen = 24;
  final String _startTok = 'startseq';
  final String _endTok = 'endseq';


  /// Methods
  // Private constructor
  Decoder._create();

  // Get function for getting Encoder instance
  static Future<Decoder> get instance async {
    if (_instance == null) {
      print('Initializing Encoder...');
      _instance = Decoder._create();

      await _instance!._loadDictionary();
      await _instance!._loadModel();
    }
    return _instance!;
  }

  Future<void> _loadDictionary() async {
    final vocab = await rootBundle.loadString('assets/$_vocabFile');
    Map dict = jsonDecode(vocab);
    vocabDict = dict;
    print('Loaded Dictionary');

  }

  Future<void> _loadModel() async {
    try {
      _interpreter =
          await Interpreter.fromAsset(
            modelFileName,
            options: InterpreterOptions()..useFlexDelegateAndroid = true,
          );

      // print('Decoder Inputs:');
      var inputTensors = _interpreter?.getInputTensors();
      _inputShapes = [];
      inputTensors?.forEach((tensor) {
        _inputShapes.add(tensor.shape);
        // print(tensor.type);
      });

      // print('Decoder Outputs:');
      var outputTensors = _interpreter?.getOutputTensors();
      _outputShapes = [];
      outputTensors?.forEach((tensor) {
        _outputShapes.add(tensor.shape);
        // print(tensor.shape);
      });

    } catch (e) {
      print("Error while creating interpreter: $e");
    }
  }

  /// Runs object detection on the input image
  Future<String?> predict(ByteBuffer features) async {

    if (_interpreter == null) {
      print("Interpreter not initialized");
      return null;
    }

    // Prepare inputs
    TensorBuffer hidden1Buffer = TensorBufferFloat([1,512]);
    TensorBuffer hidden2Buffer = TensorBufferFloat([1,512]);
    TensorBuffer textBuffer = TensorBufferFloat([1,1]);
    TensorBuffer featsBuffer = TensorBufferFloat([1,2048]);

    // Load data into input tensors
    List<double> token = [vocabDict[_startTok].toDouble()];
    textBuffer.loadList(token, shape: [1,1]);
    featsBuffer.loadBuffer(features, shape: [1,2048]);

    // Create inputs list
    List<ByteBuffer> inputs = [featsBuffer.buffer, textBuffer.buffer, hidden1Buffer.buffer, hidden2Buffer.buffer];


    // Create map of lists for output tensor buffers
    Map<int, List<List<double>>> outputs = {};
    for (int i =0; i < _maxLen; i++) {
      outputs[i] = [List<double>.filled(7378, 0.0)];
    }


    // Run model
    _interpreter!.runForMultipleInputs(inputs, outputs);

    // Convert output to string
    String caption = "";
    for (Object o in outputs.values) {
      List<double> singleOut = List<List<double>>.from(o as List<List<dynamic>>)[0];
      double maxValue = singleOut.reduce(max);
      int maxIndex = singleOut.indexOf(maxValue);
      var key = vocabDict.keys.firstWhere((k) => vocabDict[k] == maxIndex, orElse: () => " ");
      if (key != _endTok) {
        caption += "$key ";
      }
    }


    return caption;
  }

  /// Gets the interpreter instance
  Interpreter? get interpreter => _interpreter;

}
