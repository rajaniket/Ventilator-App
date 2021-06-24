import 'package:flutter/material.dart';
import 'package:ventilator/Stream/streamPage.dart';
import 'package:ventilator/home.dart';
import 'constants.dart';
import 'package:flutter/services.dart';

void main() {
  // rotation locked
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ventilator',
      theme: ThemeData.dark().copyWith(
        primaryColor: kbackgroundColour,
        scaffoldBackgroundColor: kbackgroundColour,
      ),
      home: MyHomePage(),
      routes: {
        "/home": (context) => MyHomePage(),
        "/streamPage": (context) => StreamPage(),
      },
    );
  }
}
