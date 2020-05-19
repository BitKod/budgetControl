import 'package:budgetControl/inApp/models/fixed_expense.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseFixedExpenseService {
  final String uid;
  DatabaseFixedExpenseService({this.uid});

  final CollectionReference collection = Firestore.instance.collection('users');

  //FixedExpense list from snapshot

  List<FixedExpense> _fixedExpenseListFromSnapshot(QuerySnapshot snapshot) {
    
    return snapshot.documents.map((doc) {
      return FixedExpense.fromFirestore(doc);
    }).toList();
  }

  // get banks
  Stream<List<FixedExpense>> get fixedExpenses {
    return collection
        .document(uid)
        .collection('fixedExpenses')
        .snapshots()
        .map(_fixedExpenseListFromSnapshot);
  }

  Future createFixedExpense(
      String uid, String expenseType, String paymentInstrument, String details) async {
    try {
      await collection.document(uid).collection('fixedExpenses').document().setData({
        "expenseType": expenseType,
        "paymentInstrument": paymentInstrument,
        "details": details,
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });
      return uid;
    } catch (e) {
      print('Hata oluştu!! : $e');
    }
  }

  Future deleteFixedExpense(String id) async {
    try { 
      await collection
          .document(uid)
          .collection('fixedExpenses')
          .document(id)
          .delete();
    } catch (e) {
      print('Hata oluştu!! : $e');
      return null;
    }
  }

  Future editFixedExpense(
      String uid,String id, String expenseType, String paymentInstrument, String details) async {
    try {
      await collection.document(uid).collection('fixedExpenses').document(id).updateData({
        "expenseType": expenseType,
        "paymentInstrument": paymentInstrument,
        "details": details,
        "updatedAt": FieldValue.serverTimestamp(),
      });
      return uid;
    } catch (e) {
      print('Hata oluştu!! : $e');
      return null;
    }
  }
}
