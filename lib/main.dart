import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: Checkout(),
    );
  }
}



class Checkout extends StatefulWidget {
  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  Map<String, int> checkout = {};

  Widget _buildGridItem(BuildContext context, DocumentSnapshot document) {
    final name = document['name'];
    return GestureDetector(
      child: Card(
        elevation: 5.0,
        child: new Container(
          alignment: Alignment.center,
          child: Text(
            name,
            textAlign: TextAlign.center,
          ),
        ),
      ),
      onTap: () {
        setState(
          () {
            checkout.update(name, (q) => q + 1, ifAbsent: () => 1);
          },
        );
      },
    );
  }

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: StreamBuilder(
              stream: Firestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Text("Loading....");
                return GridView.builder(
                  itemCount: snapshot.data.documents.length,
                  gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4),
                  itemBuilder: (context, index) =>
                      _buildGridItem(context, snapshot.data.documents[index]),
                );
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              alignment:Alignment.topLeft,
              // decoration: BoxDecoration(
              //   border: Border.all(color:
              // ),
              padding: EdgeInsets.all(8.0),
              // alignment: Alignment.bottomCenter,
              color: Colors.white30,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: checkout.length,
                itemBuilder: (context, i) {
                  final entry = checkout.entries.elementAt(i);
                  return Text(
                    "${entry.key} x${entry.value}",
                    style: TextStyle(
                      fontWeight: FontWeight.w600
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.payment),
        onPressed: () {
          //Firestore.removeQuantityOrWhatHaveYou();
          setState(
            () {
              checkout.clear();
            },
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 4.0,
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.cancel),
              onPressed: () {
                setState(
                  () {
                    checkout.clear();
                  },
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.developer_board),
              onPressed: () {
              
              },
            ),
          ],
        ),
      ),
    );
  }
}
