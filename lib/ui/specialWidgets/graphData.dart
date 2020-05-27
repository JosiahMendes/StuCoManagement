import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charts_flutter/flutter.dart' as charts;

CollectionReference _categoryCollection() {
  return Firestore.instance.collection('transactionsCategories');
}

Stream<List<Category>> _getCategoryDatabase() {
  return _categoryCollection().snapshots().map((categories) {
    return categories.documents.map((doc) => Category.fromDoc(doc)).toList();
  });
}


class Category {
  Category();

  String name;
  double totalInflows;
  double totalOutflows;

  factory Category.fromDoc(DocumentSnapshot doc) {
    final category = Category();
    category.name = (doc.data['name'] as String);
    category.totalInflows = (doc.data['totalInflows'] as num).toDouble();
    category.totalOutflows = (doc.data['totalOutflows'] as num).toDouble();

    return category;
  }
}





class TransactionsOverview extends StatefulWidget {
  final measure;
  String title;
  TransactionsOverview(this.measure, this.title);
  @override
  _TransactionsOverviewState createState() => _TransactionsOverviewState();
}

class _TransactionsOverviewState extends State<TransactionsOverview> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: StreamBuilder(
        stream: _getCategoryDatabase(),
        builder: (context,  snapshot){
          if(snapshot.hasError) {
                      return Center(child: Text("Error!"),);
                    }
                    
                    if(snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } 
                    
                    if(snapshot.hasData) {
                      return getChartWidget(snapshot.data,snapshot.data,widget.measure,widget.title);
                    }
                  },
      )
    );
  }



Widget getChartWidget(List<Category> category,List data,measure,title) {
  var series = [
      new charts.Series<Category, String>(
        domainFn: (Category category, _) => category.name,
        // measureFn: widget.measure,
        measureFn: measure,
        // colorFn:
        id: 'Values',
        data: data,
        labelAccessorFn: (Category category, _) => '${category.name}',
      ),
    ];
    return charts.PieChart(
      series,
      animate: true,
      behaviors: [charts.ChartTitle(title, behaviorPosition: charts.BehaviorPosition.top,
            titleOutsideJustification: charts.OutsideJustification.start,innerPadding: 18)],
      defaultRenderer: charts.ArcRendererConfig(
        // arcWidth: 60,
        arcRendererDecorators: [
          charts.ArcLabelDecorator(
            labelPosition: charts.ArcLabelPosition.auto,
          )
        ],
      ),
    );
}
}

