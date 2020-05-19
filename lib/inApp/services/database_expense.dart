import 'package:budgetControl/inApp/models/expense.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseExpenseService {
  final String uid;
  DatabaseExpenseService({this.uid});

  final CollectionReference collection = Firestore.instance.collection('users');

  //Expense list from snapshot

  List<Expense> _expenseListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return Expense.fromFirestore(doc);
    }).toList();
  }

  // get expenses
  Stream<List<Expense>> get expenses {
    return collection
        .document(uid)
        .collection('expenses')
        .snapshots()
        .map(_expenseListFromSnapshot);
  }

  // get filtered Expenses
  Stream getFilteredExpenses(
    String uid,
    String bankName,
    String expenseType,
    String expenseInstrument,
    String periodMonth,
    String periodYear,
  ) {
    return collection
        .document(uid)
        .collection('expenses')
        .where('bankName', isEqualTo: bankName)
        .where('expenseType', isEqualTo: expenseType)
        .where('expenseInstrument', isEqualTo: expenseInstrument)
        .where('periodMonth', isEqualTo: periodMonth)
        .where('periodYear', isEqualTo: periodYear)
        .orderBy('updatedAt')
        .snapshots();
  }

  Future createExpense(
      String uid,
      String bankName,
      String expenseType,
      String expenseAmount,
      String installmentPeriod,
      String expenseInstrument,
      String periodMonth,
      String periodYear) async {
    if (int.parse(installmentPeriod) == 1) {
      
      try {
        await collection
            .document(uid)
            .collection('expenses')
            .document()
            .setData({
          "bankName": bankName,
          "expenseType": expenseType,
          "expenseAmount": expenseAmount,
          "installmentPeriod": installmentPeriod,
          "expenseInstrument": expenseInstrument,
          "periodMonth": periodMonth,
          "periodYear": periodYear,
          "createdAt": FieldValue.serverTimestamp(),
          "updatedAt": FieldValue.serverTimestamp(),
        });
        return uid;
      } catch (e) {
        print('Hata oluştu!! : $e');
      }
    } else {
      
      int newPeriodMonth;
      int newPeriodYear;
      int forLoop = int.parse(installmentPeriod);
      double installmentedExpenseAmount = double.parse(expenseAmount) / forLoop;
      for (var i = 0; i < forLoop; i++) {
        int dummyPeriodMonth = (int.parse(periodMonth) + i);
        if (dummyPeriodMonth > 12) {
          newPeriodMonth = (dummyPeriodMonth - 12);
          newPeriodYear = (int.parse(periodYear) + 1);
        } else {
          newPeriodMonth = dummyPeriodMonth;
          newPeriodYear = (int.parse(periodYear));
        }

        try {
          await collection
              .document(uid)
              .collection('expenses')
              .document()
              .setData({
            "bankName": bankName,
            "expenseType": expenseType,
            "expenseAmount": installmentedExpenseAmount.toStringAsFixed(2),
            "installmentPeriod": (i + 1).toString(),
            "expenseInstrument": expenseInstrument,
            "periodMonth": newPeriodMonth.toString(),
            "periodYear": newPeriodYear.toString(),
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp(),
          });
        } catch (e) {
          print('Hata oluştu!! : $e');
        }
      }
      return uid;
    }
  }

  Future deleteExpense(String uid, String id) async {
    try {
      await collection
          .document(uid)
          .collection('expenses')
          .document(id)
          .delete();
      return uid;
    } catch (e) {
      print('Hata oluştu!! : $e');
      return null;
    }
  }

  Future editExpense(
    String uid,
    String id,
    String bankName,
    String expenseType,
    String expenseAmount,
    String installmentPeriod,
    String expenseInstrument,
    String periodMonth,
    String periodYear,
  ) async {
    try {
      await collection
          .document(uid)
          .collection('expenses')
          .document(id)
          .updateData({
        "bankName": bankName,
        "expenseType": expenseType,
        "expenseAmount": expenseAmount,
        "installmentPeriod": installmentPeriod,
        "expenseInstrument": expenseInstrument,
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
