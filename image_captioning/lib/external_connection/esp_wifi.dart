import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gps_connectivity/gps_connectivity.dart';
import 'package:image_captioning/shared_components.dart';

import 'package:location/location.dart';
import 'package:open_settings/open_settings.dart';
import 'package:image_captioning/external_connection/wifi_stream.dart';
import 'package:web_socket_channel/io.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:android_flutter_wifi/android_flutter_wifi.dart';

class WifiCheck extends StatefulWidget {
  const WifiCheck({super.key});

  @override
  WifiCheckState createState() => WifiCheckState();
}

class WifiCheckState extends State<WifiCheck> with WidgetsBindingObserver {

  final String targetSSID = "\"ESP32-CAM\"";
  final Map<String, String> _connectionStatus = {};
  late List<WifiNetwork> connections = <WifiNetwork>[];
  List<WifiNetwork> devices = <WifiNetwork>[];
  List<ConfiguredNetwork> savedDevices = <ConfiguredNetwork>[];

  final Connectivity _connectivity = Connectivity();
  final Location _location = Location();
  late StreamSubscription<ConnectivityResult> wifiSubscription;
  late StreamSubscription<bool> locationSubscription;

  late bool isTargetSSID;
  late bool isWifiEnabled = false;
  late bool isLocationEnabled = false;

  final TextEditingController controller = TextEditingController();

  Future<void> _init() async {
    await AndroidFlutterWifi.init();
  }

  _getWifiState() {
    _connectivity.checkConnectivity().then((result) {
      isWifiEnabled = result == ConnectivityResult.wifi;
      if (isWifiEnabled) {
        _listScannedDevices();
      }
      print("Wifi Enabled: $isWifiEnabled");
      setState(() {});
    });
  }

  _getLocationState() {
    _location.serviceEnabled().then((result) {
      isLocationEnabled = result;
      print("Location Enabled: $isLocationEnabled");
      setState(() {});
    });
  }

  _wifiStateChangeListener() {
    wifiSubscription = Connectivity().onConnectivityChanged.listen((event) {
      isWifiEnabled = event == ConnectivityResult.wifi;
      if (isWifiEnabled) {
        EasyLoading.showSuccess('WIFI Enabled');
        EasyLoading.dismiss();
        _listScannedDevices();
        isTargetSSID ? _connectWebSocket() : initConnectivity();
      } else {
        devices.clear();
        _connectionStatus['source'] = 'None';
        if (event == ConnectivityResult.mobile) {
          _connectionStatus['name'] = 'Mobile Data';
        } else {
          _connectionStatus['name'] = 'None';
        }
      }
      setState(() {});
    });
  }

  _locationStateChangeListener() {
    locationSubscription = GpsConnectivity().onGpsConnectivityChanged.listen((result) {
      isLocationEnabled = result;
      // debugPrint("$isLocationEnabled");
      if (isLocationEnabled) {
        _listScannedDevices();
        isTargetSSID ? _connectWebSocket() : initConnectivity();
      } else {
        devices.clear();
      }
    });
    setState(() {});
  }

  _listScannedDevices() {
    devices.clear();
    AndroidFlutterWifi.getWifiScanResult().then((List<WifiNetwork> scannedDevices) {
      scannedDevices.sort((a, b) => a.frequency!.compareTo(b.frequency!));
      // for (var element in scannedDevices) {
      //   debugPrint('Network id: ${element.ssid}');
      // }
      devices = scannedDevices;
      setState(() {});
    });


  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    isTargetSSID = false;

    _init();
    _getWifiState();
    _getLocationState();
    _wifiStateChangeListener();
    _locationStateChangeListener();
  }

  @override
  void dispose() {
    EasyLoading.dismiss();
    wifiSubscription.cancel();
    locationSubscription.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.teal,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Container(
                    // color: Colors.white12,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.white12, //New
                            blurRadius: 25.0,
                            offset: Offset(0, 0))
                      ],
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text(
                            'Enable WIFI',
                            style: TextStyle(
                              fontFamily: "Nunito",
                              color: Colors.white,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          value: isWifiEnabled,
                          onChanged: (bool value) {
                            future() async {
                              if (value) {
                                EasyLoading.show(status: 'Turning On WIFI...');
                                await AndroidFlutterWifi.enableWifi();
                              } else {
                                await AndroidFlutterWifi.disableWifi();
                              }
                              return await AndroidFlutterWifi.isConnected();
                            }
                            future().then((state) {
                              setState(() {
                                isWifiEnabled = state;
                              });
                            });
                          },
                        ),
                        SwitchListTile(
                          title: const Text(
                            'Enable Location',
                            style: TextStyle(
                                fontFamily: "Nunito",
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          value: isLocationEnabled,
                          onChanged: (bool value) {
                            future() async {
                              if (value) {
                                await _location.requestService();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Navigate to phone settings to disable location'),
                                    )
                                );

                              }
                              return await _location.serviceEnabled();
                            }
                            future().then((state) {
                              print("Location Enabled: $state");
                              setState(() {
                                isLocationEnabled = state;
                              });
                            });
                          },
                        ),
                        ListTile(
                          title: const Text(
                            "Current Network",
                            style: TextStyle(
                                fontFamily: "Nunito",
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          trailing: Text(
                              isWifiEnabled ? (
                                  isLocationEnabled ? (
                                      _connectionStatus['name'] ?? "Not Connected"
                                  ) : "Please Enable Location"
                              ) : "Please Enable Wifi",
                            style: TextStyle(
                              fontFamily: "Nunito",
                              fontWeight: FontWeight.bold,
                              color:  (isWifiEnabled && isLocationEnabled) ?
                                  Colors.white :
                                  Colors.red

                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Container(
                      // height: 450,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.white12, //New
                              blurRadius: 25.0,
                              offset: Offset(0, 0))
                        ],
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            title: const Text(
                              "Select ESP-32 CAM",
                              style: TextStyle(
                                fontSize: 20.0,
                                fontFamily: "Nunito",
                                fontWeight: FontWeight.bold
                                ),
                              ),
                            trailing: IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: () {
                                _listScannedDevices();
                                setState(() {});
                              },
                            ),
                          ),
                          Expanded(
                            child: ListView(
                                children: devices.map((device) {
                                  return (device.ssid != "")  ?
                                  ListTile(
                                    enabled: true,
                                    leading: const Icon(Icons.wifi_rounded),
                                    title: Text(device.ssid ?? "Unknown"),
                                    onTap: () async {
                                      if (device.ssid == "ESP32-CAM") {
                                        bool result =
                                            await AndroidFlutterWifi.connectToNetworkWithSSID(
                                                device.ssid!);
                                        if (!result) {
                                          OpenSettings.openWIFISetting();
                                        }
                                        setState(() {});
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: Text('Please Select ESP-32 CAM'),
                                        ));
                                      }
                                    },
                                  ) :
                                    Container();
                            }).toList()
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  _connectWebSocket() {
    Future.delayed(const Duration(milliseconds: 100)).then((_) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => WifiStream(
                channel: IOWebSocketChannel.connect('ws://192.168.4.1:8888', connectTimeout: null),
              )));
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {

    late ConnectivityResult result;

    var status = await Permission.location.status;
    if(status.isDenied || status.isRestricted)
    {
      if (await Permission.location.request().isGranted)
      {
        // Either the permission was already granted before or the user just granted it.
      }
    }

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    final info = NetworkInfo();
    switch (result) {
      case ConnectivityResult.wifi:
        String? wifiName, wifiBSSID, wifiIP;

        try {
            wifiName = await info.getWifiName();
        } on PlatformException catch (e) {
          print(e.toString());
          wifiName = "Failed to get Wifi Name";
        }

        try {
            wifiBSSID = await info.getWifiBSSID();
        } on PlatformException catch (e) {
          print(e.toString());
          wifiBSSID = "Failed to get Wifi BSSID";
        }

        try {
          wifiIP = await info.getWifiIP();
        } on PlatformException catch (e) {
          print(e.toString());
          wifiIP = "Failed to get Wifi IP";
        }

        setState(() {
          _connectionStatus['source'] = '$result';
          _connectionStatus['name'] = '$wifiName';
          _connectionStatus['bssid'] = '$wifiBSSID';
          _connectionStatus['ip'] = '$wifiIP';

          isTargetSSID = targetSSID == wifiName;
          print("Target: $targetSSID, Connected: $wifiName");
        });
        break;
      case ConnectivityResult.mobile:
        setState(() {
          _connectionStatus['source'] = result.toString();
          _connectionStatus['name'] = 'Mobile Data';
        });
        break;
      case ConnectivityResult.none:
        setState(() {
          _connectionStatus['source'] = result.toString();
          _connectionStatus['name'] = 'None';
        });
        break;
      default:
        setState(() {
          _connectionStatus['source'] = 'Failed to get connectivity.';
          _connectionStatus['name'] = 'None';
        });
        break;
    }

    if (isTargetSSID) {
      _connectWebSocket();
    }
  }
}


