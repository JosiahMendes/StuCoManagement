import 'package:flutter/material.dart';
import 'package:stuco2/ui/login.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
      theme: ThemeData(
        brightness: Brightness.light,
        // brightness: Brightness.dark,
        
        primaryColor: Color(0xff5D1049),
        primaryColorDark: Color(0xff4E0d3a),
        primaryColorLight: Color(0xff720D5d),
        accentColor: Color(0xffe30425),
        errorColor: Color(0xffff9800),
        fontFamily: 'Raleway',
      ),
    );
  }
}
