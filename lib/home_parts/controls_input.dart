import 'dart:convert';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:ventilator/Stream/streamPage.dart';
import 'package:ventilator/home.dart';
import 'package:flutter/material.dart';
import 'package:ventilator/constants.dart';

enum Mode { volume, assist }

class ControlInputs extends StatefulWidget {
  ControlInputs({Key key}) : super(key: key);

  @override
  _ControlInputsState createState() => _ControlInputsState();
}

class _ControlInputsState extends State<ControlInputs> {
  int tidalVol = 600;
  double ieRatio = 2.0;
  int bpm = 25;
  int peep = 5;
  Mode selectedMode = Mode.assist;
  String output; // format --> ( TidalVol,ieRatio,bpm,peep,selectedMode )
  BluetoothConnection currentConnection;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 25, top: 20, left: 15, right: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.topRight,
            colors: [
              Colors.purple[200],
              Colors.blue[200],
            ]),

        //color: Colors.blueGrey
      ), // Color(0xFFF2F3F8)),
      child: Column(
        children: [
          // Tidal Volume & I:E Ratio
          Expanded(
            child: Row(
              children: [
                // *****************************  Tidal Vol  ********************
                Expanded(
                  child: Container(
                    margin:
                        EdgeInsets.only(right: 5, left: 5, top: 5, bottom: 5),
                    padding: EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.black38,
                      //border: ShapeBorder()
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      //crossAxisAlignment: CrossAxisAlignment.baselne,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'Tidal volume',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 15.0,
                          ),
                        ),
                        SizedBox(
                          height: 7,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          textBaseline: TextBaseline.alphabetic,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          children: [
                            Text(
                              tidalVol.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 30.0),
                            ),
                            Text(' ml'),
                          ],
                        ),
                        Slider(
                            value: tidalVol.toDouble(),

                            // widget is used to access variables of 1st class of stateful widget
                            min: 100.0,
                            max: 800.0,
                            divisions: 14,
                            activeColor: kActivesliderColor,
                            inactiveColor: kInactivesliderColor,
                            onChanged: (val) {
                              setState(() {
                                tidalVol = val.round();
                              });
                            })
                      ],
                    ),
                  ),
                ),
                //********************  I:E Ratio  ************************* */
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(
                              right: 5, left: 5, top: 5, bottom: 5),
                          padding: EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: Colors.black38,
                            //border: ShapeBorder()
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            //crossAxisAlignment: CrossAxisAlignment.baselne,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                'I:E',
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 15.0),
                              ),
                              SizedBox(
                                height: 7,
                              ),
                              Text(
                                '1 : ${ieRatio.toString()}',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 30.0),
                              ),
                              Slider(
                                  value:
                                      ieRatio, // widget is used to access variables of 1st class of stateful widget
                                  min: 1.0,
                                  max: 3.0,
                                  divisions: 4,
                                  activeColor: kActivesliderColor,
                                  inactiveColor: kInactivesliderColor,
                                  onChanged: (val) {
                                    setState(() {
                                      ieRatio = val;
                                    });
                                  })
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // BPM and Peep
          Expanded(
            child: Row(
              children: [
                //************************BPM******************* */
                Expanded(
                  child: Container(
                    margin:
                        EdgeInsets.only(right: 5, left: 5, top: 5, bottom: 5),
                    padding: EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.black38,
                      //border: ShapeBorder()
                    ),
                    // ************************* BPM  *************************
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      //crossAxisAlignment: CrossAxisAlignment.baselne,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'BPM',
                          style: TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 15.0),
                        ),
                        SizedBox(
                          height: 7,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          textBaseline: TextBaseline.alphabetic,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          children: [
                            Text(
                              bpm.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 30.0),
                            ),
                            Text(' b/min'),
                          ],
                        ),
                        Slider(
                            value: bpm
                                .toDouble(), // widget is used to access variables of 1st class of stateful widget
                            min: 10.0,
                            max: 40.0,
                            activeColor: kActivesliderColor,
                            inactiveColor: kInactivesliderColor,
                            onChanged: (val) {
                              setState(() {
                                bpm = val.round();
                              });
                            })
                      ],
                    ),
                  ),
                ),
                // ************************  peep *************************
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(
                              right: 5, left: 5, top: 5, bottom: 5),
                          padding: EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: Colors.black38,
                            //border: ShapeBorder()
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            //crossAxisAlignment: CrossAxisAlignment.baselne,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                'Peep',
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 15.0),
                              ),
                              SizedBox(
                                height: 7,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                textBaseline: TextBaseline.alphabetic,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                children: [
                                  Text(
                                    peep.toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 30.0),
                                  ),
                                  Text(' cm H2O')
                                ],
                              ),
                              Slider(
                                  value: peep
                                      .toDouble(), // widget is used to access variables of 1st class of stateful widget
                                  min: 3.0,
                                  max: 10.0,
                                  activeColor: kActivesliderColor,
                                  inactiveColor: kInactivesliderColor,
                                  onChanged: (val) {
                                    setState(() {
                                      peep = val.round();
                                    });
                                  })
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Modes
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin:
                        EdgeInsets.only(right: 5, left: 5, top: 5, bottom: 5),
                    padding: EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.black38,
                      //border: ShapeBorder()
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      //crossAxisAlignment: CrossAxisAlignment.baselne,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'Mode',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15.0),
                        ),
                        SizedBox(
                          height: 7,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 25.0, right: 25.0, bottom: 25, top: 7),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Text(
                                //   selectedMode,
                                //   style: TextStyle(
                                //       fontWeight: FontWeight.bold, fontSize: 30.0),
                                // ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      print('Vol');
                                      setState(() {
                                        selectedMode = Mode.volume;
                                      });
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Volume Control',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      //color: Colors.red,
                                      decoration: BoxDecoration(
                                          color: kInactiveCardColor,
                                          borderRadius:
                                              BorderRadius.circular(40),
                                          border: Border.all(
                                            color: selectedMode == Mode.volume
                                                ? kActiveModeBorderColor
                                                : kInactiveModeBorderColor,
                                            width: 2.5,
                                          )),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 25,
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      print('Assist');
                                      // print(
                                      //     "Device State: ${BluetoothDataProvider.of(context).iwTidalVol}");
                                      setState(() {
                                        selectedMode = Mode.assist;
                                      });
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Assist Control',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      //color: Colors.red,
                                      decoration: BoxDecoration(
                                          color: kInactiveCardColor,
                                          borderRadius:
                                              BorderRadius.circular(40),
                                          border: Border.all(
                                            width: 2.5,
                                            color: selectedMode == Mode.assist
                                                ? kActiveModeBorderColor
                                                : kInactiveModeBorderColor,
                                          )),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        //Radio(value: selectedMode, groupValue: , onChanged: onChanged)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          // Submit button
          FractionallySizedBox(
            // for increasing size of elevated button
            widthFactor: 0.3,

            child: ElevatedButton(
              onPressed: BluetoothDataProvider.of(context).connection != null
                  ? submitButtonAction
                  : null,
              child: Text(
                ' Submit ',
                style: TextStyle(fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.blueGrey[600], // background color
                //onPrimary: Colors.red,  // text color

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: BorderSide(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void submitButtonAction() {
    setState(() {
      output = tidalVol.toString() +
          ',' +
          ieRatio.toString() +
          ',' +
          bpm.toString() +
          ',' +
          peep.toString() +
          ',' +
          selectedMode.index.toString();
      print(output);
      //
      //sendDataToBluetooth();
    });
    sendDataToBluetooth();

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => StreamPage(
                  currentConnection:
                      BluetoothDataProvider.of(context).connection,
                  parameterList:
                      BluetoothDataProvider.of(context).parameterList,
                )));
    //Navigator.pushNamed(context, "/streamPage");
  }

  void sendDataToBluetooth() async {
    BluetoothDataProvider.of(context)
        .connection
        .output
        .add(utf8.encode(output + "\r\n"));
    await BluetoothDataProvider.of(context).connection.output.allSent;
    print("Device State: ${BluetoothDataProvider.of(context).connection}");
    // displaySnackbar('Submitted');
    // setState(() {
    //   BluetoothDataProvider.of(context).deviceState = 1; // device on
    // });
  }
}

// Expanded(
//               child: Row(
//             children: [
//               Expanded(
//                 child: ReusableCard(),
//               ),
//             ],
//           )),
//           Expanded(
//               child: Row(
//             children: [
//               Expanded(
//                 child: ReusableCard(),
//               ),
//             ],
//           )),
//           Expanded(
//               child: Row(
//             children: [
//               Expanded(
//                 child: ReusableCard(),
//               ),
//             ],
//           )),
//           Expanded(
//               child: Row(
//             children: [
//               Expanded(
//                 child: ReusableCard(),
//               ),
//             ],
//           )),
