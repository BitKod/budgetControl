// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:budgetControl/core/constants/app_constants.dart';
import 'package:budgetControl/inApp/models/bank.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';



void main() {
  //TestWidgetsFlutterBinding.ensureInitialized();

 //CollectionReference collection = Firestore.instance.collection('users');
//var dio=Dio();

setUp((){
  
});



  /*test('getExpenses', ()  {
    // Build our app and trigger a frame.
    
    
    var result=collection
        .document('cKtOgQXD06dzi8OeVxit5Idz0Ud2')
        .collection('expenses')
        .snapshots();

        expect(result.isEmpty, false);
  });*/
List<Bank> _bankListFromSnapshot(QuerySnapshot snapshot) {
    
    return snapshot.documents.map((doc) {
      return Bank.fromFirestore(doc);
    }).toList();
  }
test('getCurrency', ()  async {
    // Build our app and trigger a frame.
  var response = await Dio().get(AppConstants.FIXER_GET_CURRENCY);
  print(response.data['rates']['USD']);
  print(response.data['rates']['TRY']);

  expect(response.statusCode, 200);
  });

  test('getBanks', ()  async {
    // Build our app and trigger a frame.
  var banks=Firestore.instance.collection('users')
  .document('bwUIhjWad3ThotBtAFDNXHUc3f32')
        .collection('banks')
        .snapshots()
        .map(_bankListFromSnapshot);


  expect(banks.isEmpty, false);
  });



}
