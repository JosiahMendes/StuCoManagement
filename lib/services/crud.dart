import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class CrudMethods {
  var path; //Stores path in for file database 
  var data; //Stores data to be added/deleted/updated
  CrudMethods(this.path, this.data);

//Asynchronous method to add new data
  Future<void> addData(data) async {
    Firestore.instance.collection(path)
      .add(data)
      .catchError(
        (e) {print(e); },
      );
  }
//Asynchronous method to get current data
  getData() async {
    return Firestore.instance.collection(path).snapshots();
  }

  getTimeDescendingData() async {
    return Firestore.instance
        .collection(path)
        .orderBy('time', descending: true)
        .snapshots();
  }
//Asynchronous method to update current data with new data
  Future<void> updateData(selectedDoc, newValues) async {
    Firestore.instance.collection(path).document(selectedDoc)
        .updateData(newValues)
        .catchError(
      (e) {
        print(e);
      },
    );
  }
//Method to delete data from database
  deleteData(docId) {
    Firestore.instance.collection(path).document(docId)
        .delete()
        .catchError((e) {
      print(e);
    });
  }
}
