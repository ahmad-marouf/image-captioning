import 'dart:convert';
import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_svprogresshud/flutter_svprogresshud.dart';

class BTPreviewPage extends StatefulWidget {
  final BluetoothDevice server;

  const BTPreviewPage({super.key, required this.server});

  @override
  State<BTPreviewPage> createState() => _BTPreviewPageState();
}

class _BTPreviewPageState extends State<BTPreviewPage> {
  BluetoothConnection? connection;
  bool isConnecting = true;

  bool get isConnected => connection?.isConnected ?? false;
  bool isDisconnecting = false;

  String? _selectedFrameSize;

  List<List<int>> chunks = <List<int>>[];
  int contentLength = 0;
  Uint8List? bytes;

  late RestartableTimer _timer;

  @override
  void initState() {
    super.initState();
    _selectedFrameSize = '0';
    _getBTConnection();
    _timer = RestartableTimer(const Duration(seconds: 1), _drawImage);
  }

  @override
  void dispose() {
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }
    _timer.cancel();
    super.dispose();
  }

  _getBTConnection() {
    // print("Name: ${widget.server.name}, Address: ${widget.server.address}");
    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      connection = _connection;
      isConnecting = false;
      isDisconnecting = false;
      setState(() {});
      connection?.input?.listen(_onDataReceived).onDone(() {
        if (isDisconnecting) {
          print("Disconnecting locally");
        } else {
          print("Disconnecting remotely");
        }
        if (mounted) {
          setState(() {});
          Navigator.of(context).pop();
        }
      });
    }).catchError((error) {
      Navigator.of(context).pop();
    });
  }

  _drawImage() {
    if (chunks.isEmpty || contentLength == 0) {
      return;
    }
    bytes = Uint8List(contentLength);
    int _offset = 0;
    for (final List<int> chunk in chunks) {
      bytes?.setRange(_offset, _offset + chunk.length, chunk);
      _offset += chunk.length;
    }
    setState(() {});

    SVProgressHUD.show(status: "Downloaded...");
    SVProgressHUD.dismiss(delay: const Duration(seconds: 1));

    contentLength = 0;
    chunks.clear();
  }

  void _onDataReceived(Uint8List data) {
    if (data.isNotEmpty) {
      chunks.add(data);
      contentLength += data.length;
      _timer.reset();
    }

    print("Data Length: ${data.length}, chunks: ${chunks.length}");
  }

  void _sendMessage(String text) async {
    text = text.trim();
    if (text.isNotEmpty) {
      try {
        connection?.output.add(Uint8List.fromList(utf8.encode(text)));
        SVProgressHUD.show(status: "Requesting...");
        await connection?.output.allSent;
      } catch (e) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: (isConnecting
            ? Text('Connecting to ${widget.server.name} ...')
            : isConnected
                ? Text('Connected with ${widget.server.name}')
                : Text('Disconnected with ${widget.server.name}')),
      ),
      body: SafeArea(
        child: isConnected
            ? Column(
                children: [
                  selectFrameSize(),
                  shotButton(),
                  photoFrame(),
                ],
              )
            : const Center(
                child: Text(
                  'Connecting...',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
      ),
    );
  }

  Widget photoFrame() {
    return Expanded(
      child: SizedBox(
          width: double.infinity,
          child: bytes != null
              ? PhotoView(
                  enableRotation: true,
                  initialScale: PhotoViewComputedScale.covered,
                  maxScale: PhotoViewComputedScale.covered * 2.0,
                  minScale: PhotoViewComputedScale.contained * 0.8,
                  imageProvider:
                      Image.memory(bytes!, fit: BoxFit.fitWidth).image,
                )
              : Container()),
    );
  }

  Widget shotButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Colors.red),
          ),
        ),
        onPressed: () {
          _sendMessage(_selectedFrameSize!);
        },
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'TAKE A SHOT',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }

  Widget selectFrameSize() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: DropDownFormField(
        titleText: 'Frame Size',
        hintText: 'Please choose one',
        value: _selectedFrameSize,
        onSaved: (value) {
          _selectedFrameSize = value;
          setState(() {});
        },
        onChanged: (value) {
          _selectedFrameSize = value;
          setState(() {});
        },
        dataSource: const [
          {'value': '4', 'display': '1600x1200'},
          {'value': '3', 'display': '1280x1024'},
          {'value': '2', 'display': '1024x786'},
          {'value': '1', 'display': '800x600'},
          {'value': '0', 'display': '640x480'},
        ],
        textField: 'display',
        valueField: 'value',
      ),
    );
  }
}
