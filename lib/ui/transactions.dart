import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stuco2/services/crud.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Transactions extends StatefulWidget {
  final path;
  Transactions(this.path);
  @override
  _TransactionsState createState() => _TransactionsState();
}


class _TransactionsState extends State<Transactions> {
  String transactionDescription, transactionAmount;
  DateTime now = DateTime.now();

  var transactions;

  Future<bool> addDialog(BuildContext context) async {
    CrudMethods crudObj = new CrudMethods(widget.path, "transactionData");

    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Add New Transaction'),
            content: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    decoration: InputDecoration(hintText: 'Enter Description'),
                    maxLines: null,
                    onChanged: (value) {
                      this.transactionDescription = value;
                    },
                  ),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration:
                        InputDecoration(hintText: 'Enter Transaction Amount'),
                    onChanged: (value) {
                      this.transactionAmount = value;
                    },
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Add'),
                onPressed: () {
                  Navigator.of(context).pop();
                  crudObj
                      .addData({
                        'description': this.transactionDescription,
                        'amount': double.parse(this.transactionAmount),
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


  Future<bool> updateDialog(BuildContext context, selectedDoc,) async {
    CrudMethods crudObj = new CrudMethods(widget.path, "transactionData");

    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Update Transaction Amount'),
            content: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration:
                        InputDecoration(helperText: 'Re-enter Product Price'),
                    onChanged: (value) {
                      this.transactionAmount = value;
                    },
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Add'),
                onPressed: () {
                  Navigator.of(context).pop();
                  crudObj
                      .updateData(selectedDoc, {
                        'amount': double.parse(this.transactionAmount),
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
    CrudMethods crudObj = new CrudMethods(widget.path, "transactionData");
    crudObj.getTimeDescendingData().then((results) {
      setState(() {
        transactions = results;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CrudMethods crudObj = new CrudMethods(widget.path, "transactionData");
    return Scaffold(
      appBar: new AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              crudObj.getTimeDescendingData().then((results) {
                setState(() {
                  transactions = results;
                });
              });
            },
          )
        ],
        title: new Text("Transactions"),
      ),
      body: Center(child: _transactionsList()),
      floatingActionButton: FloatingActionButton.extended(
        elevation: 4.0,
        icon: const Icon(Icons.add),
        label: const Text('Add a Transaction'),
        onPressed: () {
          addDialog(context);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
      ),
    );
  }

  final SlidableController slidableController = new SlidableController();
  Widget _transactionsList() {
    CrudMethods crudObj = new CrudMethods(widget.path, "transactionData");
    if (transactions != null) {
      return StreamBuilder(
          stream: transactions,
          builder: (context, snapshot) {
            if (snapshot.hasError) return new Center(child:Text('${snapshot.error}'));
                 switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return new Center(child:  CircularProgressIndicator());
                    default:
                return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, i) {
                      return Slidable(
                        controller: slidableController,
                        delegate: SlidableStrechDelegate(),
                        actions: <Widget>[
                          IconSlideAction(
                            caption: 'Update',
                            icon: Icons.update,
                            onTap: () {
                              updateDialog(context,
                                  snapshot.data.documents[i].documentID);
                            },
                          )
                        ],
                        secondaryActions: <Widget>[
                          IconSlideAction(
                            caption: 'Delete',
                            icon: Icons.delete,
                            color: Colors.red,
                            onTap: () {
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
                                              crudObj.deleteData(snapshot.data
                                                  .documents[i].documentID);
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
                          )
                        ],
                        child: new ListTile(
                            subtitle: Text(
                                snapshot.data.documents[i]['time'].toString()),
                            title: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(snapshot.data.documents[i]
                                      ['description']),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    snapshot.data.documents[i]['amount']
                                            .toString() +
                                        "RMB",
                                    style: TextStyle(
                                        color: snapshot.data.documents[i]
                                                    ['amount'] >
                                                0
                                            ? Colors.green
                                            : Colors.red),
                                  ),
                                )
                              ],
                            )),
                        // decoration:
                      );
                    });
            }
          });
    } else {
      return Text('Loading, Please wait..');
    }
  }
}
