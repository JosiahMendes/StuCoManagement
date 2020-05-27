import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:stuco2/services/crud.dart';
import 'package:stuco2/ui/specialWidgets/graphData.dart';
import 'package:stuco2/ui/transactions.dart';

class Finances extends StatefulWidget {
  @override
  _FinancesState createState() => _FinancesState();
}

class _FinancesState extends State<Finances> {
  var categories;
  double inflowTotal = 0.0;
  double outflowTotal = 0.0;

  CrudMethods crudObj =
      new CrudMethods('transactionsCategories', "transactionData");

  @override
  void initState() {
    crudObj.getData().then((results) {
      setState(() {
        categories = results;
      });
    });
    queryInflows();
    queryOutflows();
    super.initState();
  }

  void queryInflows() async {
    Firestore.instance
        .collection('transactionsCategories')
        .snapshots()
        .listen((snapshot) {
      double tempTotal = snapshot.documents
          .fold(0, (tot, doc) => tot + doc.data['totalInflows']);
      setState(() {
        inflowTotal = tempTotal;
      });
      debugPrint(inflowTotal.toString());
    });
  }

  void queryOutflows() async {
    Firestore.instance
        .collection('transactionsCategories')
        .snapshots()
        .listen((snapshot) {
      double tempTotal2 = snapshot.documents
          .fold(0, (tot, doc) => tot + doc.data['totalOutflows']);
      setState(() {
        outflowTotal = tempTotal2;
      });
      debugPrint(outflowTotal.toString());
    });
  }

  PageController controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: PageView(
                  controller: PageController(initialPage: 1),
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    TransactionsOverview(
                        (Category category, _) => category.totalInflows,
                        "Income"),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Expanded(
                            flex: 4,
                            child: Center(
                                child: Text(
                                    "Total Profit: ${(inflowTotal + outflowTotal).toString()} RMB",
                                    style:
                                        Theme.of(context).textTheme.headline5)),
                          ),
                          Expanded(
                            flex: 2,
                            child: Card(
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Center(
                                child: ListTile(
                                  leading: Icon(Icons.compare_arrows,
                                      color: Colors.green),
                                  title: Text("Income: " +
                                      inflowTotal.toString() +
                                      " RMB"),
                                  //  subtitle: Text("Swipe Up"),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Card(
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Center(
                                child: ListTile(
                                  leading: Icon(Icons.compare_arrows,
                                      color: Colors.red),
                                  title: Text("Expenditure: " +
                                      outflowTotal.toString() +
                                      " RMB"),
                                  // subtitle: Text("Swipe Down"),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TransactionsOverview(
                        (Category category, _) => category.totalOutflows,
                        "Expenditure"),
                  ],
                ),
              ),
              ListTile(
                onTap: null,
                title: Row(children: <Widget>[
                  new Expanded(
                      child: new Text(
                    "Category",
                    style: TextStyle(fontWeight: FontWeight.w800),
                  )),
                  new Expanded(
                      child: new Text("Category Profit",
                          textAlign: TextAlign.right,
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ]),
              ),
              Divider(
                color: Theme.of(context).accentColor,
              ),
              Expanded(
                child: expandableList(),
                flex: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  final SlidableController slidableController = new SlidableController();

  Widget expandableList() {
    if (categories != null) {
      return StreamBuilder(
          stream: categories,
          builder: (context, snapshot) {
            if (snapshot.hasError)
              return new Center(child: Text('${snapshot.error}'));
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return new Center(child: CircularProgressIndicator());
              default:
                return ListView.separated(
                    separatorBuilder: (context, index) => Divider(),
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, i) {
                      return Slidable(
                        controller: slidableController,
                        child: ListTile(
                            title: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(snapshot.data.documents[i]['name']),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Text((snapshot.data.documents[i]
                                              ['totalInflows'] -
                                          snapshot.data.documents[i]
                                              ['totalOutflows'])
                                      .toString() +
                                  " RMB"),
                            )
                          ],
                        )),
                        delegate: SlidableStrechDelegate(),
                        secondaryActions: <Widget>[
                          IconSlideAction(
                              caption:
                                  ("Inflows: ${snapshot.data.documents[i]['totalInflows'].toString()}"),
                              icon: Icons.arrow_downward,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Transactions(
                                        'transactionsCategories/${snapshot.data.documents[i]['name']}/inflows'),
                                  ),
                                );
                              }),
                          IconSlideAction(
                              caption:
                                  ("Outflows: ${snapshot.data.documents[i]['totalOutflows'].toString()}"),
                              icon: Icons.arrow_upward,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Transactions(
                                        'transactionsCategories/${snapshot.data.documents[i]['name']}/outflows'),
                                  ),
                                );
                              }),
                        ],
                      );
                    });
            }
          });
    } else {
      return Text('Loading, Please wait..');
    }
  }
}
