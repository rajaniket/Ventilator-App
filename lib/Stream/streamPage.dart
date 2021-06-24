import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:ventilator/constants.dart';
import 'package:fl_chart/fl_chart.dart';

class StreamPage extends StatefulWidget {
  const StreamPage({this.currentConnection, this.parameterList});
  final BluetoothConnection currentConnection;
  final List<String> parameterList;

  @override
  _StreamPageState createState() => _StreamPageState();
}

class _StreamPageState extends State<StreamPage> {
  String tidalVol =
      '0'; // tidalVol = widget.parameterList[0];  you can't directly initialize here , do it in initState
  String ieRatio = '1';
  String bpm = '0';
  String peep = '0';
  String mode = '0';
  String status = '1';
  String alarm = '0';
  String pip = '0';
  String platPress = '0';
  double time = 0.0;
  String currentVolume = '';
  String currentPressure = '';
  String flow = '';
  List<String> _combinedRecievedData;
  String _recievedMessageBuffer = '';
  bool isDisconnecting = false;
  Stream<Uint8List> stream;
  // The listen call returns a StreamSubscription of the type of your stream. This can be used to manage the stream subscription. The most common usage of the subscription is cancelling the listening when you're no longer required to receive the data. Basically making sure there are no memory leaks. A subscription to a stream will stay active until the entire memory is destroyed, usually the entire lifecycle of your app.
  StreamSubscription<Uint8List> subscription;

  List<FlSpot> volCordinates = [FlSpot(0, 0)];
  List<FlSpot> pressureCordinates = [FlSpot(0, 0)];
  List<FlSpot> flowCordinates = [FlSpot(0, 0)];

  @override
  void initState() {
    stream = widget.currentConnection.input.asBroadcastStream();
    if (stream.isBroadcast)
      print('brodcast');
    else
      print('single');
    time = 0.0;

    subscription = stream.listen(streamFunction, onDone: (() {
      showAlertDialog(context);
      // Navigator.pop(context);
    }));

    super.initState();
  }

  @override
  void dispose() {
    //widget.currentConnection.dispose();
    // widget.currentConnection = null;
    subscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(right: 8, left: 8, bottom: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.topRight,
              colors: [
                Colors.purple[200],
                Colors.blue[200],
                // Colors.blueGrey[200],
              ]),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              margin: EdgeInsets.only(
                bottom: 5,
              ),
              padding: EdgeInsets.only(top: 42, right: 35, left: 10),
              // decoration: BoxDecoration(
              //     color: Colors.transparent,
              //     border: Border.all(
              //       width: 5,
              //       color: kbackgroundColour,
              //     ),
              //     borderRadius:
              //         BorderRadius.vertical(bottom: Radius.circular(40))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back_ios),
                      color: kbackgroundColour,
                      splashColor: Colors.blue,

                      // splashRadius: 10,
                    ),
                  ),
                  Expanded(
                      child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Stream',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                    ),
                  )),

                  // server updating indicator
                  SizedBox(
                    height: 12,
                    width: 12,
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          // color: Colors.white70,  // if not streaming over internet
                          color: Colors.redAccent[700]),
                    ),
                  )
                ],
              ),
            ),
            // Expanded(
            //   flex: 1,
            //   child: ContainerGradient(),
            // ),

            Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Expanded(
                        child: ContainerParameter(
                      parameterName: 'Status',
                      value: status != '0' ? 'Active' : 'Paused',
                      unit: '',
                    )),
                    Expanded(
                        child: ContainerParameter(
                      parameterName: 'Mode',
                      unit: '',
                      value: mode != '0' ? 'AC' : 'VC',
                    )),
                    Expanded(
                        child: ContainerParameter(
                      parameterName: 'Alarm',
                      unit: '',
                      value: alarm != '1' ? 'OFF' : 'ON',
                    )),
                  ],
                )),
            Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Expanded(
                        child: ContainerParameter(
                      parameterName: 'BPM',
                      unit: 'b/min',
                      value: bpm,
                    )),
                    Expanded(
                        child: ContainerParameter(
                      parameterName: 'Tidal Vol',
                      unit: 'ml',
                      value: tidalVol,
                    )),
                    Expanded(
                        child: ContainerParameter(
                      parameterName: 'I:E',
                      unit: '',
                      value: '1:$ieRatio',
                    ))
                  ],
                )),
            Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Expanded(
                        child: ContainerParameter(
                      parameterName: 'Peep',
                      value: peep,
                      unit: 'cm H2O',
                    )),
                    Expanded(
                        child: ContainerParameter(
                      parameterName: 'PIP',
                      value: pip,
                      unit: 'cm H2O',
                    )),
                    Expanded(
                        child: ContainerParameter(
                      parameterName: 'Plat. Pressure',
                      value: platPress,
                      unit: 'cm H2O',
                    ))
                  ],
                )),
            // Expanded(
            //     flex: 2,
            //     child: ContainerGraph(
            //       gradient: kTidalGradientColour,
            //       cordinates: volCordinates,
            //       graphTitle: 'Volume (ml)',
            //       titalInterval: 200,
            //       minimumY: 0,
            //       maximumY: 801,
            //     )),
            Expanded(
                flex: 2,
                child: ContainerGraph(
                  gradient: kPressureGradientColour,
                  cordinates: pressureCordinates,
                  graphTitle: 'Pressure (cm H2O)',
                  titalInterval: 5,
                  minimumY: -5,
                  maximumY: 35,
                )),
            Expanded(
                flex: 2,
                child: ContainerGraph(
                  gradient: kFlowGradientColour,
                  cordinates: flowCordinates,
                  graphTitle: 'Flow (l/min)',
                  titalInterval: 20,
                  minimumY: -40,
                  maximumY: 60,
                )),
          ],
        ),
      ),
    );
  }

  // streamFunction(Uint8List data) {
  //   // print(data);
  //   data.forEach((byte) {
  //     // print(byte);
  //     if (byte != 10) {
  //       _recievedMessageBuffer =
  //           '$_recievedMessageBuffer${String.fromCharCode(byte)}'; // concatenate , it is better than using '+' , it gives error some time

  //     } else {
  //       _combinedRecievedData = _recievedMessageBuffer.split(',');
  //       // make a list of comma seprated string // // 100,2.5,30,20,1,1,0,40,35,10.5,500.5,28.5,40.5
  //       print('Combined data streamPage: $_combinedRecievedData');
  //       _recievedMessageBuffer = '';
  //       if (_combinedRecievedData.length == 6) {
  //         setState(() {
  //           // PEEP,PIP,PLAT_P,VOL,PRESSURE_2,FLOW
  //           // 0   , 1 , 2    , 3 ,   4      ,5

  //           peep = _combinedRecievedData[0];
  //           pip = _combinedRecievedData[1];
  //           platPress = _combinedRecievedData[2];
  //           currentVolume = _combinedRecievedData[3];
  //           currentPressure = _combinedRecievedData[4];
  //           flow = _combinedRecievedData[5];
  //           //_________________
  //           if (volCordinates.length <= 100) {
  //             // WINDOW SIZE FOR GRAPH (200 for ventilator and 40 for demo)
  //             volCordinates.add(FlSpot(time, double.parse(currentVolume)));
  //             pressureCordinates
  //                 .add(FlSpot(time, double.parse(currentPressure)));
  //             flowCordinates.add(FlSpot(time, double.parse(flow)));
  //             // volCordinates.removeAt(0);
  //             // pressureCordinates.removeAt(0);
  //             // flowCordinates.removeAt(0);
  //           } else {
  //             volCordinates.add(FlSpot(time, double.parse(currentVolume)));
  //             pressureCordinates
  //                 .add(FlSpot(time, double.parse(currentPressure)));
  //             flowCordinates.add(FlSpot(time, double.parse(flow)));
  //             volCordinates.removeAt(0);
  //             pressureCordinates.removeAt(0);
  //             flowCordinates.removeAt(0);
  //           }
  //         });
  //       } else if (_combinedRecievedData.length == 4) {
  //         setState(() {
  //           // TV,I_E,BPM,ALARM
  //           // 0 , 1 , 2 , 3
  //           tidalVol = _combinedRecievedData[0];
  //           ieRatio = _combinedRecievedData[1];
  //           bpm = _combinedRecievedData[2];
  //           alarm = _combinedRecievedData[3];
  //         });
  //       } else if (_combinedRecievedData.length == 2) {
  //         setState(() {
  //           //MODE,STATUS
  //           // 0  ,  1
  //           mode = _combinedRecievedData[0];
  //           status = _combinedRecievedData[1];
  //         });
  //       }
  //     }
  //   });
  //   time++;
  // }

// for persentation only_________________________________________________
  streamFunction(Uint8List data) {
    // print(data);
    data.forEach((byte) {
      // print(byte);
      if (byte != 10) {
        _recievedMessageBuffer =
            '$_recievedMessageBuffer${String.fromCharCode(byte)}'; // concatenate , it is better than using '+' , it gives error some time

      } else {
        _combinedRecievedData = _recievedMessageBuffer.split(',');
        // make a list of comma seprated string // // 100,2.5,30,20,1,1,0,40,35,10.5,500.5,28.5,40.5
        print('Combined data streamPage: $_combinedRecievedData');
        _recievedMessageBuffer = '';
        if (_combinedRecievedData.length == 9) {
          setState(() {
            // PEEP,PIP,PLAT_P,VOL,PRESSURE_2,FLOW
            // 0   , 1 , 2    , 3 ,   4      ,5

            peep = _combinedRecievedData[0];
            pip = _combinedRecievedData[1];
            platPress = _combinedRecievedData[2];
            currentVolume = _combinedRecievedData[3];
            currentPressure = _combinedRecievedData[4];
            flow = _combinedRecievedData[5];
            tidalVol = _combinedRecievedData[6];
            ieRatio = _combinedRecievedData[7];
            bpm = _combinedRecievedData[8];
            //print(currentPressure);
            //_________________
            if (volCordinates.length <= 40) {
              // WINDOW SIZE FOR GRAPH (200 for ventilator and 40 for demo)
              volCordinates.add(FlSpot(time, double.parse(currentVolume)));
              pressureCordinates
                  .add(FlSpot(time, double.parse(currentPressure)));
              flowCordinates.add(FlSpot(time, double.parse(flow)));
              // volCordinates.removeAt(0);
              // pressureCordinates.removeAt(0);
              // flowCordinates.removeAt(0);
            } else {
              volCordinates.add(FlSpot(time, double.parse(currentVolume)));
              pressureCordinates
                  .add(FlSpot(time, double.parse(currentPressure)));
              flowCordinates.add(FlSpot(time, double.parse(flow)));
              volCordinates.removeAt(0);
              pressureCordinates.removeAt(0);
              flowCordinates.removeAt(0);
            }
          });
        }
      }
    });
    time++;
  }
  //__________________________________________________________

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
}

class ContainerGraph extends StatefulWidget {
  const ContainerGraph({
    @required this.gradient,
    @required this.cordinates,
    @required this.graphTitle,
    @required this.titalInterval,
    @required this.minimumY,
    this.maximumY,
  });

  final List<Color> gradient;
  final List<FlSpot> cordinates;
  final String graphTitle;
  final double titalInterval;
  final double minimumY;
  final double maximumY;

  @override
  _ContainerGraphState createState() => _ContainerGraphState();
}

class _ContainerGraphState extends State<ContainerGraph> {
  @override
  Widget build(BuildContext context) {
    //Widget(double )
    return Container(
      // alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(right: 5, left: 5, top: 5, bottom: 5),
      padding: EdgeInsets.only(top: 20, bottom: 10, right: 8, left: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.black38,
        //border: ShapeBorder()
      ),
      child: LineChart(
        LineChartData(
          minY: widget.minimumY,
          maxY: null,

          borderData: FlBorderData(show: false),

          lineBarsData: [
            LineChartBarData(
              spots: widget.cordinates, // all cordinates points
              isCurved: false, // curve or smooth
              barWidth: 1.4, // outline of graph
              colors: [
                const Color(0xFFafd6e8),
                //const Color(0xffdfafbd),
              ],
              // bar line colour

              // fill Area above x-axis
              belowBarData: BarAreaData(
                show: true,
                colors: widget.gradient
                    .map((color) => color.withOpacity(0.5))
                    .toList(),
                gradientColorStops: const [
                  0.25,
                  0.5,
                  0.75
                ], // from where all the colors will end

                // determines start of the gradient, each number should be between 0 and 1, e.g if(0,0.1) then gradient will start from top like y=0.1 line (for horizontal)
                gradientFrom: const Offset(0, 1),
                //determines end of the gradient, each number should be between 0 and 1,
                gradientTo: const Offset(0, 0.1),

                cutOffY: 0, // for decreasing the area
                applyCutOffY: true,
              ),

              //  fill Area below x-axis
              aboveBarData: BarAreaData(
                show: true,
                colors: widget.gradient
                    .map((color) => color.withOpacity(0.5))
                    .toList(),
                gradientColorStops: const [
                  0.25,
                  0.5,
                  0.75
                ], // from where all the colors will end

                // determines start of the gradient, each number should be between 0 and 1, e.g if(0,0.1) then gradient will start from top like y=0.1 line (for horizontal)
                gradientFrom: const Offset(0, 1),
                //determines end of the gradient, each number should be between 0 and 1,
                gradientTo: const Offset(0, 0.1),

                cutOffY: 0, // for decreasing the area
                applyCutOffY: true,
              ),

              // show dots or points
              dotData: FlDotData(
                show: false,
              ),
            ),
          ],

          gridData: FlGridData(
            show: true,

            drawHorizontalLine: true,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.white12,
                strokeWidth: 1,
              );
            },

            // on which value of title you want to show line
            checkToShowHorizontalLine: (value) {
              return (value - widget.minimumY).abs() % widget.titalInterval ==
                  0;
            },
          ), // for grid

          lineTouchData: LineTouchData(
            enabled: true,
          ), // on touch it will give the value

          // Graph Title
          axisTitleData: FlAxisTitleData(
              topTitle: AxisTitle(
                  showTitle: true,
                  titleText: widget.graphTitle,
                  margin: 1,
                  reservedSize: -2,
                  textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w300),
                  textAlign: TextAlign.end)),

          // for managing text data on side and bottom
          titlesData: FlTitlesData(
            bottomTitles: SideTitles(
              showTitles: false,
            ),
            leftTitles: SideTitles(
              getTextStyles: (value) => const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 10,
              ),
              showTitles: true,
              interval: widget.titalInterval,
              reservedSize: 22,
            ),
          ),
        ),

        swapAnimationDuration: Duration(milliseconds: 1000), // Optional
        swapAnimationCurve: Curves.linear, // Optional
      ),
    );
  }
}

class ContainerParameter extends StatelessWidget {
  const ContainerParameter({this.parameterName, this.unit, this.value});
  final String parameterName;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    //Widget(double )
    return Container(
      margin: EdgeInsets.only(right: 5, left: 5, top: 5, bottom: 5),
      padding: EdgeInsets.only(top: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.black38,
        //border: ShapeBorder()
      ),
      child: Column(
        children: [
          Expanded(
              child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
            child: Text(
              parameterName,
              style: TextStyle(
                fontSize: 15,
              ),
            ),
          )),
          SizedBox(
            height: 20, //10
          ),
          Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                textBaseline: TextBaseline.alphabetic,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                children: [
                  Text(
                    value,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 21.0),
                  ),
                  Text(' $unit'),
                ],
              )),
        ],
      ),
    );
  }
}

// int tidalVol;
// double ieRatio;
// int bpm;
// int peep;
// int mode;
// int status;
// int alarm;
// double pip;
// double platPress;
// double time;
// double volume;
// double currentPressure;
// double flow;
