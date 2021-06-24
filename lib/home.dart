import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:ventilator/constants.dart';
import 'package:ventilator/home_parts/app_bar_data.dart';
import 'package:ventilator/home_parts/controls_input.dart';

import 'Stream/streamPage.dart';

class BluetoothDataProvider extends InheritedWidget {
  BluetoothDataProvider(
      {this.parameterList, this.connection, this.currentDevice, this.child});
  //final int temp;
  final BluetoothConnection connection;
  final BluetoothDevice currentDevice;
  final List<String> parameterList;
  final Widget child;

  static BluetoothDataProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<BluetoothDataProvider>();
  }

  @override
  bool updateShouldNotify(BluetoothDataProvider oldWidget) {
    return true;
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int deviceState;
  BluetoothConnection passConnectionDetail;
  BluetoothDevice passCurrentDevice;
  List<String> passParameterList;

  //______________________ both the function will be passed as argument in app bar so that it will bring the values from appbar to home and that value we can use using inherited widget

  bluetoothDeviceInformation(BluetoothConnection con, BluetoothDevice dev) {
    setState(() {
      passConnectionDetail = con;
      passCurrentDevice = dev;
      // deviceState = deviceCurrentState;
    });
  }

  recievedParametersInformation({List<String> parametersList}) {
    setState(() {
      passParameterList = parametersList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BluetoothDataProvider(
      // updating values of inherited widget variables
      connection: passConnectionDetail,
      currentDevice: passCurrentDevice,

      child: Scaffold(
        drawer: MyDrawer(), // will open through navigation
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // *************** App Bar Part *************
            Container(
              padding: EdgeInsets.only(
                  top: 60.0, bottom: 0.0, left: 30.0, right: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MyCustomAppBar(
                    passFunctionForConnection: bluetoothDeviceInformation,
                    passFunctionForParameters: recievedParametersInformation(),
                  ), // passing defined function so that appbar can assign the values into this and that value can be updated on inherited widget
                ],
              ),
            ),
            //***************** Control section ******************
            Expanded(
              child: ControlInputs(),
            ),
          ],
        ),
        //drawer: Drawer(),
      ),
    );
  }
}

class MyDrawer extends StatelessWidget {
  const MyDrawer({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor:
            kbackgroundColour, //This will change the drawer background to blue.
        //other styles
      ),
      child: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              padding: EdgeInsets.zero,
              child: Image(
                image: AssetImage('images/back_drawer2.jpg'),
                fit: BoxFit.cover,
              ),
              decoration: BoxDecoration(color: kbackgroundColour),
            ),
            // ListTile(
            //   leading: Icon(Icons.home),
            //   title: Text("Home"),
            //   subtitle: Text("Control Page"),
            // ),
            ListTile(
              onTap: BluetoothDataProvider.of(context).connection != null
                  ? () {
                      // Navigator.popAndPushNamed(context, '/streamPage');
                      Navigator.pop(context); // THIS WILL CLOSE THE DRAWER
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => StreamPage(
                                currentConnection:
                                    BluetoothDataProvider.of(context)
                                        .connection,
                                parameterList: BluetoothDataProvider.of(context)
                                    .parameterList,
                              )));
                    }
                  : () {
                      showAlertDialog(context);
                    },
              leading: Icon(Icons.stream),
              title: Text("Stream"),
              subtitle: Text("Real Time Monitoring"),
            ),
            ListTile(
              onTap: () {
                Navigator.pop(context);
                FlutterBluetoothSerial.instance.openSettings();
              },
              leading: Icon(Icons.settings),
              title: Text("Settings"),
            ),
            ListTile(
              leading: Icon(Icons.menu_book),
              title: Text("Manual"),
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text("Help"),
            )
          ],
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    Navigator.pop(context);
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        title: Text(
          "Not Connected",
          style: TextStyle(color: Colors.black),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                'App is not connected to the device.',
                style: TextStyle(color: Colors.black),
              ),
              Text(
                'Check your connection and try again ',
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.transparent, // background
              onPrimary: Colors.black, // foreground
              elevation: 0,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text("Ok"),
          ),
        ],
      ),
    );
  }
  //   Navigator.pop(context); // THIS WILL CLOSE THE DRAWER
  //   return AlertDialog(
  //     title: Text('Error'),
  //     content: SingleChildScrollView(
  //       child: ListBody(
  //         children: <Widget>[
  //           Text('App is not connected to the ventilator'),
  //           Text('Check your connection and try again '),
  //         ],
  //       ),
  //     ),
  //     actions: [
  //       TextButton(
  //         child: Text('Ok'),
  //         onPressed: () {
  //           Navigator.of(context).pop();
  //         },
  //       ),
  //     ],
  //   );
  // },

}
