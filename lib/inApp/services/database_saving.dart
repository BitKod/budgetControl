import 'package:budgetControl/core/constants/app_constants.dart';
import 'package:budgetControl/inApp/models/saving.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

class DatabaseSavingService {
  final String uid;
  DatabaseSavingService({this.uid});

  final CollectionReference collection = Firestore.instance.collection('users');

  //Saving list from snapshot

  List<Saving> _savingListFromSnapshot(QuerySnapshot snapshot) {
    
    return snapshot.documents.map((doc) {
      return Saving.fromFirestore(doc);
    }).toList();
  }




  // get savings
  Stream<List<Saving>> get savings {
    return collection
        .document(uid)
        .collection('savings')
        .snapshots()
        .map(_savingListFromSnapshot);
  }

   // get filtered Savings
  Stream getFilteredSavings(
    String uid,
    String bankName,
    String savingType,
    String savingDate,
  ) {
    return collection
        .document(uid)
        .collection('savings')
        .where('bankName', isEqualTo: bankName)
        .where('savingType', isEqualTo: savingType)
        .where('savingDate', isEqualTo: savingDate)
        .orderBy('updatedAt')
        .snapshots();
  }

  Future createSaving(
      String uid, String bankName, String savingType, String savingAmount,String savingCurrency, String savingDate) async {
    try {
      await collection.document(uid).collection('savings').document().setData({
        "bankName": bankName,
        "savingType": savingType,
        "savingAmount": savingAmount,
        "savingCurrency": savingCurrency,
        "savingDate": savingDate,
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });
      return uid;
    } catch (e) {
      print('Hata oluştu!! : $e');
    }
  }

  Future deleteSaving(String uid, String id) async {
    try { 
      await collection
          .document(uid)
          .collection('savings')
          .document(id)
          .delete();
          return uid;
    } catch (e) {
      print('Hata oluştu!! : $e');
      return null;
    }
  }

  Future editSaving(
      String uid,String id, String bankName, String savingType, String savingAmount,String savingCurrency, String savingDate) async {
    try {
      await collection.document(uid).collection('savings').document(id).updateData({
        "bankName": bankName,
        "savingType": savingType,
        "savingAmount": savingAmount,
        "savingCurrency": savingCurrency,
        "savingDate": savingDate,
        "updatedAt": FieldValue.serverTimestamp(),
      });
      return uid;
    } catch (e) {
      print('Hata oluştu!! : $e');
      return null;
    }
  }

Future getCurrencyEUR() async {
    try { 
  var response = await Dio().get(AppConstants.FIXER_GET_CURRENCY);
  return response.data['rates']['TRY'];
    } catch (e) {
      print('Hata oluştu!! : $e');
      return null;
    }
  }
  Future getCurrencyUSD() async {
    try { 
  var response = await Dio().get(AppConstants.FIXER_GET_CURRENCY);
  return response.data['rates']['TRY']/response.data['rates']['USD'];
    } catch (e) {
      print('Hata oluştu!! : $e');
      return null;
    }
  }




}
