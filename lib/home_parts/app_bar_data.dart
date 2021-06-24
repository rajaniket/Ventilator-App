import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter/services.dart';

class MyCustomAppBar extends StatefulWidget {
  final void Function(BluetoothConnection, BluetoothDevice)
      passFunctionForConnection;

  final void Function(List<String> parameters) passFunctionForParameters;
  // updating it's value in the connect and comingdata function

  MyCustomAppBar(
      {Key key, this.passFunctionForConnection, this.passFunctionForParameters})
      : super(key: key);

  @override
  _MyCustomAppBarState createState() => _MyCustomAppBarState();
}

class _MyCustomAppBarState extends State<MyCustomAppBar> {
  String _recievedMessageBuffer = '';
  List<String> combinedRecievedData = [];
  bool isBluetoothEnabled = false;
  //*********************** Variable Starts************************************ */
  // .... Enabling bluetooth......
  // intializing the bluetooth connection state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  // get the current instance of the bluetooth
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  // Tracking the bluetooth connection with the remote device , BluetoothConnection is a class that Represents ongoing Bluetooth connection to remote device.
  // inside this class there are many inbuilt function has defined like isConnected which is a bool type
  BluetoothConnection connection;
  // To track wether the device is still connected or not to bluetooth
  bool
      get isConnected => // if connection is null that means it is not connected to any device
          connection != null &&
          connection
              .isConnected; // Fat Arrow Expression or Lambda Function Expression is a syntax to write a function on a single line
  // defining a deviceState variable to track connection state of bluetooth device
  // ignore: unused_field
  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // defining a new class member variable for storing device list
  List<BluetoothDevice> _devicesList = [];
  // defining a member variable to track when the disconnection is in progress
  bool isDisconnecting = false;
  bool _connected = false;
  BluetoothDevice _device;
  bool _isButtonUnavailable = true;

  var stream;

  //************************ Variable Ends*************************************************** */
  // inside initState , first we have to fetch current state of bluetooth , as per state ,
  // requst user to give permissions for enabling Bluetooth on their device if the Bluetooth is not turned on.

// Goal of initState
// when user will open the app , first app will demand user permission to ON bluetooth app
// if it is already off then it will ON the bluetooth and will load paired device list

// this off , ON and getting paired list can be done using buttons also

  @override
  void initState() {
    super.initState();
    // getting current state
    FlutterBluetoothSerial.instance.state.then((state) {
      // state is argument , that will give us status
      setState(() {
        _bluetoothState = state;
      });
    });

    // if the bluetooth of the device is not enabled, then request permission to turn on bluetooth as the app starts up.
    enableBluetooth(); // for getting bluetooth permission from the user.

    // Listen for further state change  (after enabling again we have to do some operations)
    // after enabling or if bluetooth gets on or off  then we have to save it's state in  _bluetoothState
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
        // now for retrieving or fetching the paired device list
        getPairedDevices(); // for fetching the paired device list
      });
    });

    //
  }

  // defining enableBluetooth function
  Future<bool> enableBluetooth() async {
    // retrieving the current bluetooth state
    _bluetoothState = await FlutterBluetoothSerial.instance.state;

    // if the bluetooth is off, then turn it on first and then retrieve the devices that are paired
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices(); // defined downside
      // suppose user didn't give the permission in that case button should not be in active state
      if (await FlutterBluetoothSerial.instance.state ==
          BluetoothState.STATE_ON) {
        setState(() {
          if (_device != null)
            _isButtonUnavailable = false;
          else
            _isButtonUnavailable = true;
          isBluetoothEnabled = true; //t
        });
      }
      return true;
    } else {
      await getPairedDevices();
      setState(() {
        if (_device != null)
          _isButtonUnavailable = false;
        else
          _isButtonUnavailable = true;
        isBluetoothEnabled = true; //t
      });
    }
    return false;
  }

  // Definig getPairedDevices function
  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];
    // to get the list of paired devices
    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      // defined in the ---> import 'package:flutter/services.dart'
      // Thrown to indicate that a platform interaction failed in the platform plugin.
      print("Error");
    }
    // it is an error to call [setState] unless [mounted] is true.
    if (!mounted) {
      return;
    }
    // store the [devices] list in the [_deviceList] for accessing the list outside this class
    setState(() {
      _devicesList = devices;
    });
  }

  // dispose
  // https://www.youtube.com/watch?v=CjloInz3-I0
  // Regarding a page, the dispose method is called when the page is removed from the navigation stack.
  // when you use pushreplacement means , you are removing that page from stack in that case dispose method is called
  //In some cases dispose is required for example in CameraPreview, Timer etc.. you have to close the stream.
  // When closing the stream is required you have to use it in dispose method

  //dispose() method is called when this object is removed from the tree permanently.

  // a memory leak is a type of resource leak that occurs
  // when a computer program incorrectly manages memory allocations in a way that
  // memory which is no longer needed is not released.
  // A memory leak may also happen when an object is stored in memory but cannot be accessed by the running code.
  //  So basically dispose is called when that current state will never be used again.
  // dispose() method is called when this object is removed from the tree permanently. // like pushreplacemet, or a page that comes only one time in our app and gone after some time
  @override
  void dispose() {
    // Avoid memory leak and disconnect
    // when we exit to the app or disconnecting  we have to free resourses that we have initialized other wise
    // we will get performance issue due to memory leak (will consume more ram)
    if (isConnected) {
      // isConnected is already defined at 22th line
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          //crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            // ******************** Menu Icon*****************************
            Expanded(
                flex: 2,
                child: Container(
                  alignment: Alignment.bottomLeft,
                  child: CircleAvatar(
                    // wrapping it with container because if we apply expanded over iconbutton directly the button will expand
                    backgroundColor: Colors.tealAccent,
                    child: IconButton(
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                        icon: Icon(Icons.menu),
                        color: Colors.black),
                  ),
                )),
            // Text('Bluetooth'),
            Icon(
              Icons.bluetooth_rounded,
            ),
            // ********************Bluetooth Switch Button***************************//
            Switch(
              value: _bluetoothState.isEnabled,
              onChanged: (bool value) {
                future() async {
                  if (value) {
                    await FlutterBluetoothSerial.instance.requestEnable();
                    await getPairedDevices();
                    setState(() {
                      if (_device != null)
                        _isButtonUnavailable = false;
                      else
                        _isButtonUnavailable = true;
                      isBluetoothEnabled = true; //t
                    });
                  } else {
                    await FlutterBluetoothSerial.instance.requestDisable();
                    setState(() {
                      _isButtonUnavailable = true;
                      isBluetoothEnabled = false;
                    });
                  }
                  // await getPairedDevices();
                  // _isButtonUnavailable = false;

                  // if this switch is used that means for any reason means,
                  // we have to disconnect with connected device (ongoing communication ends)
                  // again user has to establish connection with device

                  if (_connected) {
                    _disconnect();
                  }
                }

                future().then((_) {
                  setState(() {});
                });
              },
            ),

            // ***************** Refresh Icon*******************************
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () async {
                // So, that when new devices are paired
                // while the app is running, user can refresh
                // the paired devices list.
                //print('data recieved refreshed : $_recievedMessageBuffer');
                print('conn: $connection');
                await getPairedDevices().then((_) {
                  displaySnackbar('Device list refreshed',
                      duration: Duration(seconds: 3));
                });
              },
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text('Menu'),
        ),
        //**********************Paired Device Text********************* */
        Center(
            child: Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          child: Text(
            'Paired Devices',
            style: TextStyle(fontSize: 17.0),
          ),
        )),
// **************** Paired devices list *********************
        Center(
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: connection != null
                    ? Border.all(
                        color: Colors.lightGreenAccent,
                        width: 2) // when connected to the device
                    : Border.all(color: Colors.white),
              ),
              padding: EdgeInsets.only(left: 15, right: 10),
              child: DropdownButton(
                items: _getDeviceItems(),
                onChanged: (value) {
                  if (value != null)
                    _isButtonUnavailable = false;
                  else
                    _isButtonUnavailable = true;

                  setState(() => _device = value);
                },
                value: _devicesList.isNotEmpty ? _device : null,
                hint: Text('Select Your Device'),
                dropdownColor: Colors.blueGrey[900],
                underline: SizedBox(), // to remove underline
              ),
            ),
          ),
        ),

        // ************** Connect Button ***********************
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          child: Center(
            child: ElevatedButton(
              onPressed: _isButtonUnavailable
                  ? null // null means button is unavailable
                  : () {
                      if (_connected) {
                        // print('conn1: $connection');
                        _disconnect();
                        connection = null;
                        // informing inherited widget connection on value changed
                        widget.passFunctionForConnection(connection, _device);
                        //print('conn3: $connection');
                      } else
                        _connect();
                    },
              child: Text(_connected ? 'Disconnect' : 'Connect'),
              style: ElevatedButton.styleFrom(
                primary: Colors.blueGrey[600],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: BorderSide(color: Colors.white)),
              ),
            ),
          ),
        )
        //
      ],
    );
  }

  // Create the List of devices to be shown in Dropdown Menu
  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devicesList.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      _devicesList.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name),
          value: device,
        ));
      });
    }
    return items;
  }

  // Method to connect to bluetooth
  void _connect() async {
    setState(() {
      _isButtonUnavailable = false;
    });
    if (_device == null) {
      displaySnackbar('No device selected');
    } else {
      if (!isConnected) {
        showProgressDialog(
            context); // will show circular progress indicator on connection
        await BluetoothConnection.toAddress(_device.address)
            .then((_connection) {
          print('Connected to the device');
          connection = _connection;
          setState(() {
            _connected = true;
          });
          Navigator.pop(
              context); // After connection remove circular progress indicator

          connection.input.asBroadcastStream().listen(null).onDone(() {
            if (isDisconnecting) {
              print('Disconnecting locally!');
            } else {
              print('Disconnected remotely!');
              setState(() {
                _connected = false;
                _isButtonUnavailable = false;
                connection = null;
                // passing values
                widget.passFunctionForConnection(connection, _device);
              });
            }
            if (this.mounted) {
              setState(() {});
            }
          });
        }).catchError((error) {
          print('Cannot connect, exception occurred');
          print(error);
          Navigator.pop(
              context); // if  connection fail , remove circular progress indicator
          displaySnackbar('Error or Device Not Available');
        });

        if (isConnected) displaySnackbar('Device connected');
        //setState(() => _isButtonUnavailable = false);

      }
    }
    widget.passFunctionForConnection(connection,
        _device); // passing current bluetooth connection with inherited widget
    print(
        '_________Connection_________ $connection ____________Device ${_device.address}');
  }

  // Method to disconnect bluetooth
  void _disconnect() async {
    //await connection.close();
    displaySnackbar('Device disconnected');
    if (connection.isConnected) {
      setState(() {
        _connected = false;
        _isButtonUnavailable = false;
      });
    }
    print('conn2: $connection');
    await connection
        .close(); // after this line nothing will execute some error in the library , that's why kept it in the last after all the process
  }

  // Method to show a Snackbar,
  // taking message as the text
  Future displaySnackbar(
    String message, {
    Duration duration: const Duration(seconds: 3),
  }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    ScaffoldMessenger.of(context).showSnackBar(
      new SnackBar(
        key: _scaffoldKey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
          side: BorderSide(color: Colors.blueGrey[900]),
        ),
        backgroundColor: Colors.blueGrey[900],

        content: new Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
        duration: duration, //ScaffoldMessenger
      ),
    );
  }

  void comingData(Uint8List data) {
    data.forEach((byte) {
      // print(byte);
      if (byte != 10) {
        _recievedMessageBuffer =
            '$_recievedMessageBuffer${String.fromCharCode(byte)}'; // concatenate , it is better than using '+' , it gives error some time
      } else {
        combinedRecievedData = _recievedMessageBuffer.split(',');

        // make a list of comma seprated string // // 100,2.5,30,20,1,1,0,40,35,10.5,500.5,28.5,40.5
        // print('Combined data : $combinedRecievedData');
        print('Combined data : $combinedRecievedData');
        _recievedMessageBuffer = '';
        // widget.passFunctionForParameters(combinedRecievedData);

        //
      }
    });
  }

  // progress indicator using AlertDialog
  // for removal of this use Navigator.pop(contet);
  showProgressDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              backgroundColor: Colors.tealAccent[700],
              valueColor: AlwaysStoppedAnimation(Colors.white),
              strokeWidth: 5,
            ),
            Container(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Text(
                  "Connecting...",
                  style: TextStyle(color: Colors.black),
                )),
          ],
        ),
      ),
    );
  }
}
// 100,2.5,30,20,1,1,0,40,35,10.5,500.5,28.5,40.5
// TV,I_E,BPM,PEEP,MODE,STATUS,ALARM,PIP,PLAT_P,TIME,VOL,PRESSURE_2,FLOW
