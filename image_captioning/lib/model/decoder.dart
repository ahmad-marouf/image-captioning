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
  late List<int> _outputOrder;
  final List<int> _trueOrder = [0,1,12,23,24,25,26,27,28,29,
    2,3,4,5,6,7,8,9,10,11,13,14,
    15,16,17,18,19,20,21,22];


  /// Text Processing
  final _vocabFile = "tflite_models/word_dict.json";
  late Map vocabDict;

  final int _maxLen = 30;
  final int _vocabSize = 26637;
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
        // print(tensor.shape);
      });

      // print('Decoder Outputs:');
      var outputTensors = _interpreter?.getOutputTensors();
      _outputShapes = [];
      _outputOrder = [];
      outputTensors?.forEach((tensor) {
        _outputShapes.add(tensor.shape);
        _outputOrder.add(int.parse(tensor.name.substring(24)));
        // print(tensor.name);
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
    List<ByteBuffer> inputs = [hidden1Buffer.buffer, hidden2Buffer.buffer, textBuffer.buffer, featsBuffer.buffer];


    // Create map of lists for output tensor buffers
    Map<int, List<List<double>>> outputs = {};
    for (int i =0; i < _maxLen; i++) {
      outputs[i] = [List<double>.filled(_vocabSize, 0.0)];
    }


    // Run model
    _interpreter!.runForMultipleInputs(inputs, outputs);

    // Convert output to string
    String caption = "";
    for (int i = 0; i < _outputOrder.length; i++) {
      List<double> singleOut = List<List<double>>.from(
          outputs[_outputOrder.indexOf(_trueOrder[i])]
          as List<List<dynamic>>)[0];

      double maxValue = singleOut.reduce(max);
      int maxIndex = singleOut.indexOf(maxValue);
      var key = vocabDict.keys.firstWhere((k) => vocabDict[k] == maxIndex, orElse: () => " ");
      if (key == _endTok) {
        break;
      }
      caption += "$key ";
    }

    return caption;
  }

  /// Gets the interpreter instance
  Interpreter? get interpreter => _interpreter;

}
