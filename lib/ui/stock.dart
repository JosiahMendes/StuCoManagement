import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stuco2/services/crud.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Stock extends StatefulWidget {
  @override
  _StockState createState() => _StockState();
}

class _StockState extends State<Stock> {
  CrudMethods crudObj = new CrudMethods('products', "productData");
  String productName, productQuantity, productPrice;

  var products;

  Future<bool> addDialog(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Add New Product'),
            content: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    decoration: InputDecoration(hintText: 'Enter Product Name'),
                    onChanged: (value) {
                      this.productName = value;
                    },
                  ),
                  SizedBox(height: 5.0),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration:
                        InputDecoration(hintText: 'Enter product quantity'),
                    onChanged: (value) {
                      this.productQuantity = value;
                    },
                  ),
                  SizedBox(height: 5.0),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration:
                        InputDecoration(hintText: 'Enter product price'),
                    onChanged: (value) {
                      this.productPrice = value;
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
                        'name': this.productName,
                        'quantity': int.parse(this.productQuantity),
                        'price': int.parse(this.productPrice),
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

  Future<bool> updateDialog(BuildContext context, selectedDoc) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Update Product Information'),
            content: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    decoration: InputDecoration(
                      helperText: 'Re-enter Product Name',
                    ),
                    onChanged: (value) {
                      this.productName = value;
                    },
                  ),
                  SizedBox(height: 5.0),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        helperText: 'Re-enter Product Quantity'),
                    onChanged: (value) {
                      this.productQuantity = value;
                    },
                  ),
                  SizedBox(height: 5.0),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration:
                        InputDecoration(helperText: 'Re-enter Product Price'),
                    onChanged: (value) {
                      this.productPrice = value;
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
                        'name': this.productName,
                        'quantity': int.parse(this.productQuantity),
                        'price': int.parse(this.productPrice),
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
    crudObj.getData().then((results) {
      setState(() {
        products = results;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              crudObj.getData().then((results) {
                setState(() {
                  products = results;
                });
              });
            },
          )
        ],
        title: new Text("Stock"),
      ),
      body: Center(child: _productList()),
      floatingActionButton: FloatingActionButton.extended(
        elevation: 4.0,
        icon: const Icon(Icons.add),
        label: const Text('Add a product'),
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

  Widget _productList() {
    if (products != null) {
      return StreamBuilder(
          stream: products,
          builder: (context, snapshot) {
            if (snapshot.hasError)
              return new Center(child: Text('${snapshot.error}'));
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return new Center(child: CircularProgressIndicator());
              default:
                return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, i) {
                      return Slidable(
                        actions: <Widget>[
                          IconSlideAction(
                            caption: 'Update',
                            icon: Icons.update,
                            color: Colors.blue,
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
                        child: ListTile(
                            title: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(snapshot.data.documents[i]['name']),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Text("Qty " +
                                  snapshot.data.documents[i]['quantity']
                                      .toString()),
                            )
                          ],
                        )),
                        delegate: SlidableStrechDelegate(),
                        controller: slidableController,
                      );
                    });
            }
          });
    } else {
      return Text('Loading, Please wait..');
    }
  }
}
