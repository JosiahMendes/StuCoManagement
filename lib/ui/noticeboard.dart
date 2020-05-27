import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stuco2/services/crud.dart';
import 'package:stuco2/ui/login.dart';
import 'package:firebase_auth/firebase_auth.dart';





class NoticeBoard extends StatefulWidget {
  @override
  _NoticeBoardState createState() => _NoticeBoardState();
}

class _NoticeBoardState extends State<NoticeBoard> {
  CrudMethods crudObj = new CrudMethods('notices', "noticeData");
  String title;
  var notices;
  DateTime now = DateTime.now();

  Future<bool> addDialog(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Add Notice'),
            content: TextField(
              maxLines: null,
              decoration: InputDecoration(hintText: 'Enter Title'),
              onChanged: (value) {
                this.title = value;
              },
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Add'),
                onPressed: () {
                  Navigator.of(context).pop();
                  crudObj
                      .addData({
                        'title': this.title,
                        'time': now,
                      })
                      .then((result) {})
                      .catchError((e) {
                        print(e);
                      });
                },
              ),
              FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  void initState() {
    crudObj.getTimeDescendingData().then((results) {
      if (this.mounted)
      {setState(() {
        notices = results;
      });}
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SafeArea(
            child: Container(
              padding: EdgeInsets.all(15.0),
              child: Text(
                "Welcome to \n StuCo Management",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 30,
                  color: Theme.of(context).accentColor,
                ),
              ),
            ),
          ),
          Expanded(child: _noticeList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
          elevation: 4.0,
          icon: const Icon(Icons.add),
          label: const Text(
            'Add a Notice',
            style: TextStyle(fontSize: 13),
          ),
          onPressed: () {
            addDialog(context);
          },
      ),
      // floatingActionButton: AdminFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                Future<void> signOut() async {
                  return FirebaseAuth.instance.signOut();
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
            // IconButton(icon:Icon(Icons.access_time), onPressed: null,)
          ],
        ),
      ),
    );
  }

  Widget _noticeList() {
    if (notices != null) {
      return StreamBuilder(
          stream: notices,
          builder: (context, snapshot) {
            if (snapshot.hasError) return new Center(child:Text('${snapshot.error}'));
                 switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return new Center(child:  CircularProgressIndicator());
                    default:
            return ListView.separated(
                separatorBuilder: (context, index) => Divider(),
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, i) {
                  return new ListTile(
                      subtitle:
                          Text(snapshot.data.documents[i]['time'].toString()),
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Delete Confirmation'),
                              content: Text(
                                  'Are you sure you want to delete this? \n\nThis cannot be undone!'),
                              actions: <Widget>[
                                Row(
                                  children: <Widget>[
                                    FlatButton(
                                      child: Text('Yes'),
                                      onPressed: () {
                                        crudObj.deleteData(snapshot
                                            .data.documents[i].documentID);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    FlatButton(
                                      child: Text('No'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    )
                                  ],
                                )
                              ],
                            );
                          },
                        );
                      },
                      title: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(snapshot.data.documents[i]['title']),
                          ),
                        ],
                      ));
                });}
          });
    } else {
      return Text('Loading, Please wait..');
    }
  }
}
