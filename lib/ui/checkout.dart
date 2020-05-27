import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stuco2/ui/stock.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

CollectionReference _productCollection() {
  return Firestore.instance.collection('products');
}

Stream<List<Product>> _getProductDatabase() {
  return _productCollection().snapshots().map((products) {
    return products.documents.map((doc) => Product.fromDoc(doc)).toList();
  });
}

class Product {
  Product();

  DocumentReference _ref;
  String _sku;
  String name;
  double price;
  int stockLevel;

  String get sku => _sku;

  factory Product.fromDoc(DocumentSnapshot doc) {
    final product = Product();
    product._ref = doc.reference;
    product._sku = doc.documentID;
    product.name = (doc.data['name'] as String);
    product.price = (doc.data['price'] as num).toDouble();
    product.stockLevel = (doc.data['quantity'] as int);

    return product;
  }

  Future<void> removeStock(int count) async {
    await Firestore.instance.runTransaction((Transaction transaction) async {
      final doc = await transaction.get(_ref);
      stockLevel = doc.data['quantity'] as int;

      final data = {
        'quantity': stockLevel - count,
      };
      await transaction.update(_ref, data);
    });
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          _sku == other._sku;

  @override
  int get hashCode => _sku.hashCode;
}

class CheckoutItem {
  CheckoutItem(this.product) : _quantity = 1;

  final Product product;
  int _quantity;
  int get quantity => _quantity;
  double get total => _quantity * product.price;

  void incrementQuantity() {
    _quantity++;
  }

  void decrementQuantity() {
    _quantity--;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheckoutItem &&
          runtimeType == other.runtimeType &&
          product == other.product;

  @override
  int get hashCode => product.hashCode;
}

class CheckoutBasket {
  final items = Set<CheckoutItem>();
  DateTime now = DateTime.now();

  void addProduct(Product product) {
    final newItem = CheckoutItem(product);
    final currentItem = items.lookup(newItem);
    if (currentItem != null) {
      currentItem.incrementQuantity();
    } else {
      items.add(newItem);
    }
  }

  double get total => items.fold(0.0, (prev, item) => prev + item.total);

  int get itemCount => items.length;

  CheckoutItem operator [](int index) => items.elementAt(index);

  void clear() {
    items.clear();
  }

  void updateStockLevel() {
    for (CheckoutItem item in items) {
      item.product.removeStock(item.quantity);
    }
  }

  Future<void> addTransaction(double basketTotal) async {
    await Firestore.instance.runTransaction((Transaction transaction) async {
      final transactionData = {
        'amount': basketTotal,
        'description': 'Automatic Addition: Tuck Shop Store Sales',
        'time': now,
      };
      await Firestore.instance
          .collection('transactionsCategories/Tuck Shop/inflows')
          .add(transactionData);
    });
  }
}

class Checkout extends StatefulWidget {
  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  final CheckoutBasket basket = CheckoutBasket();

  Widget _buildGridItem(BuildContext context, Product product) {
    return GestureDetector(
      child: Card(
        elevation: 5.0,
        child: Center(
          child: new ListTile(
            title: Text(
              product.name,
              textAlign: TextAlign.center,
            ),
            subtitle: Text(
              product.price.toString() + ' RMB',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      onTap: () {
        setState(() {
          basket.addProduct(product);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: StreamBuilder(
              stream: _getProductDatabase(),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return new Center(child: Text('${snapshot.error}'));
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return new Center(child: CircularProgressIndicator());
                  default:
                    return GridView.builder(
                      itemCount: snapshot.data.length,
                      gridDelegate:
                          new SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:
                                  MediaQuery.of(context).size.width <= 600
                                      ? 3
                                      : MediaQuery.of(context).size.width >=
                                              1000
                                          ? 6
                                          : 4),
                      itemBuilder: (context, index) =>
                          _buildGridItem(context, snapshot.data[index]),
                    );
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.topLeft,
              // decoration: BoxDecoration(
              //   border: Border.all(color:
              // ),
              padding: EdgeInsets.all(8.0),
              decoration: new BoxDecoration(
                  border: new Border(
                      top: BorderSide(color: Theme.of(context).dividerColor))),
              // alignment: Alignment.bottomCenter,

              child: Column(
                children: <Widget>[
                  Text(
                    'Checkout Items',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).accentColor),
                  ),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: basket.itemCount,
                      itemBuilder: (context, i) {
                        final item = basket[i];
                        return Text(
                          "${item.product.name} x${item.quantity}",
                          style: TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 14),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.payment),
        onPressed: () {
          final double total = basket.total;
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Checkout Total'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(padding:EdgeInsets.all(8.0),child: Image.asset('images/qrcode.jpg',fit: BoxFit.cover,)),
                    Text("Total: $total RMB", style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),)
                  ],
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text("Paid"),
                    onPressed: () {
                      basket.updateStockLevel();
                      basket.addTransaction(total);
                      setState(() {
                        basket.clear();
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: Text("Go Back"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
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
                    basket.clear();
                  },
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.developer_board),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Stock()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
