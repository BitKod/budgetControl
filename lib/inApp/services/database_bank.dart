import 'package:budgetControl/inApp/models/bank.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseBankService {
  final String uid;
  DatabaseBankService({this.uid});

  final CollectionReference collection = Firestore.instance.collection('users');

  //Bank list from snapshot

  List<Bank> _bankListFromSnapshot(QuerySnapshot snapshot) {
    
    return snapshot.documents.map((doc) {
      return Bank.fromFirestore(doc);
    }).toList();
  }

  // get banks
  Stream<List<Bank>> get banks {
    return collection
        .document(uid)
        .collection('banks')
        .snapshots()
        .map(_bankListFromSnapshot);
  }

  Future createBank(
      String uid, String bankName, String accountType, String owner) async {
    try {
      await collection.document(uid).collection('banks').document().setData({
        "bankName": bankName,
        "accountType": accountType,
        "owner": owner,
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });
      return uid;
    } catch (e) {
      print('Hata oluştu!! : $e');
    }
  }

  Future deleteBank(String id) async {
    try { 
      await collection
          .document(uid)
          .collection('banks')
          .document(id)
          .delete();
    } catch (e) {
      print('Hata oluştu!! : $e');
      return null;
    }
  }

  Future editBank(
      String uid,String id, String bankName, String accountType, String owner) async {
    try {
      await collection.document(uid).collection('banks').document(id).updateData({
        "bankName": bankName,
        "accountType": accountType,
        "owner": owner,
        "updatedAt": FieldValue.serverTimestamp(),
      });
      return uid;
    } catch (e) {
      print('Hata oluştu!! : $e');
      return null;
    }
  }
}
