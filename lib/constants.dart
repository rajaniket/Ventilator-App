import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

const kbackgroundColour = Color(0XFF15202B);
const kActiveCardColor = Color(0xFF1D1E33);
const kInactiveCardColor = Colors.black38; //Color(0xFF111328);
const kActivesliderColor = Colors.tealAccent;
const kInactivesliderColor = Colors.teal;
const kActiveModeBorderColor = Colors.tealAccent;
const kInactiveModeBorderColor = Colors.black12;
List<Color> kGradientLineColour = [
  Color(0xfff5efef),
  Color(0xfffeada6),
];
List<Color> kPressureGradientColour = [
  // const Color(0xff53b6e6),
  // const Color(0xff02d39a),
  const Color(0xff48b1bf),
  const Color(0xff06beb6)
];
List<Color> kFlowGradientColour = [
  const Color(0xff48b1bf),
  const Color(0xff06beb6)
];
List<Color> kTidalGradientColour = [
  const Color(0xff48b1bf),
  const Color(0xff06beb6)
];
List<FlSpot> kPressueCordinates = [
  FlSpot(0, 0),
  // FlSpot(1, 50),
  // FlSpot(1.2, 30),
  // FlSpot(1.5, 10),
  // FlSpot(2, 5),
  // FlSpot(3, 50),
  // FlSpot(3.2, 30),
  // FlSpot(3.5, 10),
  // FlSpot(4, 5),
  // FlSpot(5, 50),
  // FlSpot(5.2, 30),
  // FlSpot(5.5, 10),
  // FlSpot(5, 100),
  // FlSpot(5.5, 1000),
  // FlSpot(6, 200),
  // FlSpot(6.5, 50),
  // FlSpot(7, 30),
];

List<FlSpot> kTidalCordinates = [
  FlSpot(0, 0),
  FlSpot(0.5, 700),
  FlSpot(1, 300),
  FlSpot(1.5, 200),
  FlSpot(2, 180),
  FlSpot(2.5, 180),
  FlSpot(3, 650),
  FlSpot(3.5, 350),
  FlSpot(4, 150),
  FlSpot(4.5, 180),
  FlSpot(5, 100),
  FlSpot(5.5, 700),
  FlSpot(6.5, 50),
  FlSpot(7, 348),
];

List<FlSpot> kFlowCordinates = [
  FlSpot(0, 0),
  FlSpot(1, -40),
  FlSpot(1.5, 60),
  FlSpot(2.5, -40),
  FlSpot(3, 60),
  FlSpot(4, -40),
  FlSpot(4.5, 55),
  FlSpot(5, 0),

  // FlSpot(5.5, 1000),
  // FlSpot(6, 200),
  // FlSpot(6.5, 50),
  // FlSpot(7, 30),
];
