import 'package:flutter/material.dart';
import 'package:stuco2/ui/checkout.dart';
import 'package:stuco2/ui/finances.dart';
import 'package:stuco2/ui/noticeboard.dart';
import 'package:firebase_auth/firebase_auth.dart';



class MyHome extends StatefulWidget {
  const MyHome({Key key, this.user}) : super(key: key);
  final FirebaseUser user;
  @override
  MyHomeState createState() => new MyHomeState();
}

// SingleTickerProviderStateMixin is used for animation
class MyHomeState extends State<MyHome> with SingleTickerProviderStateMixin {
  // Create a tab controller
  TabController controller;



  @override
  void initState() {
    super.initState();

    // Initialize the Tab Controller
    controller = new TabController(length: 3, vsync: this, initialIndex: 1,);
  }

  @override
  void dispose() {
    // Dispose of the Tab Controller
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new TabBarView(
        // Add tabs as widgets
        children: <Widget>[Checkout(), NoticeBoard(), Finances()],
        // set the controller
        controller: controller,
      ),
      // Set the bottom navigation bar
      bottomNavigationBar:
      new Material(
        // set the color of the bottom navigation bar
        // set the tab bar as the child of bottom navigation bar
        child: new TabBar(
          labelColor: Colors.black,
          tabs: <Tab>[
            new Tab(
              text:  ("Checkout"),
              // set icon to the tab
//              icon: new Icon(Icons.favorite),
            ),
            new Tab(
              text:  ("Notices"),
//              icon: new Icon(Icons.adb),
            ),
            new Tab(
              text:  ("Finances"),
//              icon: new Icon(Icons.airport_shuttle),
            ),
            
          ],
          // setup the controller
          controller: controller,
        ),
      ),
    );
  }
}