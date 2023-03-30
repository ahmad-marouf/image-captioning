import 'package:image_captioning/bluetooth/BluetoothDeviceListEntry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:image_captioning/bluetooth/bt_preview_page.dart';

class BTPairPage extends StatefulWidget {
  const BTPairPage({Key? key}) : super(key: key);

  @override
  State<BTPairPage> createState() => _BTPairPageState();
}

class _BTPairPageState extends State<BTPairPage> with WidgetsBindingObserver {

  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  List<BluetoothDevice> devices = <BluetoothDevice>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getBTState();
    _stateChangeListener();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state.index == 0) {
      if (_bluetoothState.isEnabled) {
        _listBondedDevices();
      }
    }
  }

  _getBTState() {
    FlutterBluetoothSerial.instance.state.then((state) {
      _bluetoothState = state;
      if (_bluetoothState.isEnabled) {
        _listBondedDevices();
      }
      setState(() {});
    });
  }

  _stateChangeListener() {
    FlutterBluetoothSerial.instance.onStateChanged().listen((BluetoothState state) {
      _bluetoothState = state;
      if (_bluetoothState.isEnabled) {
        _listBondedDevices();
      } else {
        devices.clear();
      }
      print('State isEnabled: ${state.isEnabled}');
      setState(() {});
    });
  }

  _listBondedDevices() {
    FlutterBluetoothSerial.instance.getBondedDevices().then((List<BluetoothDevice> bondedDevices) {
      devices = bondedDevices;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ESP32 CAM BT SERIAL")
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('Enable Bluetooth'),
            value: _bluetoothState.isEnabled,
            onChanged: (bool value) {
               future() async {
                if (value) {
                  await FlutterBluetoothSerial.instance.requestEnable();
                } else {
                  await FlutterBluetoothSerial.instance.requestDisable();
                }
              }
              future().then((_) {
               setState(() {});
              });
            },
          ),
          ListTile(
            title: const Text("Bluetooth Status"),
            subtitle: Text(_bluetoothState.toString()),
            trailing: ElevatedButton(child: const Text("Settings"), onPressed: () {
              FlutterBluetoothSerial.instance.openSettings();
            },),
          ),
          Expanded(
            child: ListView(
              children: devices
                  .map((device) => BluetoothDeviceListEntry(
                device: device,
                enabled: true,
                onTap: () {
                  // print("Device: ${device.name}");
                  _startCameraConnect(context, device);
                  // _startCameraConnect(context, _device);
                },
              )).toList()
            ),
          ),
        ],
      ),
    );
  }

  void _startCameraConnect(BuildContext context, BluetoothDevice server) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return BTPreviewPage(server: server);
    }));
  }

}

