import 'package:budgetControl/inApp/models/income.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseIncomeService {
  final String uid;
  DatabaseIncomeService({this.uid});

  final CollectionReference collection = Firestore.instance.collection('users');

  //Income list from snapshot

  List<Income> _incomeListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return Income.fromFirestore(doc);
    }).toList();
  }

  // get incomes
  Stream<List<Income>> get incomes {
    return collection
        .document(uid)
        .collection('incomes')
        .snapshots()
        .map(_incomeListFromSnapshot);
  }

  // get filtered Incomes
  Stream getFilteredIncomes(
    String uid,
    String bankName,
    String incomeType,
    String periodMonth,
    String periodYear,
  ) {
    return collection
        .document(uid)
        .collection('incomes')
        .where('bankName', isEqualTo: bankName)
        .where('incomeType', isEqualTo: incomeType)
        .where('periodMonth', isEqualTo: periodMonth)
        .where('periodYear', isEqualTo: periodYear)
        .orderBy('updatedAt')
        .snapshots();
  }

  Future createIncome(
    String uid,
    String bankName,
    String incomeType,
    String incomeAmount,
    String periodMonth,
    String periodYear,
  ) async {
    try {
      await collection.document(uid).collection('incomes').document().setData({
        "bankName": bankName,
        "incomeType": incomeType,
        "incomeAmount": incomeAmount,
        "periodMonth": periodMonth,
        "periodYear": periodYear,
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });
      return uid;
    } catch (e) {
      print('Hata oluştu!! : $e');
    }
  }

  Future deleteIncome(String uid, String id) async {
    try {
      await collection
          .document(uid)
          .collection('incomes')
          .document(id)
          .delete();
      return uid;
    } catch (e) {
      print('Hata oluştu!! : $e');
      return null;
    }
  }

  Future editIncome(
    String uid,
    String id,
    String bankName,
    String incomeType,
    String incomeAmount,
    String periodMonth,
    String periodYear,
  ) async {
    try {
      await collection
          .document(uid)
          .collection('incomes')
          .document(id)
          .updateData({
        "bankName": bankName,
        "incomeType": incomeType,
        "incomeAmount": incomeAmount,
        "periodMonth": periodMonth,
        "periodYear": periodYear,
        "updatedAt": FieldValue.serverTimestamp(),
      });
      return uid;
    } catch (e) {
      print('Hata oluştu!! : $e');
      return null;
    }
  }
}
