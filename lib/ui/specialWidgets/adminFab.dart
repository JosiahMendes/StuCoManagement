import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminFAB extends StatefulWidget {
  String text;
  var onPressed;
  AdminFAB();
  @override
  _AdminFABState createState() => _AdminFABState();
}

class _AdminFABState extends State<AdminFAB> {
  String userId;

  Future<String> getUser() async {
    var user = await FirebaseAuth.instance.currentUser();
    return user.uid;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUser(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
        } else
        print('${snapshot.data}');
          return StreamBuilder(
            stream: Firestore.instance
                .collection('admins')
                .document('${snapshot.data}')
                .snapshots(),
            builder: (context, snapshot2) {
              print('${snapshot2.data}');

              if (snapshot2.hasError) {
                return Container(
                  constraints: BoxConstraints(maxHeight: 0, maxWidth: 0),
                );
              }
              if (snapshot2.hasData && snapshot2.data != null && snapshot2.data.exists) {
                return 
                
                FloatingActionButton.extended(
                    elevation: 4.0,
                    icon: Icon(Icons.add),
                    label: Text(
                      'Test',
                      style: TextStyle(fontSize: 13),
                    ),
                    onPressed: null);
              } else
                return Container(
                  constraints: BoxConstraints(maxHeight: 0, maxWidth: 0),
                );
            },
          );
      },
    );

    // StreamBuilder(
    //   stream:Firestore.instance.collection('admins').document('$userId').snapshots(),
    //   builder: (context,snapshot){
    //     if(snapshot.hasError) {
    //       return Center(child: Text("Error!"),);
    //     }
    //     if (snapshot.hasData){
    //       return FloatingActionButton.extended(
    //         elevation: 4.0,
    //         icon:  Icon(Icons.add),
    //         label: Text('Test', style: TextStyle(fontSize: 13),),
    //         onPressed: null
    //       );
    //     } else return Container(constraints: BoxConstraints(maxHeight: 0,maxWidth: 0),);
    //   },

    // );
  }
}
